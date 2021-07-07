# INSTRUCTIONS:
  # name of the input file: df_in
  # pipe operator:          %>% | (shortcut = ctrl+M) https://uc-r.github.io/pipe
  # create a new column:    mutate
  # if else condition:      case_when
  # (in)equality:           ==, >, <, <=, >=, %in%, |, &, is.na(), !

create_new_col <- function(df_in){
  
  df_out <- df_in
  # ########################################
  # FORMULA FOR NEW COLUMNS IN THIS SECTION:
  
  # SAMPLE:
  # df_out <- df_out %>% 
  #   mutate(new_var = case_when(
  #     old_var_1 %in% c("A", "B") ~ "Value 1",       Meaning: when old_var_1 is EITHER A OR B then new_var = Value 1
  #     !(old_var_2 %in% c("C", "D")) ~ "Value 2",    Meaning: else when old_var_2 is NEITHER C NOR D then new_var = value 2
  #     T                          ~ "value 3"        Meaning: else new_var = "Value 3"
  # ))
  
  # C01: -----
  df_out <- df_out %>% 
    mutate(state_new = "BIHAR")
  
  # C02: -----
  df_out <- df_out %>% 
    mutate(state_new_2 = "Uttar Pradesh")
  
  
  # ########################################
  return (df_out)
}
