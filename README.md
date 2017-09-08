# image_processing
Processing implementation of image processing

## Interface

Very basic command-line style interface.

- `q` - quit
- `l` - load image by filename
- `[`, `]` - select left/right among operators
- `L`
- `LF`
- `L`E
- `LEA` - eye finder
- `d` - display
- `a` - add operator
- `r` - remove operator
- `e` - quick channel
- `E` - quick channel substitution
- `b` - bitplane selection
- `B` - bitwise substitution
- `c` - compute?
- `z` - auto-zoom
- `ls` - list directory
- `p` - print
- `pp` - print palette
- `M` - macros


### Macros 

1. `a laplace 2` `]` `a + 0` `[` `a sobel` `]]]` `a 5x5` `]` `a * 2` `]` `a + 0` `]` `a scale` `]` `a gamma 0.4 -0.1`
2. `a bitplane 7` `]` `a gamma 0.4 0.0` `]` `a + 0` `]` `a sobel` `]` `a * 3` `]` `a / 0` `]` `a scale` `]` `a gamma 0.4 0.0`
3. `a bitplane 7` `a bitplane 6` `a bitplane 5` `a bitplane 4` `a bitplane 3` `a bitplane 2` `a bitplane 1` `a bitplane 0`
4. `a bitplane 7` `a bitplane 6` `]]` `a gamma 1.0 -0.5` `]` `a + 1` `]` `[[[[` `a - 4` `]]]]]` `a clip` `[[[[[` `a - 6` `a * 7` `]]]]]]]]` `a scale` `]`
5. `a hist` `a gamma 0.4 0.0` `]]` `a hist` `[[` `a equal` `]]]]` `a hist`
23. `L truck_rear.pgm` `]` `a edgelocal` `]` `a athresh 70 30` `]` `e 0` `e 1` `]` `a hgap` `]` `a vgap` `]]` `a + 5`
24. `L fingerprint.pgm` `]` `a hist` `a gthresh`
25. `L noise.pgm` `]` `a nhist`
26. `L noisy.pgm` `]` `a gmean` `a amean`


### Operators

- `hist` - Histogram
- `nhist` - Noise Histogram
- `+`, `-`, `*`, `/` - Arithmetic operators
- `neg` - Negation (inverse)
- `gamma` - Gamma adjustment
- `thresh` - Thresholding
- `equal` - Histogram Equalization
- `filter` - Default filter
- `sharp` - Unsharp masking
- `median` - Median
- `laplace` - Laplacian
- `sobel` - Sobel filter
- `prewitt` - Prewitt filter
- `5x5` - 5x5 filter
- `gauss` - Gaussian blur
- `scale` - Resize image
- `clip` - Hard limiting
- `ch` - Channel selection
- `hsi` - Convert RGB to HSI
- `rgb` - Convert HSI to RGB
- `dft` - Discrete Fourier Transform
- `edgelocal` - Edge Localization
- `hgap`
- `vgap`
- `athresh`
- `gthresh` - Local Thresholding
- `gmean` - Geometric Mean
- `amean` - Arithmetic Mean
- `eye` - Eye Finder v2
- `rowsum` - Sum value of each row
- `colsum` - Sum value of each column
- `eyecrop` - Crop based on 
- `sumxy` - Plaid transform (custom)
