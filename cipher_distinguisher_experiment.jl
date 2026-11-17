using CSV
using DataFrames
using Oscar
using ProgressMeter

include("GMiMC.jl")
include("prefix_collisions.jl")
include("differential_structure.jl")


p = parse(Int, ARGS[1])
n = parse(Int, ARGS[2])
max_blocks = parse(Int, ARGS[3])
max_d = parse(Int, ARGS[4])

seed = get(ARGS, 5, 13)
if typeof(seed) == String 
    seed = parse(Int, seed)
end


function main()
    sep_1 = repeat("-", 50)
    sep_2 = repeat("+", 50)

    Oscar.Random.seed!(seed)

    println("GMiMC Distinguisher Experiment.")
    println("RNG seed: ", seed)

    field = GF(p)
    constants = [rand(field) for _ in 1:(n * max_blocks)]

    ######################################
    key = [rand(field) for _ in 1:n]
    key_mat = rand(matrix_space(field, n, n))

    num_structures = 2 * ceil(p^(maximum([0, n - 7])))

    println("GMiMC Parameters.")
    println("Field: ", field)
    println("n: ", n)
    println("max_blocks: ", max_blocks)
    println("constants: ", constants)
    println("max_d: ", max_d)
    println("key: ", key)
    println("key matrix:\n", key_mat)
    println("number of structures: ", num_structures)
    println(sep_2)

    column_names = ["blocks"; ["d_$i" for i in 2:max_d]]
    df = DataFrame([Int[] for _ in column_names], Symbol.(column_names))
    append!(df[!, Symbol("blocks")], 1:max_blocks)

    for d in 2:max_d
        println("d: ", d)
        for blocks in 1:max_blocks
            gmimc = GMiMC_constructor(field=field, d=d, n=n, rounds=blocks * n, constants=constants, key_mat=key_mat, info_level=0)
            prod_iter = Base.product(ntuple(i -> gmimc.field, n - 2)...)
            n_cols = 0
            P = Progress(num_structures, desc="Evaluating plaintexts in structures.")
            for a in Iterators.take(prod_iter, num_structures)
                n_cols += number_of_collisions_in_structure_keyed(gmimc, collect(a), 2, key)
                next!(P)
            end
            println("(blocks, n_cols, log_2(n_cols)): " * string((blocks, n_cols, log(2, n_cols))))
            push!(df[!, Symbol("d_$d")], n_cols)
        end
        println(sep_1)
    end

    file_name = "data_cipher" * "_p" * string(p)
    file_name *= "_n" * string(n)
    file_name *= "_b" * string(max_blocks)
    file_name *= ".csv"
    CSV.write(file_name, df)
end

main()
