using Oscar
using ProgressMeter

include("GMiMC.jl")

function evaluate_structure(gmimc::GMiMC,
                            a::Vector{FqFieldElem},
                            k::Int)
    #inputs = Vector{Vector{FqFieldElem}}()
    outputs = Vector{Vector{FqFieldElem}}()

    offset = [zero(gmimc.field) for _ in 1:gmimc.n]
    offset[1:gmimc.n - k] += a[1:gmimc.n - k]

    prod_iter = Base.product(ntuple(i -> gmimc.field, k)...)
    p = Progress(length(prod_iter); desc="Evaluating points in structure.")
    for el in prod_iter
        x_in = copy(offset)
        for j in 1:k
            x_in[gmimc.n - k + j] += el[j]
        end
        x_out = permutation(gmimc, x_in)
        #push!(inputs, x_in)
        push!(outputs, x_out)
        next!(p)
    end

    #return inputs, outputs
    return outputs
end

function number_of_collisions_in_structure(gmimc::GMiMC,
                                           a::Vector{FqFieldElem},
                                           k::Int)
    #_, outputs = evaluate_structure(gmimc, a, k)
    outputs = evaluate_structure(gmimc, a, k)
    result = find_prefix_collisions(outputs, gmimc.n - k)
    counts = count_unique_collisions(result)
    return counts.duplicates
end

function evaluate_structure_keyed(gmimc::GMiMC,
                                  a::Vector{FqFieldElem},
                                  k::Int,
                                  key::Vector{FqFieldElem})
    #inputs = Vector{Vector{FqFieldElem}}()
    outputs = Vector{Vector{FqFieldElem}}()

    offset = [zero(gmimc.field) for _ in 1:gmimc.n]
    offset[1:gmimc.n - k] += a[1:gmimc.n - k]

    prod_iter = Base.product(ntuple(i -> gmimc.field, k)...)
    #p = Progress(length(prod_iter); desc="Evaluating plaintexts in structure.")
    for el in prod_iter
        x_in = copy(offset)
        for j in 1:k
            x_in[gmimc.n - k + j] += el[j]
        end
        x_out = permutation(gmimc, x_in, key)
        #push!(inputs, x_in)
        push!(outputs, x_out)
        #next!(p)
    end

    #return inputs, outputs
    return outputs
end

function number_of_collisions_in_structure_keyed(gmimc::GMiMC,
                                                 a::Vector{FqFieldElem},
                                                 k::Int,
                                                 key::Vector{FqFieldElem})
    #_, outputs = evaluate_structure(gmimc, a, k)
    outputs = evaluate_structure_keyed(gmimc, a, k, key)
    result = find_prefix_collisions(outputs, gmimc.n - k)
    counts = count_unique_collisions(result)
    return counts.duplicates
end