# Discussion points
# - implementation of Observables as struct or as function of an agent
# - multiple optimisation steps for each trade
# - init model without random trades -> First market will get all customers
# - state of the working paper

# include marcel
# include("marcel/structureModule.jl")
# include("marcel/jumpSolver.jl")
# include("marcel/analysisModule.jl")
include("jmarket.jl")


model = initialize_model()


@time Agents.step!(model, agent_step!,  1) 
