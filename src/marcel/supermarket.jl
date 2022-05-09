# TODO
# basic strucutre: 
# - neighbours go shopping -> prices stored in Observables
# - agent gets information out of observable
# - agent decides which shop to visit
#
#
# functions:
# get_utiltiy
# optimize shopping
# use informationfrom frind network


include("structureModule.jl")
include("jumpSolver.jl")
using Graphs, MetaGraphs

struct Trade
    shop::Int
    prices::Vector{Float64}
end

@observable PriceHistory begin
    trades::Vector{Trade}
end

@agentM Shopper begin
    id::Int
    preference::Vector{Float64}
    basket::Vector{Float64}
    friends::Vector{Int64}
    history::PriceHistory

    function Shopper(id, pref, basket)
        return new(id, pref, basket, [], PriceHistory([]))
    end
end

@agentM Market begin
    id::Int
    prices::Vector{Float64}
    inventory::Vector{Float64}
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

function getExpectedPrices(pCustomers, pShops, pActiveAgentID = 1)
    # calculate the epected price based on the agent history and the network history
    expectedPrices = []
    for shop in pShops
        shopHistory = []
        for agent in filter(x -> x.id in vcat(pCustomers[pActiveAgentID].friends, pActiveAgentID), pCustomers)
            agentExperience = getExpectedPrices(agent, shop.id)
            if agentExperience != []
                push!(shopHistory, agentExperience)
            end
        end
        push!(expectedPrices, Trade(shop.id, sum(shopHistory) ./ length(shopHistory)))
    end
    return expectedPrices
end

function getRandomPriceVec(pLength)
    priceVec = zeros(pLength)
    for i in 1:pLength
        priceVec[i] = rand(globalRNG, 1:10)
    end
    return priceVec
end

function getRandomTrade()
    randShopID = rand(globalRNG, 1:shopCount)
    randPrices = getRandomPriceVec(3)
    return Trade(randShopID,randPrices)
end

function getExpectedPrices(pAgent::Shopper, pShopID::Int)
    # return expected price for one agent and one shop
    expectedPrices = []
    tradeList = filter(x -> x.shop == pShopID, pAgent.history.trades)
    if length(tradeList) > 0
        expectedPrices = sum(map(x -> x.prices, tradeList)) ./ length(tradeList) # TODO: Use Other AVG value
    end
    return expectedPrices
end

function createCustomers()
    customers = []
    push!(customers, Shopper(1, activeAgentPref, [0,0,0,50])) # <- active agent
    push!(customers, Shopper(2, [0.0, 0.0, 0.0], [0,0,0,24]))
    push!(customers, Shopper(3, [0.0, 0.0, 0.0], [0,0,0,30]))

    # add network to active agent
    map(x -> push!(customers[1].friends, x), [2,3])

    # add history to passiveAgents
    for passiveAgent in customers[2:end]
        for i in 1:rand(globalRNG, 1:5)
            randTrade = getRandomTrade()
            push!(passiveAgent.history.trades, randTrade)
        end
    end

    return customers
end

function createShops()
    # TODO: Utilise shopCount and random init
    # TODO: Link shop prices to random history
    shops = []
    push!(shops, Market(1, [4,3,2,1], [10, 10, 10]))
    push!(shops, Market(2, [5,1,4,1], [20, 20, 20]))
    return shops
end

function runModel!(pCustomer, pShops)
    preferedShop = 0
    maxUtil = 0
    activeAgent = pCustomer[1]
    for prices in getExpectedPrices(pCustomer, pShops)
        expectedUtil, optimalBasket = optimize(activeAgent.preference, activeAgent.basket, prices.prices)
        println(expectedUtil)
        if expectedUtil > maxUtil
            maxUtil = expectedUtil
            preferedShop = prices.shop
        end
    end
    println(preferedShop)
end