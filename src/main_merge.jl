
include("utilities.jl")
include("merge.jl")


function main_merge(isMultivariate::Bool = false)
    res = Vector{String}[]

    for dataSetName in ["iris", "seeds", "wine", "tic-tac-toe", "cmc"]
            
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

            # println("\t\tUnivarié")
            res_merge = testMerge(X_train, Y_train, X_test, Y_test, D, time_limit = time_limit, isMultivariate = isMultivariate)

            for i in 1:length(res_merge)
                push!(res, vcat([dataSetName, string(D) ], string.(res_merge[i])))
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
        
        push!(res, [length(clusters), round(resolution_time, digits=1), string(round(gap, digits = 1))*"\\%", prediction_errors(T,X_train,Y_train), prediction_errors(T,X_test,Y_test)])
    end
    println()

    return res
end 


"""
Ecris les résultats dans un fichier .tex
"""
function save_results(isMultivariate::Bool=false)
    include("building_tree.jl")
    res_classic = main_merge(isMultivariate)
    include("calback.jl")
    res_callback = main_merge(isMultivariate)

    rows = Vector{Vector{String}}(undef, size(res_classic,1))
    lines = String[]
    for i in 1:length(res_classic)
        if rem(i, 6) == 1
            if rem(i, 18) == 1
                rows[i] = vcat(["\\multirow{18}*{\\textbf{" * res_classic[i][1] * "}}", "\\multirow{6}*{2}" ], res_classic[i][3:end], res_callback[i][4:end])
            else
                rows[i] = vcat(["", "\\multirow{6}*{" * res_classic[i][2] * "}", res_classic[i][3]], res_classic[i][4:end], res_callback[i][4:end])
            end
            push!(lines, "")
        else
            rows[i] = vcat(["", ""], res_classic[i][3:end], res_callback[i][4:end])
            
            if rem(i, 6) == 0
                if rem(i, 18) == 0
                    push!(lines, "\\hline")
                else
                    push!(lines, "\\cline{2-11}")
                end
            else
                push!(lines,"")
            end
        end
        
    end

    titles =    ["Instance", "D", "nb clusters", "Classique",                             "Callback"]
    subtitles = ["",         "",  "",            "Temps", "GAP", "Erreurs",               "Temps", "GAP", "Erreurs" ]
    subsubtitles = ["",      "",  "",            "",      "",    "Train set", "Test set", "",      "",    "Train set", "Test set" ]
    separation = isMultivariate ? "multivaries" : "univarie"
    write_table_tex("../res/results_merge_" * separation, "Résultats avec regroupements " * separation, titles, rows, 
                    subtitles=subtitles, subsubtitles = subsubtitles, num_col_titles = [1,1,1,4,4], num_col_sub = [1,1,1,1,1,2,1,1,2],
                    alignment="|l|c|r|cccc|cccc|", lines = lines, maxRawsPerPage=54)
end

save_results(false) #Univarié
save_results(true) #Multivarié