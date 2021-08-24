# INSTRUCTIONS:
  # name of the input file: df_in
  # pipe operator:          %>% | (shortcut = ctrl+M) https://uc-r.github.io/pipe
  # create a new column:    mutate
  # if else condition:      case_when
  # (in)equality:           ==, >, <, <=, >=, %in%, |, &, is.na(), !


# ************* For manual run, Run this part ***************
library(rstudioapi)
file_loc <- dirname(rstudioapi::getActiveDocumentContext()$path)
load(file.path(file_loc,"env.RData"))
error = f_libraries(
  necessary.std = c("dplyr"),
  necessary.github = c()
)
df_in <- d_01_D
# ******************** End of manual run *********************

# #####################################################################
# DO NOT ADD ANY NEW LINE TILL HERE. MAIN CODE SHOULD START AT LINE 23
# #####################################################################

create_new_col <- function(df_in){
  
  df_out <- df_in
  
  # ****************************************
  # FORMULA FOR NEW COLUMNS IN THIS SECTION:
  
  # EXAMPLE:
  # df_out <- df_out %>% 
  #   mutate(new_var = case_when(
  #     old_var_1 %in% c("A", "B") ~ "Value 1",       Meaning: when old_var_1 is EITHER A OR B then new_var = Value 1
  #     !(old_var_2 %in% c("C", "D")) ~ "Value 2",    Meaning: else when old_var_2 is NEITHER C NOR D then new_var = value 2
  #     T                          ~ "value 3"        Meaning: else new_var = "Value 3"
  # ))
  # ****************************************
  
  # ++++++++++++++++++++++++++START OF SPACE FOR DEFINING NEW COLUMNS++++++++++++++++++++++++++
  
  # C00: <Describe column being created> ----
  
  
  # C01: <Describe column being created> ----
  
  
  
  
  
  
  # ++++++++++++++++++++++++++ END OF SPACE FOR DEFINING NEW COLUMNS ++++++++++++++++++++++++++
  return (df_out)
}

   