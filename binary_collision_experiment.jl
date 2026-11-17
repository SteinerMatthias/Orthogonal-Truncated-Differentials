using CSV
using DataFrames
using Oscar

include("GMiMC.jl")
include("prefix_collisions.jl")
include("differential_structure.jl")


m = parse(Int, ARGS[1])
n = parse(Int, ARGS[2])
max_blocks = parse(Int, ARGS[3])
max_k = parse(Int, ARGS[4])
max_d = parse(Int, ARGS[5])

seed = get(ARGS, 6, 13)
if typeof(seed) == String 
    seed = parse(Int, seed)
end


function main()
    sep_1 = repeat("-", 50)
    sep_2 = repeat("+", 50)
    sep_3 = repeat("=", 50)

    Oscar.Random.seed!(seed)

    println("GMiMC Collision Experiment.")
    println("RNG seed: ", seed)

    field = GF(2^m)
    constants = [rand(field) for _ in 1:(n * max_blocks)]

    ######################################
    a = [zero(field) for _ in 1:n]

    println("GMiMC Parameters.")
    println("Field: ", field)
    println("n: ", n)
    println("max_blocks: ", max_blocks)
    println("constants: ", constants)
    println("max_k: ", max_k)
    println("max_d: ", max_d)
    println("a: ", a)
    println(sep_3)

    for k in 2:max_k
        println("k: ", k)
        column_names = ["blocks"; ["d_$i" for i in 2:max_d if mod(i, 2) == 1]]
        df = DataFrame([Int[] for _ in column_names], Symbol.(column_names))
        append!(df[!, Symbol("blocks")], 1:max_blocks)
        for d in 2:max_d
            if mod(d, 2) == 1
                println("d: ", d)
                for blocks in 1:max_blocks
                    gmimc = GMiMC_constructor(field=field, d=d, n=n, rounds=blocks * n, constants=constants, info_level=0)
                    n_cols = number_of_collisions_in_structure(gmimc, a, k)
                    println("(blocks, n_cols, log_2(n_cols)): " * string((blocks, n_cols, log(2, n_cols))))
                    push!(df[!, Symbol("d_$d")], n_cols)
                end
                println(sep_1)
            end
        end
        println(sep_2)
        file_name = "data_hash" * "_m" * string(m)
        file_name *= "_n" * string(n)
        file_name *= "_k" * string(k)
        file_name *= "_a0"
        file_name *= ".csv"
        CSV.write(file_name, df)
    end
end

main()
