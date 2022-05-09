using Agents

@agent eater GraphAgent begin
    consumption::Float64
    isPresent::Bool
end

function initialize_model(;
    consumption_distribution = 0, p_present = 0.5, forward_factor = 0.1)
    properties = Dict(:p_present => p_present, :forward_factor => forward_factor)
    model = ABM(eater; properties)
    for (i,cs) in enumerate(consumption_distribution)
        agent = eater(i, 0, cs, 1)
        add_agent!(agent, model)
    end
    return model
end

function agent_step!(agent, model)
    agent.isPresent = rand() < model.p_present ? 1 : 0
    return
end

function model_step!(model)
    meals = falses(nagents(model))
    for (i,agent) in allagents(model)
        meals[i] = rand() < agent.consumption ? 1 : 0
    end
    
end