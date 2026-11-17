# GMiMC Collision Experiments
This repository contains the small scale collision experiments of [GMiMC_erf](https://doi.org/10.1007/978-3-030-29962-0_8) for the paper `Orthogonal Truncated Differentials`.

## Requirements
GMiMC and the experiments are implemented in the computer algebra system [OSCAR](https://www.oscar-system.org/).
[Julia](https://julialang.org/) language must be installed on the system, then add the following packages:
```julia
using Pkg
Pkg.add("CSV")
Pkg.add("DataFrames")
Pkg.add("ProgressMeter")
Pkg.add("Oscar")
```

## Collision Experiment
To run the collision experiment for the truncated differential $(0, \dots, 0, x_1, \dots, x_k) \to (0, \dots, 0, y_1, \dots, y_k)$ of GMiMC_erf run the following command within the repository
```shell
julia collision_experiment.jl $prime $n $max_blocks $k $max_d $seed
```
where `$prime` is the underlying prime field $\text{GF} (p)$, `$n` the state size, `$max_blocks` specifies the maximal number of rounds $b_{\max} \cdot n$, $k$ specifies the size of the truncated differential, `$max_d` specifies the interval exponent $[2, d_{\max}]$, and `$seed` the optional seed with default value $13$.

For experiments over a binary field run
```shell
julia binary_collision_experiment.jl $m $n $max_blocks $k $max_d $seed
```
where `$m` specifies the size of the finite field $\text{GF} (2^m)$.

To reproduce the data for the plots in the paper run the following
```sh
julia collision_experiment.jl 29 8 10 2 8
julia collision_experiment.jl 29 10 10 3 8
julia collision_experiment.jl 29 12 10 4 8
julia collision_experiment.jl 29 14 10 4 8

julia collision_experiment.jl 59 8 10 2 8
julia collision_experiment.jl 59 10 10 3 8
julia collision_experiment.jl 59 12 10 4 8
julia collision_experiment.jl 59 14 10 3 8

julia collision_experiment.jl 127 10 10 3 8

julia binary_collision_experiment.jl 5 8 10 2 8
julia binary_collision_experiment.jl 5 10 10 3 8
julia binary_collision_experiment.jl 5 12 10 4 8
julia binary_collision_experiment.jl 5 14 10 4 8

julia binary_collision_experiment.jl 6 8 10 2 8
julia binary_collision_experiment.jl 6 10 10 3 8
julia binary_collision_experiment.jl 6 12 10 4 8
julia binary_collision_experiment.jl 6 14 10 3 8

julia binary_collision_experiment.jl 7 10 10 3 8
```

## Cipher Distinguisher Experiment
To run the cipher distinguisher experiment for the truncated differential $(0, \dots, 0, x_1, \dots, x_k) \to (0, \dots, 0, y_1, \dots, y_k)$ of GMiMC_erf run the following command within the repository
```sh
julia cipher_distinguisher_experiment.jl $prime $n $max_blocks $max_d $seed
```
where `$prime` is the underlying prime field $\text{GF} (p)$, `$n` the state size, `$max_blocks` specifies the maximal number of rounds $b_{\max} \cdot n$, `$max_d` specifies the interval exponent $[2, d_{\max}]$, and `$seed` the optional seed with default value $13$.

To reproduce the data for the plots in the paper run the following
```sh
julia cipher_distinguisher_experiment.jl 59 7 7 8
julia cipher_distinguisher_experiment.jl 59 8 8 8

julia cipher_distinguisher_experiment.jl 127 7 7 8

julia binary_cipher_distinguisher_experiment.jl 6 7 7 8
julia binary_cipher_distinguisher_experiment.jl 6 8 8 8

julia binary_cipher_distinguisher_experiment.jl 7 7 7 8
```
