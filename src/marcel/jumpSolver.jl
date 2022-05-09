using JuMP
using Ipopt

function createOptModel(pPref, pStartVec, pPrices)
    model = Model(Ipopt.Optimizer)
    set_silent(model)
    # add variables with lower bounds
    @variable(model, g1 >= pStartVec[1])
    @variable(model, g2 >= pStartVec[2])
    @variable(model, g3 >= pStartVec[3])
    @variable(model, cash, start = 1.0)

    # add objective and constraint for the model
    @NLobjective(model, Max,  g1^pPref[1]*g2^pPref[2]*g3^pPref[3]+log(cash))
    @constraint(model, (g1-lower_bound(g1))*pPrices[1]+(g2-lower_bound(g2))*pPrices[2]+(g3-lower_bound(g3))*pPrices[3]+cash*1 == pStartVec[4]) # only calculate cost of the new goods # TODO: use global cashprice
    return model
end


function optimize(pPref, pStartVec, pPrices)
    model = createOptModel(pPref, pStartVec, pPrices)
    optimize!(model)
    return objective_value(model), [model[:g1], model[:g2], model[:g3], model[:cash]]
end