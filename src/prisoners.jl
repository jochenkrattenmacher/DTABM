using Agents
using Random

mutable struct Prisoner <: AbstractAgent
    id::Int
end

function initialize_model(; rng = MersenneTwister(12345),
    TRPS = [4 3 2 1])
    properties = Dict(:TRPS => TRPS)
    model = ABM(Prisoner; properties, rng)
    add_agent!(model)
    add_agent!(model)
    return model
end

function agent_step!(agent, model)
    TRPS = model.TRPS
    U_defer = TRPS[1] + TRPS[3]
    U_cooperate = TRPS[2] + TRPS[4]
    if U_defer > U_cooperate
        println("Agent $(agent.id) defers")
    else
        println("Agent $(agent.id) cooperates")
    end
end