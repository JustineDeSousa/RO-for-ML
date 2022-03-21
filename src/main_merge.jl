
include("utilities.jl")
include("merge.jl")


function main_merge()
    res = Vector{String}[]

    for dataSetName in ["iris"]#, "seeds", "wine", "tic-tac-toe", "cmc"]
            
        print("=== Dataset ", dataSetName)
        
        # Préparation des données
        include("../data/" * dataSetName * ".txt") 
        train, test = train_test_indexes(length(Y))
        X_train = X[train,:]
        Y_train = Y[train]
        X_test = X[test,:]
        Y_test = Y[test]

        println(" (train size ", size(X_train, 1), ", test size ", size(X_test, 1), ", features count: ", size(X_train, 2), ")")
        
        # Temps limite de la méthode de résolution en secondes        
        time_limit = 10

        for D in 2:4
            println("\tD = ", D)

            println("\t\tUnivarié")
            res_uni = testMerge(X_train, Y_train, X_test, Y_test, D, time_limit = time_limit, isMultivariate = false)

            for i in 1:length(res_uni)
                push!(res, vcat([dataSetName, string(D), "Univarié" ], string.(res_uni[i])))
            end

            # println("\t\tMultivarié")
            # res_multi = testMerge(X_train, Y_train, X_test, Y_test, D, time_limit = time_limit, isMultivariate = true)

            # for i in 1:length(res_uni)
            #     push!(res, vcat([dataSetName, string(D), "Multivarié" ], string.(res_multi[i])))
            # end
        end
    end
    return res
end 

function testMerge(X_train, Y_train, X_test, Y_test, D; time_limit::Int=-1, isMultivariate::Bool = false)
    
    res = []

    # Pour tout pourcentage de regroupement considéré
    println("\t\t\tGamma\t\t# clusters\tGap")
    for gamma in 0:0.2:1
        print("\t\t\t", gamma * 100, "%\t\t")
        clusters = simpleMerge(X_train, Y_train, gamma)
        print(length(clusters), " clusters\t")
        T, obj, resolution_time, gap = build_tree(clusters, D, multivariate = isMultivariate, time_limit = time_limit)
        print(round(gap, digits = 1), "%\t") 
        print("Erreurs train/test : ", prediction_errors(T,X_train,Y_train))
        print("/", prediction_errors(T,X_test,Y_test), "\t")
        println(round(resolution_time, digits=1), "s")
        
        push!(res, [gamma, length(clusters), round(resolution_time, digits=1), string(round(gap, digits = 1))*"\\%", prediction_errors(T,X_train,Y_train), prediction_errors(T,X_test,Y_test)])
    end
    println()

    return res
end 

include("building_tree.jl")
res_classic = main_merge()
include("calback.jl")
res_callback = main_merge()


rows_univarie = Vector{String}[]
lines_univarie = String[]
for i in 1:length(res_classic)
    if rem(i, 6) == 1
        rows[i][3] = "\\multirow{6}*{" * res[i][3] * "}"
        if rem(i, 12) == 1
            rows[i][2] = "\\multirow{12}*{" * string(res[i][2]) * "}"
            if rem(i, 36) == 1
                rows[i][1] = "\\multirow{36}*{\\textbf{" * res[i][1] * "}}"
            else
                rows[i][1] = ""
            end
        else
            rows[i][1:2] = ["",""]
        end
        push!(lines, "")
    else
        rows[i][1:3] = ["","",""]
        if rem(i, 6) == 0
            if rem(i, 12) == 0
                if rem(i, 36) == 0
                    push!(lines, "\\hline")
                else
                    push!(lines, "\\cline{2-9}")
                end
            else
                push!(lines, "\\cline{3-9}")
            end
        else
            push!(lines,"")
        end
    end
       
end

titles = ["Instance", "D", "Séparation", "\$\\gamma\$", "nb clusters", "Temps", "GAP", "Erreurs"]
subtitles = ["", "", "", "", "", "", "", "Train set", "Test set"]
write_table_tex("../res/results_merge", "Résultats avec regroupements", titles, rows, 
                subtitles=subtitles, num_col_titles = [1,1,1,1,1,1,1,2], alignment="|l|c|lcccccc|", lines = lines,
                maxRawsPerPage=60)