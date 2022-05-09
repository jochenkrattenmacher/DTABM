# Discussion points
# - implementation of Observables as struct or as function of an agent
# - multiple optimisation steps for each trade
# - init model without random trades -> First market will get all customers
# - state of the working paper

using Random

const seed = 12345
const globalRNG = MersenneTwister(seed)
const activeAgentPref = [0.5, 0.3, 0.2]
const shopCount = 2
const cashPrice = 1

# include marcel
include("marcel/structureModule.jl")
include("marcel/jumpSolver.jl")
include("marcel/analysisModule.jl")
include("marcel/supermarket.jl")


customer = createCustomers()
shops = createShops()

runModel!(customer, shops)