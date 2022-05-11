module StructureModule
export Good, Household, Trade, createHH, OutputCT, getUtility, getHistory

using Random
using ..Observables

mutable struct Good
	id::Int64
	name::String
end

struct Trade
	tradeVec::Vector
	sellerID::Integer
end

@observable TradeHistory begin
	trades::Vector{Trade}
end

@agent Household begin
	id::Int64
	inventory::Vector{Int64}
	utilWeight::Vector{Float64}
	partner::Vector
	product::Good
	history::TradeHistory
end

function getHistory(pHousehold::Household, pLength::Int)
	history = []
	length(pHousehold.history.trades) < pLength ? start = 0 : start = length(pHousehold.history.trades) - pLength
	for tradeID in start+1:length(pHousehold.history.trades)
		push!(history, pHousehold.history.trades[tradeID])
	end
	return history
end

function getUtility(pAgent::Household)
	return getUtility(pAgent, pAgent.inventory)
end

function getUtility(pAgent::Household, pInventory)
	return prod(pInventory .^ pAgent.utilWeight)
end

function createHH(pItems, pUtilWeights, pPartners, pProduct, pID, pRNG)
	randomRange = 10:50
	product = filter(x -> x.name == pProduct, pItems)[1]
	newHH = Household(pID, ones(length(pItems)), pUtilWeights, pPartners, product, TradeHistory([]))
	newHH.inventory[1] = rand(pRNG, randomRange)
	newHH.inventory[product.id] = rand(pRNG, randomRange)
	return newHH
end

end # end of module