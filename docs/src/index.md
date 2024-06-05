# RamseyGrowthModel.jl

## Simple example

```@example
push!(LOAD_PATH, pwd() * "/../..") # hide
using RamseyGrowthModel

my_model = GrowthModel(
    0.95,  # discount factor
    0.02,  # depreciation rate on capital
    2.0,   # coefficient of relative risk aversion
    0.3,   # return to capital per capita
    1,     # technology
)

allocation = solve(
    my_model,
    5,     # time horizon
    1.0    # initial capital
)

print(allocation)
```

## Defining and Solving a Growth Model

```@docs
GrowthModel
```

```@docs
RamseyGrowthModel.steady_state_K
```

```@docs
solve
```

## Sample Functions Used in the Model

!!! info
    You *probably* should not be using these functions directly in your program. Instead, use a constructor of the [`GrowthModel`](@ref).

```@docs
RamseyGrowthModel.sample_u
```

```@docs
RamseyGrowthModel.sample_f
```
