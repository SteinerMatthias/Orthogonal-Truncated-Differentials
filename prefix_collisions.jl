using Oscar
using ProgressMeter

function find_prefix_collisions(list_of_vectors::Vector{Vector{FqFieldElem}}, k::Int64)
    # Dictionary to group vectors by their first k elements
    groups = Dict{Vector{FqFieldElem}, Vector{Int}}()
    
    # Group indices by the prefix
    p = Progress(length(list_of_vectors); desc="Searching prefix collisions.")
    for (idx, vec) in enumerate(list_of_vectors)
        prefix = vec[1:k]
        if haskey(groups, prefix)
            push!(groups[prefix], idx)
        else
            groups[prefix] = [idx]
        end
        next!(p)
    end
    
    # Filter out prefixes that only appeared once (no collision)
    collisions = filter(pair -> length(pair.second) > 1, groups)
    
    return collisions
end

function count_unique_collisions(collisions::Dict{Vector{FqFieldElem}, Vector{Int}})
    # Definition A: The number of distinct prefixes that cause a collision
    num_colliding_prefixes = length(collisions)
    
    # Definition B: The total number of extra (duplicate) vectors 
    # (e.g., if 3 vectors share a prefix, that counts as 2 collisions)
    total_duplicate_count = 0
    p = Progress(length(collisions); desc="Counting prefix collisions.")
    for (_, indices) in collisions
        total_duplicate_count += (length(indices) - 1)
        next!(p)
    end
    
    return (prefixes = num_colliding_prefixes, duplicates = total_duplicate_count)
end
