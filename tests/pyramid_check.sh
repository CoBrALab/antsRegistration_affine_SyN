#!/bin/bash
# Self-check for the automatic pyramid generation. Runs without image data.
# Usage: tests/pyramid_check.sh
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
script="${here}/../antsRegistration_affine_SyN.sh"
fns=$(mktemp)
trap 'rm -f "$fns"' EXIT
# Pull only the helper and pyramid functions out of the script.
sed -n '/^function calc/,/^# Add handler for failure/p' "$script" | head -n -1 >"$fns"
sed -n '/^function make_syn_pyramid/,/^# Setup exit trap/p' "$script" | head -n -1 >>"$fns"
# shellcheck disable=SC1090
source "$fns"

fail() { echo "FAIL: $*" >&2; exit 1; }

# levels_of "<pyramid text>" prints "shrink sigma" per level, in order.
levels_of() {
  paste -d' ' <(grep -o -- '--shrink-factors [^ ]*' <<<"$1" | cut -d' ' -f2 | tr 'x' '\n') \
              <(grep -o -- '--smoothing-sigmas [^ ]*' <<<"$1" | cut -d' ' -f2 | sed 's/mm//' | tr 'x' '\n')
}

check_monotone() { # shrinks and sigmas never increase towards the fine end
  awk -v name="$1" '
    NR > 1 && ($1 > ps || $2 > psig) { printf "FAIL: %s level %d (%s %s) is coarser than the previous (%s %s)\n", name, NR, $1, $2, ps, psig; bad = 1 }
    { ps = $1; psig = $2 }
    END { exit bad }'
}

# Case 1: 1 mm human T1 to 1 mm template. FWHM 1 .. 12.06, 4 per octave -> 15 levels.
syn=$(make_syn_pyramid --min-spacing 1.0 --min-fwhm 1 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 20)
n=$(levels_of "$syn" | wc -l)
((n == 15)) || fail "human SyN expected 15 levels, got $n"
levels_of "$syn" | check_monotone "human SyN"
[[ $(levels_of "$syn" | head -1) == "11 "* ]] || fail "human SyN coarsest shrink should be 11"
[[ $(levels_of "$syn" | tail -1) == "1 0.0000" ]] || fail "human SyN finest level should be unsmoothed"
[[ $(levels_of "$syn" | cut -d' ' -f2 | sort | uniq -d) == "" ]] || fail "human SyN has duplicate sigmas"

affine=$(make_affine_pyramid --min-spacing 1.0 --min-fwhm 1 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 50 --reg-type affine --linear-metric Mattes)
grep -c -- '--transform' <<<"$affine" | grep -qx 3 || fail "human affine expected 3 stages"
# Stages: Rigid 5 levels, Similarity 3 + 1 hand-over, Affine 7 + 1 hand-over.
[[ $(grep -o -- '--shrink-factors [^ ]*' <<<"$affine" | tr '\n' ' ') == "--shrink-factors 11x9x8x6x5 --shrink-factors 5x4x4x3 --shrink-factors 3x2x2x2x1x1x1x1 " ]] \
  || fail "human affine shrink factors: $(grep -o -- '--shrink-factors [^ ]*' <<<"$affine" | tr '\n' ' ')"
# Hand-over repeats exactly the previous stage's last sigma.
sig=($(grep -o -- '--smoothing-sigmas [^ ]*' <<<"$affine" | cut -d' ' -f2 | sed 's/mm//'))
[[ ${sig[0]##*x} == ${sig[1]%%x*} && ${sig[1]##*x} == ${sig[2]%%x*} ]] || fail "hand-over sigma mismatch: ${sig[*]}"

# Case 2: masked, not mask-all -> mid stage repeated with masks, 4 stages, no hand-over into the repeat.
masked=$(make_affine_pyramid --min-spacing 1.0 --min-fwhm 1 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 50 --reg-type affine --linear-metric Mattes --masked)
grep -c -- '--transform' <<<"$masked" | grep -qx 4 || fail "masked affine expected 4 stages"
[[ $(grep -o -- '--shrink-factors [^ ]*' <<<"$masked" | sed -n 3p) == "--shrink-factors 4x4x3" ]] || fail "masked mid repeat should not get a hand-over"

# Case 3: 3 mm fMRI moving on a 1 mm T1: finest level is shrink 3, no fine stage.
fmri=$(make_affine_pyramid --min-spacing 1.0 --min-fwhm 3 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 50 --reg-type affine --linear-metric Mattes)
grep -c -- '--transform' <<<"$fmri" | grep -qx 2 || fail "fMRI affine expected 2 stages (no fine band)"
[[ $(levels_of "$fmri" | tail -1) == "3 "* ]] || fail "fMRI finest shrink should be 3"
[[ $(grep -- '--transform' <<<"$fmri" | tail -1) == *Affine* ]] || fail "fMRI last stage must be the requested Affine"

# Case 4: tiny image where the finest scale exceeds the coarsest still yields one level.
tiny=$(make_syn_pyramid --min-spacing 0.3 --min-fwhm 3.3 --max-fwhm 2 --convergence 1e-6 --final-iterations 20)
((  $(levels_of "$tiny" | wc -l) == 1 )) || fail "tiny image should give exactly one level"

# Case 5: --rough drops shrink 1 and 2, --close caps shrink at 4.
rough=$(make_syn_pyramid --min-spacing 1.0 --min-fwhm 1 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 20 --rough)
[[ $(levels_of "$rough" | tail -1) == "3 "* ]] || fail "rough finest shrink should be 3"
close=$(make_syn_pyramid --min-spacing 1.0 --min-fwhm 1 --max-fwhm 12.06 --convergence 1e-6 --final-iterations 20 --close)
[[ $(levels_of "$close" | head -1) == "4 "* ]] || fail "close coarsest shrink should be 4"

echo "pyramid_check: all checks passed"
echo "--- human T1 affine pyramid:"; tr -d '\\' <<<"$affine"
echo "--- human T1 SyN pyramid:"; tr -d '\\' <<<"$syn"
