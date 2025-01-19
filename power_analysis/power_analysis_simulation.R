
library(dplyr)
library(emmeans)
library(car)
library(MASS)
library(lme4)



get_simulated_data <- function(n,
                               conditions,
                               pre_means, 
                               pre_std_devs,
                               post_means,
                               post_std_devs,
                               correlation = 0.9
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




simulate_aim <- function(n, conditions, pre_means, pre_std_devs, post_means, post_std_devs, correlation, FastPropOnly){

    
    simulated_data = get_simulated_data(n, 
                       conditions = conditions,
                       pre_means=pre_means, 
                       pre_std_devs=pre_std_devs,
                       post_means = post_means, 
                       post_std_devs=post_std_devs,
                       correlation = correlation
                       )
    
    
    # Prepare data for lmer
    simulated_data$participant <- factor(simulated_data$participant)
    simulated_data$condition <- factor(simulated_data$condition)
    simulated_data$period <- factor(simulated_data$period)
    
    model <- lmer(observation ~ period * condition + (1|participant), 
                 data = simulated_data)
    
    # Compute estimated marginal means
    emm <- emmeans(model, specs = ~ period | condition)
    
    # Pairwise comparisons of Period within each Condition
    period_comparisons <- pairs(emm, simple = "period", adjust="holm")
    #p_values <- summary(period_comparisons)$p.value
    
    # Check if all pairwise comparisons are significant (p < 0.05)
    #successful_simulation <- all(p_values < 0.05) 
   
    
    if (FastPropOnly) {
      fastprop_comparison <- subset(period_comparisons, condition == "FastProp")
      summary(fastprop_comparison)
      successful_simulation <-  summary(subset(period_comparisons, condition == "FastProp"))$p.value < 0.05
      # browser()
    } else {
      # Extract p-values 
      p_values <- summary(period_comparisons)$p.value
      
      # Check if all pairwise comparisons are significant (p < 0.05)
      successful_simulation <- all(p_values < 0.05) 
      
    }
    
    return(successful_simulation)
}


