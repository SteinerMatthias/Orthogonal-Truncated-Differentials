using Oscar

struct GMiMC
    field::FqField
    n::Int64
    d::Int64
    rounds::Int64
    constants::Vector{FqFieldElem}
    key_mat::FqMatrix
end

function GMiMC_constructor(;field=GF(2^31 - 1),
                            n=16,
                            d=8,
                            rounds=16,
                            constants=nothing,
                            key_mat=nothing,
                            info_level=1)
    if isnothing(constants)
        constants = [rand(field) for _ in 1:rounds]
    end
    constants = map(field, constants)

    if isnothing(key_mat)
        key_mat = rand(matrix_space(field, n, n))
    end
    key_mat = matrix(field, key_mat)

    if info_level > 0
        println("GMiMC Parameters")
        println("Field: ", field)
        println("n: ", n)
        println("d: ", d)
        println("Rounds: ", rounds)
        println("Constants:\n", constants)
        println("Key schedule matrix:\n", key_mat)
    end

    return GMiMC(field, n, d, rounds, constants, key_mat)
end

function feistel(gmimc::GMiMC, 
                 x_in::Vector{R},
                 key::R,
                 constant::FqFieldElem) where R <: RingElem
    pow = (x_in[1] + key + constant)^gmimc.d
    x_out = deepcopy(x_in)
    for i in 2:gmimc.n
        x_out[i] += pow
    end

    return x_out
end

function permute(x_in::Vector{R}) where R <: RingElem
    return circshift(x_in, -1)
end

function round_function(gmimc::GMiMC, 
                        x_in::Vector{R},
                        key::R,
                        constant::FqFieldElem) where R <: RingElem
    x_out = feistel(gmimc, x_in, key, constant)
    x_out = permute(x_out)
    return x_out
end

function permutation(gmimc::GMiMC,
                     x_in::Vector{R}) where R <: RingElem
    x_out = deepcopy(x_in)
    for r in 1:gmimc.rounds
        x_out = round_function(gmimc, x_out, zero(gmimc.field), gmimc.constants[r])
    end
    return x_out
end

function permutation(gmimc::GMiMC,
                     x_in::Vector{R},
                     key::Vector{R}) where R <: RingElem
    keys = deepcopy(key)
    for _ in 1:Int64(ceil(((gmimc.rounds - 1) / gmimc.n)))
        key = gmimc.key_mat * key
        keys = [keys; key]
    end
    x_out = deepcopy(x_in)
    for r in 1:gmimc.rounds
        x_out = round_function(gmimc, x_out, keys[r], gmimc.constants[r])
    end
    return x_out
end
