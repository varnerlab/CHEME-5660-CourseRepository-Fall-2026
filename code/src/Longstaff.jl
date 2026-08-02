# --- PRIVATE METHODS BELOW HERE -------------------------------------------------------------------------------------- #
function _lsqfit_local_regression_model(X::Array{Float64,1},Y::Array{Float64,1})::MyLocalExpectationRegressionModel 

    # setup the model -
    # @. model(x, p) = p[1]+p[2]*x+(p[3]*x^2)+(p[4]*x^3)+(p[5]*x^4)
    @. model(x, p) = p[1]+p[2]*x+p[3]*x^2


    # setup the fit -
    p0 = [-1.0, 3.0, -2.0]
    
    # run the fit -
    fit_bounds = curve_fit(model, X, Y, p0)

    # Wrap -
    a = fit_bounds.param

    # return the model -
    return MyLocalExpectationRegressionModel(a[1], a[2], a[3]);
end

function _evaluate_local_regression_model(model::MyLocalExpectationRegressionModel, X::Array{Float64,1})::Array{Float64,1}

    # initialize -
    f_value_array = Array{Float64,1}()
    
    # get the parameters for the model -
    a0 = model.a0
    a1 = model.a1
    a2 = model.a2

    # compute -
    for value in X
        term_1 = a0
        term_2 = a1*value
        term_3 = a2*(value)^2
        f_value = term_1+term_2+term_3
        push!(f_value_array,f_value)
    end

    # return -
    return f_value_array
end
# --- PRIVATE METHODS ABOVE HERE -------------------------------------------------------------------------------------- #

function premium(contract::T, model::MyLongstaffSchwartzContractPricingModel;
    choice::Function=_rational)::Float64 where {T<:AbstractContractModel}

    # initialize -
    S = model.S; # rows: samples, cols time
    r̄ = model.r̄
    Δt = model.Δt;
    (number_of_samples, number_of_periods) = size(S);
    intrinsic_value_table = zeros(number_of_samples, number_of_periods);
    option_value_table = zeros(number_of_samples, number_of_periods);
    option_exercise_table = Array{Int64,2}(undef, number_of_samples, number_of_periods);
    fill!(option_exercise_table, 0.0);

    # populate the intrinsic_value_table -
    for i ∈ 1:number_of_samples
        for j ∈ 1:number_of_periods
            intrinsic_value_table[i,j] = _payoff(contract, S[i,j]); 
        end
    end

    # the last col of the option_exercise_table holds the intrinsic value -
    for i ∈ 1:number_of_samples
        option_value_table[i,end] = intrinsic_value_table[i,end];
    end

    # let's look at expiration - should we exercise?
    for i ∈ 1:number_of_samples
        iv = intrinsic_value_table[i,end];
        if (iv > 0.0)
            option_exercise_table[i,end] = 1
        end
    end

    # loop over the periods - starting from the last period -
    for t ∈ (number_of_periods-1):-1:1

        # build the X array -
        idx_non_zero = findall(x->x>0.0, intrinsic_value_table[:,t]);
        Y = (1/𝒟(r̄,Δt))*intrinsic_value_table[idx_non_zero,t+1];
        X = S[idx_non_zero,t];
    
        # fit a local expectation model -
        local_expectation_model = _lsqfit_local_regression_model(X,Y);

        # ok, compute the continuation value -
        continue_values = _evaluate_local_regression_model(local_expectation_model, X);
        exercise_values = intrinsic_value_table[idx_non_zero,t];

        # populate the option table -
        number_of_nonzero_values = length(idx_non_zero);
        for k ∈ 1:number_of_nonzero_values
            
            index = idx_non_zero[k];
            a = continue_values[k];
            b = exercise_values[k];
            option_value_table[index,t] = choice(a,b)
        end
    end

    option_price = mean(option_value_table[:,1]);

    # return -
    return option_price
end