using Agents
using Random
include("marcel/jumpSolver.jl")

mutable struct Shopper <: AbstractAgent
    id::Int
    preference::Vector{Float64}
    basket::Vector{Float64}
    preferedShop::Int
end

function initialize_model(; rng = MersenneTwister(12345),
    shops = ([4,3,2,1], [5,1,4,1]), 
    preferences = ([0.5, 0.3, 0.2], [0.2, 0.3, 0.5], [0.4, 0.2, 0.4]), 
    basket = [0,0,0,50])
    properties = Dict(:shops => shops)
    model = ABM(Shopper; properties, rng)
    for (i,p) in enumerate(preferences)
        agent = Shopper(i, p, basket, 0)
        add_agent!(agent, model)
    end
    return model
end

function agent_step!(agent, model)
    preferedShop = 0
    maxUtil = 0
    for (i, prices) in enumerate(model.shops)
        expectedUtil, optimalBasket = optimize(agent.preference, agent.basket, prices)
        println(expectedUtil)
        if expectedUtil > maxUtil
            maxUtil = expectedUtil
            preferedShop = i
        end
    end
    agent.preferedShop = preferedShop
    println(preferedShop)
end