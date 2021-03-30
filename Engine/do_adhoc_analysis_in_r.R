# INSTRUCTIONS:
  # name of the input file: df_in
  # pipe operator:          %>% | (shortcut = ctrl+M) https://uc-r.github.io/pipe
  # create a new column:    mutate
  # if else condition:      case_when
  # (in)equality:           ==, >, <, <=, >=, %in%, |, &, is.na(), !
  # 

# SAMPLE:
  # df_out <- df_in %>% 
  #   mutate(new_var = case_when(
  #     old_var_1 %in% c("A", "B") ~ "Value 1",       Meaning: when old_var_1 is EITHER A OR B then new_var = Value 1
  #     !(old_var_2 %in% c("C", "D")) ~ "Value 2",    Meaning: else when old_var_2 is NEITHER C NOR D then new_var = value 2
  #     T                          ~ "value 3"        Meaning: else new_var = "Value 3"
  # ))

# DOING CHECKS AND GETTING DATA:
if (!exists("d_01_D") | !is.data.frame(d_01_D)){}





create_new_col <- function(df_in){
  
  # ########################################
  # FORMULA FOR NEW COLUMNS IN THIS SECTION:
  
  
  
  
  
  # ########################################
  return (df_out)
}
