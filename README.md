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
