using Random
using DelimitedFiles
include("struct/tree.jl")


function lecture_instances()
    mat = readdlm("../data/tic-tac-toe.data")
    dic = Dict{String,Int}("positive" => 1, "negative" => 2)
    y = [ dic[split(mat[i], ",")[end]]      for i in 1:length(mat) ]
    dic = Dict{String,Float64}("x" => 0.5, "o" => 1., "b" => 0.)
    x = reshape([ dic[ split(mat[i], ",")[1:end-1][j] ] for j in 1:9 for i in 1:length(mat) ], (length(mat),9))
    centerAndSaveDataSet(x, y, "../data/tic-tac-toe.txt")

    mat = readdlm("../data/cmc.data")
    y = [ parse.(Int, split(mat[i], ",")[end] )     for i in 1:length(mat) ]
    x = hcat([parse.(Int, split(mat[i], ",")[1:end-1]) for i in 1:length(mat) ]...)'
    centerAndSaveDataSet(x, y, "../data/cmc.txt")
end

"""
Création de deux listes d'indices pour les jeux de données d'entrainement et de test
Entrées :\n
    - n le nombre de données dans le dataset
    - p la proportion que représente le jeu de données test
Sorties :\n
    - train, la liste des indices des données d'entrainement
    - test, la liste des indices des données de tesr
"""
function train_test_indexes(n::Int64,p::Float64=0.2)

    # Fixe la graine aléatoire pour assurer la reproductibilité
    Random.seed!(1)
    rd = randperm(n)

    test = rd[1:ceil(Int,n*p)]
    train = rd[ceil(Int,n*p)+1:n]

    return train,test
end

"""
Retourne le nombre d'erreurs de prédiction d'un arbre pour un ensemble de données

Entrées :
- T : l'arbre
- x : les données à prédire
- y : la classe des données

Sortie :
- class::Vector{Int64} : class prédites (class[i] est la classe de la donnée x[i, :])
"""
function prediction_errors(T::Tree, x::Matrix{Float64}, y::Vector{Int64})
    dataCount = length(x[:, 1])
    featuresCount = length(x[1, :])
    
    errors = 0
    
    for i in 1:dataCount
        t = 1
        for d in 1:(T.D+1)
            if T.c[t] != -1
                errors += T.c[t] != y[i]
                break
            else
                if sum(T.a[j, t]*x[i, j] for j in 1:featuresCount) - T.b[t] < 0
                    t = t*2
                else
                    t = t*2 + 1
                end
            end
        end
    end
    return errors
end

"""
Retourne la prédiction d'un arbre pour un ensemble de données

Entrées :
- T : l'arbre
- x : les données à prédire

Sortie :
- class::Vector{Int64} : class prédites (class[i] est la classe de la donnée x[i, :])
"""
function predict_class(T::Tree, x::Matrix{Float64})
    dataCount = length(x[:, 1])
    featuresCount = length(x[1, :])
    class = zeros(Int64, dataCount)
    
    for i in 1:dataCount
        t = 1
        for d in 1:(T.D+1)
            if T.c[t] != -1
                class[i] = T.c[t]
                break
            else
                if sum(T.a[j, t]*x[i, j] for j in 1:featuresCount) - T.b[t] < 0
                    t = t*2
                else
                    t = t*2 + 1
                end
            end
        end
    end
    return class
end


"""
Change l'échelle des caractéristiques d'un dataset pour les situer dans [0, 1]

Entrée :
- X: les caractéristiques du dataset d'origine

Sortie :
- caractéristiques entre 0 et 1
"""
function centerData(X)

    result = Matrix{Float64}(X)

    # Pour chaque caractéristique
    for j in 1:size(result, 2)
        
        m = minimum(result[:, j])
        M = maximum(result[:, j])
        result[:, j] .-= m
        result[:, j] ./= M
    end

    return result
end

function centerAndSaveDataSet(X, Y::Vector{Int64}, outputFile::String)
    
    centeredX = centerData(X)

    open(outputFile, "w") do fout
        println(fout, "X = ", centeredX)
        println(fout, "Y = ", Y)
    end    
end 


"""
Write a table in a .tex file
Input:
    - output = filename of the output file
    - caption = caption of the table
    - titles = header of the table
        - num_col_titles = number of cols for each title
    - subtitles = subheader of the table
        - num_col_sub = number of cols for each subtitle
"""
function write_table_tex(output::String, caption::String, titles::Array{String}, rows::Vector{Vector{String}};
    subtitles::Array{String}=String[], subsubtitles::Array{String}=String[], 
    num_col_titles::Array{Int}=ones(Int,length(titles)), num_col_sub::Array{Int}=ones(Int,length(subtitles)),
    alignment::String="c"^sum(num_col_titles), lines::Array{String}=fill("",length(rows)), maxRawsPerPage::Int=50 )

    fout = open(output * ".tex", "w")

    println(fout, raw"""\documentclass[main.tex]{subfiles}
\newmargin{2cm}{2cm}
\setlength{\voffset}{-1.5cm}
\begin{document}
\thispagestyle{empty}
""")

    #HEADER OF TABLE
    header = raw"""
\begin{table}
    \centering
    \caption{"""
    header *= caption
    header *= raw"""
}
    \begin{tabular}{
    """

    header *= alignment * "}\n\\hline\t\n\t"

    for i in 1:length(titles)
        if num_col_titles[i] > 1
            header *= "\\multicolumn{" * string(num_col_titles[i]) * "}{c}{"
        end
        header *= "\\textbf{" * titles[i] * "}"
        if num_col_titles[i] > 1
            header *= "}"
        end
        if i < length(titles)
            header *= " &"
        end
    end
    header *= "\\\\\n\t\\hline\n"

    #SUBHEADERS
    subheader = "\n\t"
    if length(subtitles) > 0
        for i in 1:length(subtitles)
            if num_col_sub[i] > 1
                subheader *= "\\multicolumn{" * string(num_col_sub[i]) * "}{c}{"
            end
            subheader *= subtitles[i]
            if num_col_sub[i] > 1
                subheader *= "}"
            end
            if i < length(subtitles)
                subheader *= " &"
            end
        end
        subheader *= "\\\\\n\t"
    end

    #SUBSUBHEADERS
    subsubheader = "\n\t"
    if length(subsubtitles) > 0
        for i in 1:length(subsubtitles)
            subsubheader *= subsubtitles[i]
            
            if i < length(subsubtitles)
                subsubheader *= " &"
            end
        end
        subsubheader *= "\\\\\n\t\\hline\n"
    end

    #FOOTER OF TABLES
    footer = raw"""
    \end{tabular}
\end{table}
"""

    print(fout, header)
    println(fout, subheader)
    println(fout, subsubheader)

    id = 1

    #CONTENT
    for j in 1:length(rows)
        for i in 1:length(rows[j])
            print(fout, rows[j][i])
            if i < length(rows[j])
                print(fout, " &")
            end
        end
        
        println(fout, "\\\\" * lines[j])
        
        
        #If we need to start a new page
        if rem(id, maxRawsPerPage) == 0
            println(fout, footer, "\\newpage\n\\thispagestyle{empty}")
            println(fout, header)
            println(fout, subheader)
            println(fout, subsubheader)
        end
        id += 1
    end
    
    println(fout, footer)
    println(fout, "\\end{document}")
    close(fout)
end