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
add_to_skip <- function(data, y, ...){
  data <- data %>% 
    rbind(data.frame(new = y, old = c(...)))
}

create_new_col <- function(df_in){
  
  df_out <- df_in
  
  # Container to hold skip logic for additional columns 
  df_skip_info <- data.frame(matrix(ncol=2, nrow=0))
  colnames(df_skip_info) <- c("new", "old")
  
  # ++++++++++++++++++++++++++START OF SPACE FOR DEFINING NEW COLUMNS++++++++++++++++++++++++++
  
  # C00: Unit weight ----
  df_out <- df_out %>% 
    mutate(
      z_weight = 1
    )
  
  df_out %>% 
    select(z_weight) %>% 
    f_grouper()
  
  df_skip_info <- df_skip_info %>% 
    add_to_skip ("z_D_awareness_portability", "T")
  
  # ++++++++++++++++++++++++++ END OF SPACE FOR DEFINING NEW COLUMNS ++++++++++++++++++++++++++
  return (list(df_out, df_skip_info))
  
  
}



   