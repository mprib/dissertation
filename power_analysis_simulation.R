
library(dplyr)
library(emmeans)

get_simulated_data <- function(n,
                               conditions,
                               variable_name, 
                               pre_means, 
                               pre_vars,
                               post_means,
                               post_vars
                               ) {
  
  all_simulated_data = list()
 

  for (cond in conditions) {
    for (per in list("pre", "post")) {
    
        # Generate data
        condition <- as.factor(rep(cond, n))
        period <- as.factor(rep(per,n))
        participant <- seq_len(n)
        
        if (per == "pre") {
          means <- pre_means
          vars <- pre_vars
        } else {
          means <- post_means
          vars <- post_vars
        }
           
        mean = means[[cond]]
        var = vars[[cond]]
        observation <- rnorm(n, mean = mean, sd = sqrt(var))
        
        all_simulated_data[[paste(cond, per)]] = data.frame(participant,
                                                condition,
                                                period,
                                                observation )
    }
    
  }
  
  merged_data = do.call(rbind, all_simulated_data)

  return(merged_data)

}

conditions <- list( "cSBT", "FastProp", "FastBrake" )

# Aim 2

simulate_Aim2_SLR <- function(n){
    ## H1: SLR increases in each condition (powered to observe differences in effect size from cSBT)
    variable_name = "SLR"
    
    # healthy population...anticipate symmetry
    pre_means <-list(
      "cSBT" = 1,
      "FastProp" = 1,
      "FastBrake" = 1
    )
    
    post_means <-list(
      "cSBT" = 1.4, # from lauziere et al 2014
      "FastProp" = 1.2, # expect half impact
      "FastBrake" = 1.2 # expect half impact
    )
    
    # from Lauziere et al 2014
    pre_vars <-list(
      "cSBT" = .0036,
      "FastProp" = .0036,
      "FastBrake" = .0036
    )
    
    # from Lauzier et al 2014
    # makes sense as greater variance expected after adaptation
    post_vars <-list(
      "cSBT" = .07,
      "FastProp" = .07,
      "FastBrake" = .07
    )
    
    
    simulated_data = get_simulated_data(n, 
                       conditions = conditions,
                       variable_name = variable_name, 
                       pre_means=pre_means, 
                       pre_vars=pre_vars,
                       post_means = post_means, 
                       post_vars=post_vars)
    
    model <-  aov(observation ~ condition * period  , data = simulated_data)
    
    ## ugly but this gets the results of the F test on the interaction
    interaction_effect_p_value <- summary(model)[[1]]$'Pr(>F)'[3]
    
    
    emm <- emmeans(model, ~condition*period)
    # Planned comparison: pre vs. post within each condition
    planned_comparisons <- contrast(emm, "pairwise", by = "condition") %>% 
                           summary(adjust="bonferroni")
    
    H1_success = all(planned_comparisons$p.value<.05)
    
    # do the check of the hypothesis
    if (all(interaction_effect_p_value<.05, H1_success)){
      success <- TRUE
    } else {
      success <-FALSE
    }
    return(success)

}

# Mac, start here and build out iterations on this to keep incrementing success rate until
# it is > .95
success_count = 0
success_rate = 0
n = 20
for (i in 1:20) {
  success = simulate_Aim2_SLR(n)
  if (success){
    success_count = success_count + 1
    success_rate = success_count / i
    print(paste("For n = ", n, "Success rate is ", success_rate, " on ", i, "runs"))
  }
   
}



## H2: Paretic PF Impulses move in different directions in FastBrake and FastProp
## Basically: interaction effect for FastBrake and FastProp and significant Difference

