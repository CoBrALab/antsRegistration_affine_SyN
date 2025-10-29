# antsRegistration_affine_SyN

A wrapper script around ANTs' `antsRegistration` tool that provides optimized registration pyramids for both affine and SyN (non-linear) transformations. This tool simplifies the process of image registration by providing sensible defaults and automatic parameter generation based on image properties.



## Features

- Combined affine and SyN (non-linear) registration in a single command
- Support for both MINC and NIFTI file formats
- Automatic generation of multi-resolution pyramids based on image properties

![SIFT Multi-octave pyramid](pyramid.png "SIFT Multi-octave pyramid")

- Support for multispectral registration
- Flexible initialization options (center of mass, center of volume, etc.)
- Optional masking and histogram matching
- Support for various linear transform types (rigid, similarity, affine)
- Configurable convergence criteria and iteration limits
- Optional fast registration mode for quicker results
- Support for float or double precision calculations

## Prerequisites

The following ANTs tools must be available in your PATH:
- `ImageMath`
- `ThresholdImage`
- `antsAI`
- `antsApplyTransforms`
- `antsRegistration`

## Usage

```bash
./antsRegistration_affine_SyN.sh [-h|--help] [options] <movingfile> <fixedfile> <outputbasename>
```
## Full command line help
```bash
A wrapper around antsRegistration providing optimized registration pyramids
Usage: ./antsRegistration_affine_SyN.sh [-h|--help] [--moving-mask <arg>] [--fixed-mask <arg>] [--(no-)mask-extract] [--(no-)keep-mask-after-extract] [-o|--resampled-output <arg>] [--resampled-linear-output <arg>] [--initial-transform <arg>] [--linear-type <LINEAR>] [--(no-)close] [--(no-)rough] [--fixed <arg>] [--moving <arg>] [--weights <arg>] [--convergence <arg>] [--(no-)skip-linear] [--linear-metric <arg>] [--linear-shrink-factors <arg>] [--linear-smoothing-sigmas <arg>] [--linear-convergence <arg>] [--final-iterations-linear <arg>] [--(no-)skip-nonlinear] [--syn-control <arg>] [--syn-metric <arg>] [--syn-shrink-factors <arg>] [--syn-smoothing-sigmas <arg>] [--syn-convergence <arg>] [--final-iterations-nonlinear <arg>] [--(no-)histogram-matching] [--winsorize-image-intensities <arg>] [--(no-)fast] [--(no-)float] [-c|--(no-)clobber] [-v|--(no-)verbose] [-d|--(no-)debug] <movingfile> <fixedfile> <outputbasename>
        <movingfile>: The moving image
        <fixedfile>: The fixed image
        <outputbasename>: The basename for the output transforms
        -h, --help: Prints help
        --moving-mask: Mask for moving image (default: 'NOMASK')
        --fixed-mask: Mask for fixed image (default: 'NOMASK')
        --mask-extract, --no-mask-extract: Use masks to extract input images, only works with both images masked (off by default)
        --keep-mask-after-extract, --no-keep-mask-after-extract: Keep using masks for metric after extraction (off by default)
        -o, --resampled-output: Output resampled file(s), repeat for resampling multispectral outputs (empty by default)
        --resampled-linear-output: Output resampled file(s) with only linear transform, repeat for resampling multispectral outputs (empty by default)
        --initial-transform: Initial moving transformation for registration. Can be one of: 'com-masks', 'com', 'cov', 'origin', 'none', or a transform filename, comma separated initalizations are applied like a stack, last in list first (default: 'com-masks')
        --linear-type: Type of linear transform. Can be one of: 'rigid', 'lsq6', 'similarity', 'lsq9', 'affine' and 'lsq12' (default: 'affine')
        --close, --no-close: Images are close in space and similarity, skip large scale pyramid search (off by default)
        --rough, --no-rough: Skip fine-resolution alignment, only perform rough parts of scale pyramid (off by default)
        --fixed: Additional fixed images for multispectral registration, pair with --moving in order (empty by default)
        --moving: Additional moving images for multispectral registration, pair with --fixed in order (empty by default)
        --weights: A single value, which disables weighting, or a comma separated list of weights, ordered primary pair, followed by multispectral pairs (default: '1')
        --convergence: Convergence stopping value for registration (default: '1e-6')
        --skip-linear, --no-skip-linear: Skip the linear registration stages (off by default)
        --linear-metric: Linear metric (default: 'Mattes')
        --linear-shrink-factors: Shrink factors for linear stage, provide to override automatic generation, must be provided with sigmas and convergence (no default)
        --linear-smoothing-sigmas: Smoothing sigmas for linear stage, provide to override automatic generation, must be provided with shrinks and convergence (no default)
        --linear-convergence: Convergence levels for linear stage, provide to override automatic generation, must be provided with shrinks and sigmas (no default)
        --final-iterations-linear: Maximum iterations at finest scale for linear automatic generation (default: '50')
        --skip-nonlinear, --no-skip-nonlinear: Skip the nonlinear stage (off by default)
        --syn-control: Non-linear (SyN) gradient and regularization parameters, not checked for correctness (default: '0.4,4,0')
        --syn-metric: Non-linear (SyN) metric and radius or bins, choose Mattes[32] for faster registrations (default: 'CC[4]')
        --syn-shrink-factors: Shrink factors for Non-linear (SyN) stage, provide to override automatic generation, must be provided with sigmas and convergence (no default)
        --syn-smoothing-sigmas: Smoothing sigmas for Non-linear (SyN) stage, provide to override automatic generation, must be provided with shrinks and convergence (no default)
        --syn-convergence: Convergence levels for Non-linear (SyN) stage, provide to override automatic generation, must be provided with shrinks and sigmas (no default)
        --final-iterations-nonlinear: Maximum iterations at finest scale for non-linear automatic generation (default: '20')
        --histogram-matching, --no-histogram-matching: Enable histogram matching (off by default)
        --winsorize-image-intensities: Winsorize data based on specified quantiles, comma separated lower,upper (no default)
        --fast, --no-fast: Run fast SyN registration, overrides syn-metric above with Mattes[32] (off by default)
        --float, --no-float: Calculate registration using float instead of double (off by default)
        -c, --clobber, --no-clobber: Overwrite files that already exist (off by default)
        -v, --verbose, --no-verbose: Run commands verbosely (on by default)
        -d, --debug, --no-debug: Show all internal commands and logic for debug (off by default)
```

