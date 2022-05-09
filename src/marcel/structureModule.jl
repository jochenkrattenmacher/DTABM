# Macro helper functions
function createStruct(pName, pFields, pType::Type)
    myStruct = :(mutable struct $(esc(pName)) <: $pType end)
    push!(myStruct.args[end].args, map(esc,pFields.args)...)
    return myStruct
end

function createStruct(pName, pFields, pBase::Symbol, pType::Type)
    base_struct = eval(pBase)
    base_fieldnames = fieldnames(base_struct)
    base_types = [t for t in base_struct.types]
    base_fields = [:($f::$T) for (f, T) in zip(base_fieldnames, base_types)]
    myStruct = :(mutable struct $(esc(pName)) <: $pType end)
    push!(myStruct.args[end].args, base_fields...)
    push!(myStruct.args[end].args, map(esc,pFields.args)...)
    return myStruct
end

# basic Agent type
abstract type AbstractAgent end

struct Relation
    node1::AbstractAgent
    node2::AbstractAgent
    directed::Bool
end

macro agentM(pName, pFields)
    return createStruct(pName, pFields, AbstractAgent)
end
# basic Observer Type

abstract type AbstractObservable end

macro observable(pName, pFields)
    myObservable = createStruct(pName, pFields, AbstractObservable)
    return myObservable
end

# function addObserver!(pObservable::AbstractObservable, pAgent::AbstractAgent)
#     push!(pObservable.oberverList, pAgent)
# end