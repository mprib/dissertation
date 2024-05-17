
library(dplyr)
library(emmeans)
library(car)

get_simulated_data <- function(n,
                               conditions,
                               pre_means, 
                               pre_std_devs,
                               post_means,
                               post_std_devs
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
          std_devs <- pre_std_devs
        } else {
          means <- post_means
          std_devs <- post_std_devs
        }
           
        mean = means[[cond]]
        std_dev = std_devs[[cond]]
        observation <- rnorm(n, mean = mean, sd = std_dev)
        all_simulated_data[[paste(cond, per)]] = data.frame(participant,
                                                condition,
                                                period,
                                                observation )
    }
    
  }
  
  merged_data = do.call(rbind, all_simulated_data)

  return(merged_data)

}


simulate_aim <- function(n, conditions, pre_means, pre_std_devs, post_means, post_std_devs){

    
    simulated_data = get_simulated_data(n, 
                       conditions = conditions,
                       pre_means=pre_means, 
                       pre_std_devs=pre_std_devs,
                       post_means = post_means, 
                       post_std_devs=post_std_devs)
   
    # browser()
    
    # Levene's test for homogeneity of variances
    # levene_test_result <- leveneTest(observation ~ condition * period, data = simulated_data)
    # print(levene_test_result) 
    
    model <-  aov(observation ~ condition * period  , data = simulated_data)
    
    # ugly but this gets the results of the F test on the interaction
    # powering the study to identify differences in impact of condition on 
    # changes across time periods
    interaction_effect_p_value <- summary(model)[[1]]$'Pr(>F)'[3]
    
    # browser()
    # Check post hoc tests for interaction: pre vs. post within each condition
    emm <- emmeans(model, ~condition*period)
    post_hoc <- summary(contrast(emm, "pairwise", by = "condition"))

    n_comparisons <- nrow(post_hoc)
   
    # browser()
    
    # penalize with bonferonni 
    post_hoc_adjusted_p_value <- post_hoc$p.value * n_comparisons
    post_hoc_success = all(post_hoc_adjusted_p_value < .05)
    
    # do the check of the hypothesis
    # if (all(interaction_effect_p_value<.05,  post_hoc_success)){
    if (post_hoc_success){
    # if (interaction_effect_p_value<.05){
      success <- TRUE
    } else {
      success <-FALSE
    }
    return(success)

}

