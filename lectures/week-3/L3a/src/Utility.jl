"""
    function securityterm(duration::String)::Float64

Convert a security term string (e.g., "6-Month", "1-Year") into a fractional year value. 
This assumes 365 days per year and 7 days per week.

### Arguments
- `duration::String`: The security term as a string in the format "X-Unit", where X is a number and Unit is "Week", or "Year".

### Returns
- `Float64`: The equivalent duration in years.

"""
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