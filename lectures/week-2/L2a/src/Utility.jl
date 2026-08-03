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

"""
    treasury_bill_price_from_investment_rate(par, investment_rate, issue_date, maturity_date)

Convert Treasury's reported investment rate (coupon-equivalent yield) to a bill
price using the conventions in 31 CFR Part 356, Appendix B. Bills with no more
than one half-year remaining use simple annualization; longer bills use the
coupon-equivalent formula. Dates determine both actual days to maturity and
whether the following year contains 365 or 366 days.
"""
function treasury_bill_price_from_investment_rate(
    par::Real,
    investment_rate::Real,
    issue_date::Date,
    maturity_date::Date,
)::Float64
    par > 0 || throw(ArgumentError("par must be strictly positive"));
    maturity_date > issue_date || throw(ArgumentError("maturity_date must be after issue_date"));

    days_to_maturity = Dates.value(maturity_date - issue_date);
    days_in_following_year = Dates.value((issue_date + Year(1)) - issue_date);
    rate = Float64(investment_rate);

    denominator = if 2 * days_to_maturity <= days_in_following_year
        1 + rate * days_to_maturity / days_in_following_year
    else
        (1 + (days_to_maturity - days_in_following_year / 2) * rate / days_in_following_year) *
        (1 + rate / 2)
    end
    denominator > 0 || throw(DomainError(denominator, "quotation formula produced a non-positive denominator"));

    return Float64(par) / denominator;
end
