include("building_tree.jl")
# include("calback.jl")
include("utilities.jl")

function main()
    rows = Vector{String}[]
    lines = String[]

    # Pour chaque jeu de données
    for dataSetName in ["iris", "seeds", "wine", "tic-tac-toe", "cmc"]
        
        print("=== Dataset ", dataSetName)

        # Préparation des données
        include("../data/" * dataSetName * ".txt") 

        train, test = train_test_indexes(length(Y))
        X_train = X[train, :]
        Y_train = Y[train]
        X_test = X[test, :]
        Y_test = Y[test]

        println(" (train size ", size(X_train, 1), ", test size ", size(X_test, 1), ", features count: ", size(X_train, 2), ")")
        
        # Temps limite de la méthode de résolution en secondes
        time_limit = 30

        # Pour chaque profondeur considérée
        for D in 2:4
            println("  D = ", D)
            if D == 2
                line = String["\\multirow{6}*{\\textbf{" *dataSetName*"}}", "\\multirow{2}*{" * string(D) * "}"]
            else
                line = String["", "\\multirow{2}*{" * string(D) * "}"]
            end
            
            ## 1 - Univarié (séparation sur une seule variable à la fois)
            # Création de l'arbre
            print("    Univarié...  \t")
            push!(line, "Univarié")
            T, obj, resolution_time, gap = build_tree(X_train, Y_train, D,  multivariate = false, time_limit = time_limit)

            # Test de la performance de l'arbre
            print(round(resolution_time, digits = 1), "s\t")
            push!(line, string(round(resolution_time, digits = 1)))

            print("gap ", round(gap, digits = 1), "%\t")
            push!(line, string(round(gap, digits = 1)) * "\\%")

            if T != nothing
                print("Erreurs train/test ", prediction_errors(T,X_train,Y_train))
                print("/", prediction_errors(T,X_test,Y_test), "\t")
                push!(line, string(prediction_errors(T,X_train,Y_train)))
                push!(line, string(prediction_errors(T,X_test,Y_test)))
            end
            println()
            push!(rows, line)
            push!(lines, "")

            ## 2 - Multivarié
            print("    Multivarié...\t")
            line = String["", "", "Mulivarié"]
            T, obj, resolution_time, gap = build_tree(X_train, Y_train, D, multivariate = true, time_limit = time_limit)
            
            print(round(resolution_time, digits = 1), "s\t")
            print("gap ", round(gap, digits = 1), "%\t")
            push!(line, string(round(resolution_time, digits = 1)))
            push!(line, string(round(gap, digits = 1)))
            
            if T != nothing
                print("Erreurs train/test ", prediction_errors(T,X_train,Y_train))
                print("/", prediction_errors(T,X_test,Y_test), "\t")
                push!(line, string(prediction_errors(T,X_train,Y_train)))
                push!(line, string(prediction_errors(T,X_test,Y_test)))
            end
            println("\n")
            push!(rows, line)
            if D == 4
                push!(lines, "\\hline")
            else
                push!(lines, "\\cline{2-7}")
            end
        end
    end 
    return rows, lines
end



rows, lines = main()
titles = ["Instance", "D", "Séparation", "Temps", "GAP", "Erreurs"]
subtitles = ["", "", "", "", "", "Train set", "Test set"]
write_table_tex("../res/results_classic", "Résultats sans regroupement", titles, rows, 
                subtitles=subtitles, num_col_titles = [1,1,1,1,1,2], alignment="l|c|lcccc", lines=lines)