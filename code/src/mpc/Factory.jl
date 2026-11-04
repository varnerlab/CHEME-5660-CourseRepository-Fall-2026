"""
    build(::Type{MyMarketData}, data::NamedTuple)::MyMarketData

Build a `MyMarketData` from a NamedTuple holding every field (units as in the type docstring).
"""
function build(::Type{MyMarketData}, data::NamedTuple)::MyMarketData
    model = MyMarketData()
    for f ∈ fieldnames(MyMarketData)
        haskey(data, f) || throw(ArgumentError("Cannot build MyMarketData: missing field $(f)"))
        setfield!(model, f, data[f])
    end
    return model
end

"""
    build(::Type{MySIMParameterEstimate}, data::NamedTuple)::MySIMParameterEstimate

Build a SIM estimate from a NamedTuple with fields `α`, `β`, `σ_ε`, `r²`.
"""
function build(::Type{MySIMParameterEstimate}, data::NamedTuple)::MySIMParameterEstimate
    model = MySIMParameterEstimate()
    for f ∈ fieldnames(MySIMParameterEstimate)
        haskey(data, f) || throw(ArgumentError("Cannot build MySIMParameterEstimate: missing field $(f)"))
        setfield!(model, f, Float64(data[f]))
    end
    return model
end

"""
    build(::Type{MyEWLSState}, data::NamedTuple)::MyEWLSState

Build an EWLS state from a NamedTuple holding every field.
"""
function build(::Type{MyEWLSState}, data::NamedTuple)::MyEWLSState
    model = MyEWLSState()
    for f ∈ fieldnames(MyEWLSState)
        haskey(data, f) || throw(ArgumentError("Cannot build MyEWLSState: missing field $(f)"))
        setfield!(model, f, Float64(data[f]))
    end
    return model
end

"""
    build(::Type{MyEWVarState}, data::NamedTuple)::MyEWVarState

Build an EW variance state from a NamedTuple holding every field.
"""
function build(::Type{MyEWVarState}, data::NamedTuple)::MyEWVarState
    model = MyEWVarState()
    for f ∈ fieldnames(MyEWVarState)
        haskey(data, f) || throw(ArgumentError("Cannot build MyEWVarState: missing field $(f)"))
        setfield!(model, f, Float64(data[f]))
    end
    return model
end
