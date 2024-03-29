library(heRomod)

param <- define_parameters(
  age_init = 60,
  sex = 0,
  
  # age increases with cycles
  age = age_init + markov_cycle,
  
  # operative mortality rates
  omrPTHR = .02,
  omrRTHR = .02,
  
  # re-revision mortality rate
  rrr = .04,
  
  # parameters for calculating primary revision rate
  cons = -5.49094,
  ageC = -.0367,
  maleC = .768536,
  lambda = exp(cons + ageC * age_init + maleC * sex),
  gamma = 1.45367786,
  
  rrNP1 = .260677,
  
  # revision probability of primary procedure
  standardRR = 1 - exp(lambda * ((markov_cycle - 1) ^ gamma -
                                   markov_cycle ^ gamma)),
  np1RR = 1 - exp(lambda * rrNP1 * ((markov_cycle - 1) ^ gamma - 
                                      markov_cycle ^ gamma)),
  
  # age-related mortality rate
  sex_cat = ifelse(sex == 0, "FMLE", "MLE"),
  mr = get_who_mr(age, sex_cat, country = "GBR", local = TRUE),
  
  # state values
  u_SuccessP = .85,
  u_RevisionTHR = .30,
  u_SuccessR = .75,
  c_RevisionTHR = 5294
)
param

#Now that parameters are defined, the probability transitions can be easily written:
mat_standard <- define_transition(
  state_names = c(
    "PrimaryTHR",
    "SuccessP",
    "RevisionTHR",
    "SuccessR",
    "Death"
  ),
  0, C, 0,          0, omrPTHR,
  0, C, standardRR, 0, mr,
  0, 0, 0,          C, omrRTHR+mr,
  0, 0, rrr,        C, mr,
  0, 0, 0,          0, 1
)
mat_standard

mat_np1 <- define_transition(
  state_names = c(
    "PrimaryTHR",
    "SuccessP",
    "RevisionTHR",
    "SuccessR",
    "Death"
  ),
  0, C, 0,          0, omrPTHR,
  0, C, np1RR,      0, mr,
  0, 0, 0,          C, omrRTHR+mr,
  0, 0, rrr,        C, mr,
  0, 0, 0,          0, 1
)
mat_np1

plot(mat_standard)

#Utilities and costs are then associated to states. In this model costs are discounted at a rate of 6% and utilities at a rate of 1.5%.
#Now that parameters, transition matrix and states are defined we can define the strategies for the control group and the NP1 treatment.
#We use define_starting_values() to take into account the cost of surgery.

strat_standard <- define_strategy(
  transition = mat_standard,
  PrimaryTHR = define_state(
    utility = 0,
    cost = 0
  ),
  SuccessP = define_state(
    utility = discount(u_SuccessP, .015),
    cost = 0
  ),
  RevisionTHR = define_state(
    utility = discount(u_RevisionTHR, .015),
    cost = discount(c_RevisionTHR, .06)
  ),
  SuccessR = define_state(
    utility = discount(u_SuccessR, .015),
    cost = 0
  ),
  Death = define_state(
    utility = 0,
    cost = 0
  ),
  starting_values = define_starting_values(
    cost = 394
  )
)
strat_standard

strat_np1 <- define_strategy(
  transition = mat_np1,
  PrimaryTHR = define_state(
    utility = 0,
    cost = 0
  ),
  SuccessP = define_state(
    utility = discount(u_SuccessP, .015),
    cost = 0
  ),
  RevisionTHR = define_state(
    utility = discount(u_RevisionTHR, .015),
    cost = discount(c_RevisionTHR, .06)
  ),
  SuccessR = define_state(
    utility = discount(u_SuccessR, .015),
    cost = 0
  ),
  Death = define_state(
    utility = 0,
    cost = 0
  ),
  starting_values = define_starting_values(
    cost = 579
  )
)
strat_np1

#Both strategies can now be run for 60 years. By default models are computed for 1000 person starting in PrimaryTHR.

res_mod <- run_model(
  standard = strat_standard,
  np1      = strat_np1,
  parameters = param,
  cycles = 60,
  cost = cost,
  effect = utility
)
summary(res_mod)

#The new treatment costs £1 more per QALY gained.

library(ggplot2)

plot(res_mod, type = "counts", panel = "by_state", free_y = TRUE) +
  theme_bw() +
  scale_color_brewer(
    name = "Strategy",
    palette = "Set1"
  )