### Required Arguments

- `<movingfile>`: The moving image (image to be transformed)
- `<fixedfile>`: The fixed image (target image)
- `<outputbasename>`: Base name for output transform files

### Key Optional Arguments

- `--moving-mask <arg>`: Mask for moving image (default: NOMASK)
- `--fixed-mask <arg>`: Mask for fixed image (default: NOMASK)
- `--initial-transform <arg>`: Initial transform type or file (options: 'com-masks', 'com', 'cov', 'origin', 'none', or transform filename)
- `--linear-type <type>`: Type of linear transform (options: rigid, lsq6, similarity, lsq9, affine, lsq12)
- `--resampled-output`: Output resampled file(s)
- `--fast`: Run fast SyN registration using Mattes similarity metric
- `--close`: For images close in space and similarity
- `--rough`: Skip fine-resolution alignment
- `-c|--clobber`: Overwrite existing files
- `-v|--verbose`: Run commands verbosely

### Advanced Options

- `--convergence`: Convergence stopping value
- `--histogram-matching`: Enable histogram matching
- `--winsorize-image-intensities`: Winsorize data based on quantiles
- `--float`: Use float instead of double precision
- Multiple options for controlling linear and non-linear registration parameters

### Multispectral Registration

The script supports registration of multiple image pairs simultaneously:
- Use `--fixed` and `--moving` to specify additional image pairs
- Use `--weights` to specify the relative weight of each image pair

## Outputs

The script generates several output files:
- `<outputbasename>0GenericAffine.mat` (or `0_GenericAffine.xfm` for MINC): The affine transformation
- `<outputbasename>1Warp.nii.gz` (or `1_NL.xfm` for MINC): The non-linear transformation
- Additional resampled outputs if requested

## Examples

Basic affine and SyN registration:
```bash
./antsRegistration_affine_SyN.sh moving.nii.gz fixed.nii.gz output_
```

Fast registration with masks:
```bash
./antsRegistration_affine_SyN.sh --fast --moving-mask moving_mask.nii.gz --fixed-mask fixed_mask.nii.gz moving.nii.gz fixed.nii.gz output_
```

Multispectral registration:
```bash
./antsRegistration_affine_SyN.sh --moving additional_moving.nii.gz --fixed additional_fixed.nii.gz --weights 1,0.5 moving.nii.gz fixed.nii.gz output_
```
