# cleanup the environment ----
rm(list = ls())
if (!is.null(dev.list())) dev.off()
cat("\014")
start_time <- Sys.time()

# capture variable coming from vba ----
args <- commandArgs(trailingOnly=T)

# set working director ---- 
setwd(do.call(file.path, as.list(strsplit(args[1], "\\|")[[1]])))

# load environment ----
load("env.RData")

# load libraries ----
error = f_libraries(
  necessary.std = c("glue", "dplyr"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

d_01_B <- d_01_A

print(glue::glue("Importing 'Live Capture' column names from the excel interface..."))
col_list <- openxlsx::read.xlsx(g_file_path, namedRegion = "body_OHE_input", colNames = F)

col_list %>% nrow() %>% print()

Sys.sleep(3)



# vars <- clean_df_3 %>% 
#   select(matches(".*_o[0-9]+$")) %>% 
#   colnames()
# 
# vars_unique <- vars %>% 
#   str_replace("_o[0-9]+$", "_o") %>% 
#   unique()
# 
# pb <- txtProgressBar(min = 1, max = length(vars)+100, style = 3, width = 40)
# print("creating one-hot encoding...")
# j <- 1
# 
# for (var in vars_unique) {
#   
#   # create a variable temp_all_values in the main file that combines values from all relevant variables 
#   
#   table_with_relevant_cols <- clean_df_3 %>% 
#     select(x_interview_id, matches(paste0(var, "[0-9]+$"))) %>% 
#     mutate(temp_all_values = "")
#   
#   for (i in 1:(ncol(table_with_relevant_cols) - 2)){
#     table_with_relevant_cols <- table_with_relevant_cols %>% 
#       mutate(temp_all_values = paste0(temp_all_values, 
#                                       ifelse(is.na(.[, i+1]) | .[, i+1] == "",
#                                              "", paste0("|", make_col_names(.[, i+1]))
#                                       )
#       )
#       )
#   }
#   
#   table_with_relevant_cols <- table_with_relevant_cols %>% 
#     select(x_interview_id, temp_all_values)
#   
#   clean_df_3 <- clean_df_3 %>%  
#     left_join(table_with_relevant_cols, by = "x_interview_id")
#   
#   var_values <- clean_df_3 %>% 
#     select(matches(paste0(var, "[0-9]+$"))) %>% 
#     unlist() %>% 
#     table() %>% 
#     data.frame() %>% 
#     select("value" = 1, "freq" = 2) %>% 
#     filter(!is.na(value)) %>% 
#     filter(value != "") %>% 
#     filter(value != "{0}") %>% 
#     mutate(value_colnames = make_col_names(value)) %>% 
#     mutate(value = as.character(value))
#   
#   num_var_values <- var_values %>% 
#     nrow()
#   
#   for (i in 1:num_var_values){
#     
#     var_new <- var %>% 
#       paste0(i, "_", var_values[i, "value_colnames"]) %>% 
#       str_replace("x_", "z_") %>% 
#       rlang::sym()
#     
#     search_term = var_values[i, "value_colnames"]
#     
#     clean_df_3 <- clean_df_3 %>% 
#       mutate(!!var_new := case_when(
#         str_detect(temp_all_values, search_term) ~ "True",
#         trimws((str_remove_all(temp_all_values, "|"))) != "" ~ "False",
#         TRUE ~ ""
#       )
#       )
#     
#     setTxtProgressBar(pb, j)
#     
#     j = j + 1
#   }
#   
#   summary <- clean_df_3 %>%
#     select(temp_all_values, matches(str_replace(var, "x_", "z_"))) %>%
#     grouper()
#   
#   colnames(summary) <- str_replace(colnames(summary), str_replace(var, "x_", "z_"), "")
#   
#   summary %>%
#     logtable(as.character(var))
#   
#   clean_df_3 <- clean_df_3 %>% 
#     select(-temp_all_values)
# }
# close(pb)


#====================================================

# Log of run ----
cat(glue::glue("===================== Running '08_oh_encoding.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code broke a list of 'Live-Capture' columns provided in the excel interface into constituent columns with Yes/No values"), 
    file=g_file_log, sep="\n", append=TRUE)

total_time = Sys.time() - start_time
cat(glue::glue("finished run in {round(total_time, 0)} secs"), 
    file=g_file_log, sep="\n", append=TRUE)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))
