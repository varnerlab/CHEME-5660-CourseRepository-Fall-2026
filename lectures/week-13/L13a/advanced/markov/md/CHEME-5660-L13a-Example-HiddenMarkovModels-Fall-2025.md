## Example: Properties of a Three-State Hidden Markov Model
In this example, we explore the properties of a simple three-state Hidden Markov Model (HMM) to model mood swings.

> __Learning Objectives:__
>
> By the end of this example, you will be able to:
> * __Construct transition matrices for Hidden Markov Models:__ Build transition probability matrices for hidden state spaces, verify row-normalization constraints, and create categorical distributions for state transitions in Markov chains.
> * __Compute stationary distributions using iterative methods:__ Apply iterative algorithms to estimate stationary distributions from transition matrices, implement convergence criteria based on norm differences, and validate results using categorical distributions.
> * __Implement emission probability matrices and simulate HMM sequences:__ Define emission probability matrices linking hidden states to observable outputs, generate synthetic sequences by sampling from transition and emission distributions, and estimate output probabilities from simulated data.


Let's get started!
___

## Setup, Data, and Prerequisites
First, we set up the computational environment by including the `Include.jl` file and loading any needed resources.

> __Include:__ The [`include(...)` command](https://docs.julialang.org/en/v1/base/base/#include) evaluates the contents of the input source file, `Include.jl`, in the notebook's global scope. The `Include.jl` file sets paths, loads required external packages, etc. For additional information on functions and types used in this material, see the [Julia programming language documentation](https://docs.julialang.org/en/v1/). 

Let's set up our code environment:


```julia
include(joinpath(@__DIR__, "Include.jl")); # include the Include.jl file
```

### Implementation
Before we start this example, let's set up the `iterate(...)` method and specify some constants. We'll use the `iterate(...)` method to compute the stationary distribution $\pi$.
```julia
iterate(P::Array{Float64,2}; 
        maxcount::Int = 100, ϵ::Float64 = 0.1) -> Array{Float64,2}
```
> Iteratively computes a stationary distribution. Computation stops if $||\pi_{new} - \pi|| < \epsilon$ or the max number of iterations is hit. 

Let's look at the code:


```julia
function iterate(P::Array{Float64,2}; 
        maxcount::Int = 100, ϵ::Float64 = 0.1)::Array{Float64,2}

    # initialize -
    counter = 1; # initialize the iteration counter
    is_ok_to_stop = false; # flag for while loop
    N = size(P,1); # number of rows in P matrix
    πₒ = ones(Float64, N) ./ N; # initial uniform distribution
    π = reshape(πₒ, 1, N); # initialize π (make it a 1 x N matrix)
    
    # main loop - iterate until the difference ||π′ - π|| <= ϵ or we run out of iterations
    while (is_ok_to_stop == false)

        π′ = π * P; # update π
        if (norm((π′ - π),1) <= ϵ || counter >= maxcount)
            is_ok_to_stop = true; # set the flag to exit the while loop

            # warn the user if we hit the maxcount
            if (counter >= maxcount)
                @warn "Maximum iteration count reached before convergence."
            end
        end
        π = reshape(π′, 1, N); # update π (make sure it's a 1 x N matrix)
        counter += 1; # update the counter
    end

    # return -
    return π;
end;
```

#### Constants 
In the simulations below, we'll need some constant values that we set here. In particular, we set a value for the `number_of_hidden_states` variable, the `number_of_simulation_steps` variable (the number of steps that we take in a Markov Chain), and the `number_of_observable_states` variable:


```julia
number_of_hidden_states = 3; # how many hidden states do we have?
number_of_observable_states = 3; # how many observable states do we have?
number_of_simulation_steps = 50000; # number of simulation steps
```

___

## Task 1: Set up the Transition Matrix $\mathbf{P}$
In this task, we set up the transition matrix $\mathbf{P}$ for a three-state [Markov chain model](https://en.wikipedia.org/wiki/Markov_chain):

<div>
    <center>
        <img src="figs/Fig-ThreeState-HMM-Schematic.svg" width="580"/>
    </center>
</div>

In this example we have three states and the probability of moving between state $i\rightarrow{j}$, denoted as $p_{ij}$, is an element of the matrix $\mathbf{P} \in \mathbb{R}^{3\times{3}}$.

> __System:__ In this example, we'll use a three-state model where the hidden states are mapped to the mood set: 
> $$
\begin{align*}
\mathcal{S}\equiv\left\{\text{happy},\text{neutral},\text{sad}\right\}
\end{align*}
$$
> We'll then map the hidden states $s_{i}\in\mathcal{S}$ to outward manifestations of mood which are observable, as represented by [Emoji](https://en.wikipedia.org/wiki/Emoji).

So let's set up the (hidden) transition matrix $\mathbf{P}$ for this system:


```julia
P = [
    0.05 0.95 0.0 ; # moves for state 1 = happy
    0.6 0.2 0.2 ; # moves for state 2 = neutral
    0.0 0.3 0.7 ; # moves for state 3 = sad
];
```

### Check: Do the rows of the transition matrix $\mathbf{P}$ sum to `1`?
We know that the rows of the transition matrix $\mathbf{P}$ must sum to `1`. That is, if we are in state $s_{i}\in\mathcal{S}$ at time $t$, then at time $t+1$ we must be in some state $s_{j}\in\mathcal{S}$. 

> __Check:__ Let's verify that the transition matrix $\mathbf{P}$ meets this criterion using the [@assert macro](https://docs.julialang.org/en/v1/base/base/#Base.@assert) by iterating over the rows of the transition matrix $\mathbf{P}$ and checking the sum of each row. If any row does not meet this criterion, an [AssertionError](https://docs.julialang.org/en/v1/base/base/#Core.AssertionError) will be thrown.

So what do we see?


```julia
for i ∈ 1:number_of_hidden_states
    @assert sum(P[i,:]) == 1
end
```

Now that we are sure that the transition matrix $\mathbf{P}$ is proper, we populate the `hidden_state_probability_dictionary`, which holds the [categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution) modeling the transition probability for each hidden state $s\in\mathcal{S}$, i.e., the probability that we transition from state $i\rightarrow{j}$ in the next time step:


```julia
hidden_state_probability_dictionary = let
    
    # initialize -
    hidden_state_probability_dictionary = Dict{Int,Categorical}();
    
    # main loop
    for i ∈ 1:number_of_hidden_states
        hidden_state_probability_dictionary[i] = Categorical(P[i,:])
    end
    hidden_state_probability_dictionary; # return
end;
```

___

## Task 2: Compute the stationary distribution $\pi$
In this task, we'll compute the stationary distribution $\pi$ for our example [Markov chain](https://en.wikipedia.org/wiki/Markov_chain) using the `iterate(...)` method defined above. 

__So how did this work?__ We compute the stationary distribution $\bar{\pi}$ by directly iterating the expression:
$$
\pi_{n} = \pi_{\circ}\cdot\mathbf{P}^{n}\quad\,n=1,2,\dots
$$
As $n\rightarrow\infty$ (i.e., as we perform more iterations), the difference between subsequent iterations becomes small, $||\pi_{n+1}-\pi_{n}||<\epsilon$, for a non-periodic Markov chain, where $\pi_{n}\rightarrow\bar{\pi}$ as $n\rightarrow\infty$. 

> __What is going to happen?__ 
>
> We'll iterate until we hit one of two possible conditions:
> * The `counter == maxcount`; at this point, the iteration stops, and the vector $\bar{\pi}$ is returned (but it may not be correct).
> * The iteration also stops when the difference between subsequent estimates of $\bar{\pi}$ is smaller than a specified threshold $\epsilon$. In this case, the correct $\bar{\pi}$ is returned.

We'll save the stationary distribution in the $\bar{\pi}$ variable.


```julia
π̄ = iterate(P, ϵ = 1e-9, maxcount = 10000) # iterative version of iterate
```


    1×3 Matrix{Float64}:
     0.274809  0.435115  0.290076


Finally, create a [categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution) using the stationary probability of our Markov chain using the [Distributions.jl](https://github.com/JuliaStats/Distributions.jl) package. Save this distribution in the variable `d`:


```julia
d = Categorical(π̄[1,:]); # steady-state stationary distribution
```

___

## Task 3: Set up the Emission Probability Matrix $\mathbf{E}$
In this task, we set up the Emission Probability Matrix $\mathbf{E}$, which links the hidden and observable [Markov chain](https://en.wikipedia.org/wiki/Markov_chain) states. We save the emission probability matrix in the `E` variable:


```julia
E = [
    0.90 0.05 0.05 ; # 1 happy (but sometimes we see other faces)
    0.05 0.90 0.05 ; # 2 neutral (but sometimes we see other faces)
    0.05 0.05 0.90 ; # 3 sad (but sometimes we see other faces)
];
# E = diagm(ones(3)) # we never have a missed guess ...
```


    3×3 Matrix{Float64}:
     0.9   0.05  0.05
     0.05  0.9   0.05
     0.05  0.05  0.9


Populate the `emission_probability_dict`, which holds the [categorical distribution](https://en.wikipedia.org/wiki/Categorical_distribution) modeling the emission probability for each hidden state $s\in\mathcal{S}$, i.e., the probability of what output $o_{i}\in\mathcal{O}$ we expect to see if we are in $s\in\mathcal{S}$:


```julia
emission_probability_dict = Dict{Int,Categorical}()
for i ∈ 1:number_of_hidden_states
    emission_probability_dict[i] = Categorical(E[i,:]) # map hidden state to observable state
end
```


```julia
emission_probability_dict
```


    Dict{Int64, Categorical{P} where P<:Real} with 3 entries:
      2 => Categorical{Float64, Vector{Float64}}(support=Base.OneTo(3), p=[0.05, 0.…
      3 => Categorical{Float64, Vector{Float64}}(support=Base.OneTo(3), p=[0.05, 0.…
      1 => Categorical{Float64, Vector{Float64}}(support=Base.OneTo(3), p=[0.9, 0.0…


### Simulate the output from the HMM
In this task, we simulate the evolution of the hidden Markov model.
Let's implement the pseudo-code from the lecture, where each observable state corresponds to an [Emoji](https://en.wikipedia.org/wiki/Emoji). We store this relationship in the `observable_emoji_map` variable, which is a dictionary with keys corresponding to observable states $o\in\mathcal{O}$ and [Emoji](https://en.wikipedia.org/wiki/Emoji) values.


```julia
observable_emoji_map = Dict{Int,Any}();
observable_emoji_map[1] = `😄`;
observable_emoji_map[2] = `😐`;
observable_emoji_map[3] = `😞`;
```

__Simulation algorithm:__ For `number_of_simulation_steps`, starting from some initial state $s\in\mathcal{S}$: 
* First, we get the hidden state distribution from the `hidden_state_probability_dictionary`, then generate a new state $s^{\prime}$, access the emission distribution from the `emission_probability_dict` that corresponds to $s^{\prime}$, and generate a random observable output $o_{i}$.
* Next, we save both the hidden state $s^{\prime}$ and the output $o_{i}$ for this iteration in the `hidden_simulation_dict` and `output_simulation_dict` variables, respectively.
* Finally, we update the current state $s_{i}\leftarrow{s}^{\prime}$ and move onto the next iteration.

So what do we get?


```julia
output_simulation_dict, hidden_simulation_dict = let

    output_simulation_dict = Dict{Int,Any}()
    hidden_simulation_dict = Dict{Int,Int}();
    sᵢ = 1;
    
    for i ∈ 1:number_of_simulation_steps

        # get the categorical distribution for sᵢ 
        dᵢ = hidden_state_probability_dictionary[sᵢ];
    
        # compute the *next* hidden state -
        s′ = rand(dᵢ);

        # next, compute what output we see from this state -
        oᵢ = emission_probability_dict[s′] |> o -> rand(o);

        # capture -
        hidden_simulation_dict[i] = s′
        output_simulation_dict[i] = observable_emoji_map[oᵢ]

        # update -
        sᵢ = s′;
    end

    output_simulation_dict, hidden_simulation_dict # return
end
```


    (Dict{Int64, Any}(45120 => `[4m😞[24m`, 1703 => `[4m😄[24m`, 37100 => `[4m😞[24m`, 3406 => `[4m😐[24m`, 28804 => `[4m😄[24m`, 40691 => `[4m😞[24m`, 3220 => `[4m😐[24m`, 11251 => `[4m😞[24m`, 422 => `[4m😐[24m`, 15370 => `[4m😐[24m`…), Dict(45120 => 3, 1703 => 1, 37100 => 3, 3406 => 2, 28804 => 1, 40691 => 3, 3220 => 2, 11251 => 3, 422 => 2, 15370 => 2…))



```julia
foreach(i->println("$(hidden_simulation_dict[i]),$(output_simulation_dict[i])"), 1:20); # wow, that's nice ...
```

    2,`😐`
    2,`😐`
    1,`😄`
    2,`😐`
    1,`😄`
    2,`😐`
    1,`😄`
    2,`😄`
    1,`😞`
    2,`😐`
    1,`😄`
    2,`😐`
    2,`😐`
    3,`😞`
    3,`😞`
    3,`😞`
    2,`😐`
    1,`😐`
    2,`😞`
    3,`😞`


__Let's do a quick test:__ What is the probability that we observe a particular value? We'll compute this by iterating over the simulation output and counting the times a `test_value` is encountered. We'll then estimate the probability as the number of positive samples divided by the total number of samples.


```julia
let
    test_value = `😐`;
    N₊ = 0;
    for (key,value) ∈ output_simulation_dict
        if (value == test_value)
            N₊ += 1
        end
    end
    probability = N₊/number_of_simulation_steps;
    println("We observe $(test_value) with probability = $(probability)")
end
```

    We observe `😐` with probability = 0.41636


___

## Summary
This example demonstrates how to construct and simulate a three-state Hidden Markov Model for mood states using transition and emission probability matrices.

> __Key Takeaways:__
>
> * __Transition matrices must satisfy row normalization:__ Each row of the transition probability matrix sums to one, representing the complete set of possible next states from any current state. Categorical distributions constructed from transition matrix rows enable state sampling in Markov chain simulations.
> * __Stationary distributions emerge from iterative matrix multiplication:__ Repeatedly applying the transition matrix to an initial distribution converges to a stationary distribution when the norm difference between successive iterations falls below a threshold. The stationary distribution represents long-run state probabilities independent of initial conditions.
> * __Emission matrices link hidden states to observable outputs:__ Each row of the emission probability matrix defines the distribution of observable outputs for a given hidden state. Simulating HMM sequences involves sampling next states from transition distributions and sampling outputs from emission distributions corresponding to those states.

Hidden Markov Models provide a framework for modeling systems with hidden state dynamics and observable outputs.
___
