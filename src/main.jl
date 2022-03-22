include("utilities.jl")

function main(isMultivariate::Bool=false)
    res = Vector{String}[]

    # Pour chaque jeu de données
    for dataSetName in ["iris", "seeds", "wine", "tic-tac-toe", "cmc"]
        
        print("=== Dataset ", dataSetName, isMultivariate ? " multivarié" : " univarié")

        # Préparation des données
        include("../data/" * dataSetName * ".txt") 

        train, test = train_test_indexes(length(Y))
        X_train = X[train, :]
        Y_train = Y[train]
        X_test = X[test, :]
        Y_test = Y[test]

        println(" (train size ", size(X_train, 1), ", test size ", size(X_test, 1), ", features count: ", size(X_train, 2), ")")
        
        # Temps limite de la méthode de résolution en secondes
        time_limit = 60

        # Pour chaque profondeur considérée
        for D in 2:4
            print("  D = ", D, "\t\t")
            
            ## 1 - Univarié (séparation sur une seule variable à la fois)
            # Création de l'arbre
            T, obj, resolution_time, gap = build_tree(X_train, Y_train, D,  multivariate = isMultivariate, time_limit = time_limit, mu=1e-4)

            # Test de la performance de l'arbre
            print(round(resolution_time, digits = 1), "s\t")
            print("gap ", round(gap, digits = 1), "%\t")

            if T != nothing
                print("Erreurs train/test ", prediction_errors(T,X_train,Y_train))
                print("/", prediction_errors(T,X_test,Y_test), "\t")
            end
            println()
            push!(res, [dataSetName, string(D), string(round(resolution_time, digits = 1)), string(round(gap, digits = 1)) * "\\%", string(prediction_errors(T,X_train,Y_train)), string(prediction_errors(T,X_test,Y_test)) ])
            
        end
    end 
    return res
end



#Ecris les résultats dans un fichier .tex
isMultivariate = true
include("building_tree.jl")
global res_classic = main(isMultivariate)
include("calback.jl")
global res_callback = main(isMultivariate)

rows = Vector{Vector{String}}(undef, size(res_classic,1))
lines = String[]
for i in 1:length(res_classic)
    if rem(i, 3) == 1
        rows[i] = vcat(["\\multirow{3}*{\\textbf{" * res_classic[i][1] * "}}"], res_classic[i][2:end], res_callback[i][3:end])
        push!(lines, "")
    else
        rows[i] = vcat([""], res_classic[i][2:end], res_callback[i][3:end])
        
        if rem(i, 3) == 0
            push!(lines, "\\hline")
        else
            push!(lines,"")
        end
    end
    
end

titles =    ["Instance", "D", "Classique",                             "Callback"]
subtitles = ["",         "",  "Temps", "GAP", "Erreurs",               "Temps", "GAP", "Erreurs" ]
subsubtitles = ["",      "",  "",      "",    "Train set", "Test set", "",      "",    "Train set", "Test set" ]
filename = isMultivariate ? "multivarie" : "univarie"
caption = isMultivariate ? "multivariée" : "univariée"
write_table_tex("../res/results_classic_" * filename, "Résultats sans regroupement et séparation " * caption, titles, rows, 
                subtitles=subtitles, subsubtitles = subsubtitles, num_col_titles = [1,1,4,4], num_col_sub = [1,1,1,1,2,1,1,2],
                alignment="|l|c|cccc|cccc|", lines = lines, maxRawsPerPage=54)

