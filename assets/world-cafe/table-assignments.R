library(ompr)
library(tidyr)
library(ompr.roi)
library(ROI.plugin.glpk)
library(dplyr)

# indices already defined:
# people, topics, I, T, R

get_weight <- function(i, t){
  person <- people[i]
  topic  <- topics[t]
  
  row <- df[df$Participant == person, ]
  
  if (row$R1 == topic) return(3)
  if (row$R2 == topic) return(2)
  if (row$R3 == topic) return(1)
  return(-1)
}

model <- MIPModel() %>%
  
  add_variable(x[i, t, r], i = I, t = T, r = R, type = "binary") %>%
  
  add_constraint(sum_expr(x[i, t, r], t = T) <= 1, i = I, r = R) %>%
  
 # add_constraint(sum_expr(x[i, t, r], i = I) >= 3, t = T, r = R) %>%
  add_constraint(sum_expr(x[i, t, r], i = I) <= 10, t = T, r = R) %>%
  
  add_constraint(sum_expr(x[i, t, r], t = T, r = R) <= 3, i = I) %>%
  
  set_objective(
    sum_expr(x[i, t, r] * get_weight(i, t), i = I, t = T, r = R),
    "max"
  )

result <- solve_model(model, with_ROI(solver = "glpk"))

solution <- get_solution(result, x[i,t,r]) %>%
  filter(value > 0.5)

final_assignment <- solution %>%
  mutate(
    Participant = people[i],
    Topic = topics[t],
    Round = paste0("Round ", r)
  ) %>%
  select(Participant, Topic, Round)

print(final_assignment)


table_matrix <- table_counts %>%
  pivot_wider(
    names_from = Topic,
    values_from = n_people,
    values_fill = 0
  )

print(table_matrix)

#rowSums(1, table_matrix)
#write.csv(table_matrix)


# Extend your df with new rows (same format: R1, R2, R3).
existing_assignments <- final_assignment
people <- df$Participant
topics <- sort(unique(c(df$R1, df$R2, df$R3)))

I <- seq_along(people)
T <- seq_along(topics)
R <- 1:3

fixed_people <- existing_assignments$Participant

for(k in 1:nrow(existing_assignments)) {
  
  person_name <- existing_assignments$Participant[k]
  topic_name  <- existing_assignments$Topic[k]
  round_num   <- as.numeric(gsub("Round ", "", existing_assignments$Round[k]))
  
  i_idx <- which(people == person_name)
  t_idx <- which(topics == topic_name)
  
  model <- model %>%
    add_constraint(x[i_idx, t_idx, round_num] == 1)
}

for(k in 1:nrow(existing_assignments)) {
  
  person_name <- existing_assignments$Participant[k]
  topic_name  <- existing_assignments$Topic[k]
  round_num   <- as.numeric(gsub("Round ", "", existing_assignments$Round[k]))
  
  i_idx <- which(people == person_name)
  t_fixed <- which(topics == topic_name)
  
  other_topics <- setdiff(T, t_fixed)
  
  for(t in other_topics) {
    model <- model %>%
      add_constraint(x[i_idx, t, round_num] == 0)
  }
}



