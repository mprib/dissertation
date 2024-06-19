
library(dplyr)
library(emmeans)
library(car)
library(MASS)

get_simulated_data <- function(n,
                               conditions,
                               pre_means, 
                               pre_std_devs,
                               post_means,
                               post_std_devs,
                               correlation = 0.7
                               ) {
  
  all_simulated_data = list()
 

  for (cond in conditions) {
    # Generate correlated pre and post data
    means <- c(pre_means[[cond]], post_means[[cond]])
    std_devs <- c(pre_std_devs[[cond]], post_std_devs[[cond]])
    
    sigma <- matrix(c(std_devs[1]^2, correlation * std_devs[1] * std_devs[2],
                      correlation * std_devs[1] * std_devs[2], std_devs[2]^2),
                    nrow = 2, byrow = TRUE)
    
    obs_data <- mvrnorm(n, mu = means, Sigma = sigma)
    
    
    for (per in list("pre", "post")) {
      # Generate data
      condition <- as.factor(rep(cond, n))
      period <- as.factor(rep(per, n))
      participant <- seq_len(n)
      
      if (per == "pre") {
        observation <- obs_data[, 1]
      } else {
        observation <- obs_data[, 2]
      }
      
      all_simulated_data[[paste(cond, per)]] = data.frame(participant,
                                                          condition,
                                                          period,
                                                          observation)
      
    }
    
  }
  
  merged_data = do.call(rbind, all_simulated_data)

  return(merged_data)

}


simulate_aim <- function(n, conditions, pre_means, pre_std_devs, post_means, post_std_devs, effect_name){

    
    simulated_data = get_simulated_data(n, 
                       conditions = conditions,
                       pre_means=pre_means, 
                       pre_std_devs=pre_std_devs,
                       post_means = post_means, 
                       post_std_devs=post_std_devs
                       )
   
    # browser()
    
    model <-  aov(observation ~ condition * period  , data = simulated_data)
    
    anova_table = summary(model)[[1]]
    
    # Find the row corresponding to the effect name
    effect_row <- trimws(rownames(anova_table)) == effect_name
    
    # Extract the p-value for the effect
    effect_p_value <- anova_table[effect_row, "Pr(>F)"]
    
    # browser()
    # Check post hoc tests for interaction: pre vs. post within each condition
    emm <- emmeans(model, ~condition*period)
    post_hoc <- summary(contrast(emm, "pairwise", by = "condition"))
    p_values <- post_hoc$p.value
    adjusted_p_values <- p.adjust(p_values, method = "bonferroni")
   
    post_hoc_success = all(adjusted_p_values < .05)
    
    # do the check of the hypothesis
    if (all(effect_p_value < 0.05,  post_hoc_success)){
        success <- TRUE
    } else {
      success <-FALSE
    }
    
    return(success)

}

