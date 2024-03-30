
library(dplyr)
library(emmeans)

get_simulated_data <- function(n,
                               conditions,
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


simulate_aim <- function(n, conditions, pre_means, pre_vars, post_means, post_vars){

    
    simulated_data = get_simulated_data(n, 
                       conditions = conditions,
                       pre_means=pre_means, 
                       pre_vars=pre_vars,
                       post_means = post_means, 
                       post_vars=post_vars)
    
    model <-  aov(observation ~ condition * period  , data = simulated_data)
    
    # ugly but this gets the results of the F test on the interaction
    # powering the study to identify differences in impact of condition on 
    # changes across time periods
    interaction_effect_p_value <- summary(model)[[1]]$'Pr(>F)'[3]
    
    
    # Planned comparison: pre vs. post within each condition
    emm <- emmeans(model, ~condition*period)
    planned_comparisons <- contrast(emm, "pairwise", by = "condition") %>% 
                           summary(adjust="bonferroni")
    
    planned_comparison_success = all(planned_comparisons$p.value<.05)
    
    # do the check of the hypothesis
    if (all(interaction_effect_p_value<.05,  planned_comparison_success)){
      success <- TRUE
    } else {
      success <-FALSE
    }
    return(success)

}

