library(heemod)

mat_mono <-define_transition(
  .721, .202, .067, .010,
  0,    .581, .407, .012,
  0,    0,    .750, .250,
  0,    0,    0,    1
)


plot(mat_mono)

rr <- 0.509

mat_comb <- define_transition(
  C, .202*rr, .067*rr, .010*rr,
  0,    C, .407*rr, .012*rr,
  0,    0,    C, .250*rr,
  0,    0,    0,    1
)

plot(mat_comb)

cost_zido <- 2278
cost_lami <- 2086 

state_A <-  define_state(
  cost_health = discount(2756,0.06),
  cost_drugs = discount(
    dispatch_strategy(
      mono = cost_zido,
      comb = cost_zido + cost_lami),0.06),
  cost_total = cost_health + cost_drugs,
  life_year = 1
    )
  
state_A


state_B <-  define_state(
  cost_health = discount(3052,0.06),
  cost_drugs = discount(
    dispatch_strategy(
      mono = cost_zido,
      comb = cost_zido + cost_lami),0.06),
  cost_total = cost_health + cost_drugs,
  life_year = 1
)

state_B

state_C <-  define_state(
  cost_health = discount(9007,0.06),
  cost_drugs = discount(
    dispatch_strategy(
      mono = cost_zido,
      comb = cost_zido + cost_lami),0.06),
  cost_total = cost_health + cost_drugs,
  life_year = 1
)

state_C

state_D <-  define_state(
  cost_health = 0,
  cost_drugs = 0,
  cost_total = 0,
  life_year = 0
)

state_D

strat_mono <- define_strategy(
  transition = mat_mono,
  state_A,
  state_B,
  state_C,
  state_D
)

strat_comb

strat_comb <- define_strategy(
  transition = mat_comb,
  state_A,
  state_B,
  state_C,
  state_D
)

strat_comb

res_mod <- run_model(
  mono = strat_mono,
  comb = strat_comb,
  cycles = 50,
  cost = cost_total,
  effect = life_year
)

summary(
  res_mod,
  threshold = c(1000,5000,6000,1e4)
)

library(ggplot2)

plot( res_mod,type = "counts", panel = "by_strategy") + 
  xlab ("Time") + 
  theme_bw() + 
  scale_color_brewer(name = "State", palette="Set1")

# Or by state:
plot( res_mod,type = "counts", panel = "by_state") + 
  xlab ("Time") + 
  theme_bw() + 
  scale_color_brewer(name = "Strategy", palette="Set1")

plot( res_mod,type = "values", panel = "by_value") + 
  xlab ("Time") + 
  theme_bw() + 
  scale_color_brewer(name = "Strategy", palette="Set1")

