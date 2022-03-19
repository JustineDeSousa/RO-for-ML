include("building_tree.jl")

""" Local Search algorithm"""
function local_search(T::Tree, X::Matrix{Float64}, Y::Vector{Int})
    do 
        error_prev = loss(T, X, Y)
        for t in 1:length(T.c) #To shuffle
            # I = [i tq x_i assigned to leaf in T_t]
            # T_t = OptimizeNodeParallel(T_t, X[I], Y[I])
        end
    while true
    end
end

function OptimizeNodeParallel(T::Tree, X, Y)
    if isabranch(T)
        T_lower, T_upper = children(T)
    else
        
end

"""  subtree rooted at the 𝑡th node of a tree T"""
function T_root_t(T::Tree, t)

end

""" randomises the order of the indexes in A """
function shuffle(A)

end

""" retourne les indices des noeuds de T """
function nodes(T::Tree)

end

""" 
retourne deux arbres:
    - celui dont la racine est le fils gauche de la racine de T 
    - celui dont la racine est le fils droit de la racine de T 
"""   
function children(T::Tree)

end

"""
Retourne le minimum de points contenus dans une feuille de T sur les datas X,Y
"""
function minleafsize(T, X, Y)

end

"""
Evalue la fonction de cout de l'arbre T sur les données X,Y après la prédiction
"""
function loss(T,X,Y)

end