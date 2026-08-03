function securityterm(duration::String)::Float64

    # initialize -
    number_of_days_per_week = 7.0;
    number_of_days_per_year = 365.0;
    value = 0.0;
    numerator = 0.0;
    denominator = 1.0;

    # convert -
    security_term_components = split(duration, "-");
    if (length(security_term_components) != 2)
        throw(ArgumentError("Invalid security term value: $duration"));
    end

    # what is the demominator? -
    denominator = number_of_days_per_year;

    # number of time units -
    numerator = security_term_components[1] |> String |> x-> parse(Float64,x)

    # get the duration -
    unit_of_time = security_term_components[2];
    if (unit_of_time == "Week")
        numerator *= number_of_days_per_week;    
    elseif (unit_of_time == "Year")
        numerator *= number_of_days_per_year;
    end   
    
    # calculate -
    value = numerator / denominator;

    # return -
    return value;
end