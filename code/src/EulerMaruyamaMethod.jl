
function _solve(model::MyHestonModel, tspan::NamedTuple,
    initialconditions::AbstractArray, N::Int64, method::EulerMaruyamaMethod)::Tuple
    
    # initialize -
    d = model.μ
    f = model.κ
    g = model.θ
    h = model.ξ
    Σ = model.Σ
    Xₒ = initialconditions;

    # build the time and state arrays -
    tₒ = tspan.start;
    tₙ = tspan.stop;
    dt = tspan.step;
    T = range(tₒ, step=dt, stop=tₙ) |> collect
    M = length(T) # how many time steps do we have?
    X = Array{Float64,2}(undef, M, N) # initialize an empty array to store the price paths
    V = Array{Float64,2}(undef, M, N) # initialize an empty array to store the price paths

    # populate the first row -
    foreach(p -> X[1,p] = Xₒ[1], 1:N)
    foreach(p -> V[1,p] = Xₒ[2], 1:N)

    # pre generate the noise matrix -
    ZM = MvNormal(zeros(2), Σ);

    for p ∈ 1:N
        for i ∈ 2:M
            
            # call parameter functions 
            μ = d(X[i-1,p],T[i]) # drift
            κ = f(X[i-1,p],T[i]) # diffusion
            θ = g(X[i-1,p],T[i]) # mean reversion
            ξ = h(X[i-1,p],T[i]) # volatility of volatility

            # generate a sample -
            Z = rand(ZM);

            # update the state equations -
            X[i,p] = X[i-1,p] + (μ*X[i-1,p])*dt + sqrt(V[i-1,p])*X[i-1,p]*(sqrt(dt)*Z[1]);
            V[i,p] = V[i-1,p] + κ*(θ - V[i-1,p])*dt + ξ*(sqrt(V[i-1,p]))*(sqrt(dt)*Z[2]);
        end
    end

    # return the time and state arrays -
    return (T, X, V);
end


function _solve(model::MyOrnsteinUhlenbeckModel, tspan::NamedTuple,
    initialconditions::AbstractArray, N::Int64, method::EulerMaruyamaMethod)::Tuple

    # initialize -
    f = model.μ
    g = model.σ
    h = model.θ
    Xₒ = initialconditions;

    # build the time array -
    tₒ = tspan.start;
    tₙ = tspan.stop;
    dt = tspan.step;
    T = range(tₒ, step=dt, stop=tₙ) |> collect
    M = length(T) # how many time steps do we have?
    X = Array{Float64,2}(undef, M, N) # initialize an empty array to store the price paths

    # fill in the first row, this is the initial price
    foreach(p -> X[1,p] = Xₒ[1], 1:N)

    # pre generate the noise matrix -
    ZM = Normal(0,1) |> d->rand(d, M, N)
    
    # update the state array -
    for p ∈ 1:N
        for i ∈ 2:M

            # call parameter functions 
            μ = f(X[i-1,p],T[i]) # drift
            σ = g(X[i-1,p],T[i]) # diffusion
            θ = h(X[i-1,p],T[i]) # mean reversion

            # update the state -
            X[i,p] = X[i-1,p] + θ*(μ - X[i-1,p])*dt + σ*sqrt(dt)*ZM[i,p] 
        end
    end

    # return the time and state arrays -
    return (T, X);
end

"""
    function solve(model::AbstractAssetModel, tspan::NamedTuple, initialconditions::AbstractArray; 
                method::AbstractStochasticSolverModel = EulerMaruyamaMethod(), N::Int64 = 100)::Tuple

The `solve` function is used to solve a stochastic asset model. 
The function takes a model, time span, initial conditions, method, and number of paths as input and returns a tuple of time and state arrays. 
The `method` argument is used to specify the method used to solve the model. The `N` argument is used to specify the number of paths to simulate. 
The function uses the Euler-Maruyama method as the default method to solve the model.

### Arguments
- `model::AbstractAssetModel`: The asset model to solve.
- `tspan::NamedTuple`: The time span to solve the model over. The NamedTuple should have the fields `start`, `stop`, and `step`.
- `initialconditions::AbstractArray`: The initial conditions for the model.
- `method::AbstractStochasticSolverModel = EulerMaruyamaMethod()`: The method used to solve the model. Default is [Euler-Maruyama](https://en.wikipedia.org/wiki/Euler–Maruyama_method).
- `N::Int64 = 100`: The number of paths to simulate. Default is 100 paths.

### Return
- `Tuple`: A tuple of time and state arrays (more than one with multidimensional models) where the rows are the time steps and the columns are the paths. 
"""
function solve(model::AbstractAssetModel, tspan::NamedTuple,
    initialconditions::AbstractArray; method::AbstractStochasticSolverModel = EulerMaruyamaMethod(), 
    N::Int64 = 100)::Tuple
    return _solve(model, tspan, initialconditions, N, method);
end