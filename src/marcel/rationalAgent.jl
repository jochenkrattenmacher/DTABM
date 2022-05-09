using BenchmarkTools
using Plots

# declare variables
default_basket = [1, 1, 1, 41]
default_pref = [0.5, 0.3, 0.2]
default_env = [2.0, 4.0, 3.0, 1.0]

mutable struct Agent
    id::Integer
    preferance::Array{Float64,1}
    basket::Array{Float64,1}
    tick::Integer
    #custom agent with individual values
    function Agent(pId::Integer, pPreferance::Array{Float64,1}, pBasket::Array{Float64,1})
        round(sum(pPreferance), digits = 8) != 1 ? error("Preferences must add up to 1") : return new(pId, pPreferance, pBasket,1::Integer)
    end
    #default agent with preset values
    function Agent(pId::Integer)
        println("Creating agent with default values")
        return new(pId, default_pref, default_basket, 1)        
    end
end

#TODO: function updateAgent with tests for not allowed values

mutable struct Environment
    id::Integer
    priceG1::Float64
    priceG2::Float64
    priceG3::Float64
    priceCash::Float64
    function Environment(pId::Integer, pPriceG1::Float64, pPriceG2::Float64, pPriceG3::Float64, pPriceCash::Float64)
        if 0 in map(x -> x > 0,[pPriceG1, pPriceG2, pPriceG3, pPriceCash])
            error("Environment vars can only be greater than 0")
        else
            return new(pId, pPriceG1, pPriceG2, pPriceG3, pPriceCash)
        end
    end
    function Environment(pId::Integer)
        return new(pId, default_env[1], default_env[2], default_env[3], default_env[4])
    end
    
end

function envAsVector(pE::Environment)
    return [pE.priceG1, pE.priceG2, pE.priceG3, pE.priceCash]
end

function getInput(message::String)
    println(message)
    return readline()
end

function getUtilitiy(pS, pAlpha)
    if round(sum(pAlpha), digits = 8) != 1
        @error("Preferences dont add up to 1")
        return -1
    end
    if 0 in map(x -> x > 0, pS)
        @error("A value in the basket is smaller than 0: ", pS)
        return -1
    end
    # prod: Product of all elements in array
    # s[1:3]: slice of array s
    # "."-operator: elementswise mapping of two arrays(broadcast-function)
    return prod(pS[1:3] .^ pAlpha)  + log(pS[4])
end

function plotStates(pStates)
    x = 1:size(pStates)[1]
    plot(pStates)
    #, label=["q1" "q2" "q3" "money" "Utility"])
    xaxis!("step")
    yaxis!("quantities")
    # legend()
end

function main(test = false, buyStep = 1.0)
    stateList = zeros(1,5) #stores all states for plotting
    if !test
        println("Create Agent with begin State and calculate the Utility of only cash.")
        input = getInput("Do you want to enter custom vars for the agent? y/N")
        if input == "N" || input == "n" || input == ""
            myAgent = Agent(1)
        elseif input == "Y" || input == "y"
            #get Input, remove blank spaces (replace with nothing), and split into substrings
            pref = split(replace(getInput("Please enter 3 numerical values for the preferences and seperate values with \" \".The sum must be 1!")," " => ""),",")
            pref = map(x -> parse(Float64,x), pref)
            basket = split(replace(getInput("Please enter 4 numerical values for the start state and seperate values with \" \".")," " => ""),",")
            basket = map(x -> parse(Float64,x), basket)
            myAgent = Agent(1,pref,basket)
        else
            error("This input is not allowed: $input")
        end

        input = getInput("Do you want to enter custom vars for the environment? y/N")
        if input == "N"|| input == "n" || input == ""
            myEnv = Environment(1)
        elseif input == "Y" || input == "y"
            getInput("Please enter 4 numerical values for the prices of the goods and the money.")
        else
            error("This input is not allowed: $input")
        end
    else
        myAgent = Agent(1)
        myEnv = Environment(1)
    end
    

    utility = getUtilitiy(myAgent.basket, myAgent.preferance)
    if !test
        println("The agent starts with ", myAgent.basket, " and an utility of $utility \n\n")
        println("Search for the maximum Utility by looking at each single buy-decision:")
    end
    #TODO: find max with jump and compare
    bigger = true
    stepcounter = 0
    while bigger
        bigger = false
        stateList = vcat(stateList, hcat(myAgent.basket', utility))
        poss = []
        for i in 1:3
            buy_Vector = zeros(4)
            buy_Vector[i] = buyStep
            new_state = copy(myAgent.basket)
            new_state = buy_Vector .+ new_state
            new_state[4] -= sum(buy_Vector .* envAsVector(myEnv))
            push!(poss,new_state)
        end
        for state in poss
            newUtil = getUtilitiy(state, myAgent.preferance)
            # TODO: find maxUtil in poss and get the index -> only one global change per cycle
            if newUtil > utility
                diff = newUtil - utility
                stepcounter += 1
                myAgent.basket = vec(state)
                utility = newUtil
                bigger = true
                newUtil = round(newUtil, digits = 5)
                #println("step - $stepcounter: The utility difference is $diff" , state)
            end
        end
        #reduce the stepsize when no better options
        if !bigger && abs(buyStep) > 10^-3
            bigger = true
            buyStep /= -2 
            #println("reduced stepsize to: ", buyStep)
        end
    end
    println("The maximum utility is around ", round(utility, digits = 5), " with the combination ", map(x -> round(x, digits = 5), myAgent.basket) ," !")
    println("It took $stepcounter steps")
    # for i in 1:size(stateList)[1]
    #     println(map(x -> round(x, digits = 4),stateList[i,:]))
    # end
    if !test
        println("#####THE END#####")
    end
    return stateList[setdiff(1:end,1),:]
end

#@btime main(true)
plotStates(main(true))

getUtilitiy(default_basket, default_pref)()