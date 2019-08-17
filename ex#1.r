devtools::install_github("PolicyAnalysisInc/heRoMod")

library(flexsurv)
library(survival)
library(flexsurvcure)
library(heRomod)
library(ggplot2)

# Section 1. Intro to Hee

#   Transition Prob : define_transition function
mat_trans <- define_transition(
  .9, .1,
  .2, .8
)

mat_trans
plot(mat_trans,cex.txt=1.8)
# 
# A transition matrix, 2 states.
# 
# A   B  
# A 0.9 0.1
# B 0.2 0.8

#   State Values : define_state function
state_A <- define_state(
  cost = 1234,
  utility = 0.85
)
state_A
# A state with 2 values.
# 
# cost = 1234
# utility = 0.85

state_B <- define_state(
  cost = 4321,
  utility = 0.50
)

#   Combine information in a model : transition prob and state values are defined 
# for a given strategy

strat <- define_strategy(
  transition = mat_trans,
  state_A,
  state_B
)
strat
# A Markov model strategy:
#   
#   2 states,
#   2 state values

#   Run the model
res_mod <- run_model(
  strat,
  cycles = 10,
  cost = cost,
  effect = utility
)

res_mod

## 1 strategy run for 10 cycles.
## 
## Initial state counts:
## 
## A = 1000L
## B = 0L
## 
## Counting method: 'life-table'.
## 
## Values:
## 
##       cost  utility
## I 19796856 7654.552

#By default the model is run for 1000 persons starting in the first state (here state A).

#   Analyse Results
plot(res_mod)

plot(res_mod) +
  xlab("Time") +
  ylab("N") +
  theme_minimal() +
  scale_color_brewer(
    name = "State",
    palette = "Set1"
  )

plot(res_mod, bw = TRUE)

# The state membership counts and the values can be accessed 
# with get_counts() and get_values() respectively.
head(get_counts(res_mod))

get_counts(res_mod)
get_values(res_mod)