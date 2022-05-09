module AnalysisModule
export printCSV, clearOutputFile, calcWelfare, getPrice, OutputCT
using ..StructureModule

# TODO_ Move outFile into controller
outFile = "modelOutput.txt"

struct OutputCT
	round::Int64
	step::Int64
	agentID::Int64
	vendorID::Int64
	changeVec::Array
	agentNewState::Array
	vendorNewState::Array
	agentUtil::Float64
	vendorUtil::Float64
	agentExpectation::Vector
end

function printCSV(pMessage::String)
	@info pMessage
	open(outFile, "a") do output
		write(output, "$pMessage\n") 
	end
end

function printCSV(pDict::Dict)
	open(outFile, "a") do output
		for (key, value) in pDict
			write(output, "$key => $value\n") 
		end
	end
end

function clearOutputFile()
	if isfile(outFile)
		rm(outFile)
	end
end

function calcWelfare(pVillage)
	return prod(map(getUtility, pVillage))
end

function alterAgent!()
	# modify given agent to have an user defined setting
	# TODO: implement alterAgent!
end

function getPrice(pTransactions)
	priceVec = []
	for transaction in pTransactions
		if transaction.changeVec[1] != 0
			absVector = map(abs, transaction.changeVec)
			for i in 2:length(transaction.changeVec)
				if transaction.changeVec[i] != 0
					push!(priceVec, absVector ./ absVector[i])
				end
			end
		end
	end
	return priceVec
end

end # end of module