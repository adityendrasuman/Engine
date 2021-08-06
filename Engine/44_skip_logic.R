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

# load librarise ----
error = f_libraries(
  necessary.std = c("dplyr", "glue", "gdata"),
  necessary.github = c()
)
glue::glue("RUNNING R SERVER ...") %>% print()
glue::glue("Package status: {error}") %>% print()
glue::glue("\n") %>% print()

# Log of run ----
glue::glue("===================== Running '44_skip_logic.R' =====================")
glue::glue("Uploads and analyses skip logic")
glue::glue("\n") %>% f_log_string(g_file_log)
#====================================================

map <- f_read_xl(g_file_path, namedRegion = "body_skip", colNames = F)

map <- map %>% 
  unique() %>% 
  select(check_var = X1,
         condition_var = X2,
         sign	= X3,
         response = X4,
         next_condition = X5) %>% 
  mutate(
    check_var_name = case_when(
      substr(check_var, 1, 4) == "All_" ~ ".+",
      T ~ check_var),
    next_condition = ifelse(is.na(next_condition), "", next_condition)
  )

# Figure out all the question numbers to apply the check on
question_numbers <- map %>% 
  pull(check_var) %>% 
  unique()

# Overall Summary...
skip_logic_log <- data.frame(matrix(ncol=8, nrow=0))
colnames(skip_logic_log) <- c("var_to_be_checked", "total_rows", "num_values", 
                              "rows_that_satisfy_condition", "num_violations",
                              "value_when_condition_unmet", "blank_when_condition_met",
                              "condition")

# Overall Summary...
d_skip <- data.frame(matrix(ncol=2, nrow=0))
colnames(d_skip) <- c("q_no", "condition")

# For each such question number ...
for (q_no in question_numbers) {
  # filter the skip logic table for rows that contain condition variable
  skip_filtered_for_q <- map %>% 
    filter(check_var == q_no)
  
  # number of condition variables
  num_conditions <- skip_filtered_for_q %>% 
    nrow()
  
  # initialise condition text
  condition <- ""
  
  # for each condition ...
  for (i in 1:num_conditions){
    
    # get variable on which to apply the check 
    q <- skip_filtered_for_q[i, "check_var_name"]
    
    # get condition variable 
    var <- skip_filtered_for_q[i, "condition_var"]
    
    if (!is.na(var)){
      
      # get relation between condition variable and the values
      sign <- skip_filtered_for_q[i, "sign"]
      
      # get all allowed values of condition variable, i.e. response vector
      response_vector <- skip_filtered_for_q[i, "response"] %>% 
        strsplit(split = "\\|") %>% 
        gdata::trim() %>% 
        unlist()
      
      # calculate size of this response vector
      num_response <- length(response_vector)
      
      # check if response vector is numeric or charecter
      response_is_string <- response_vector %>% 
        as.numeric() %>% 
        is.na() %>%
        suppressWarnings() %>% 
        sum()
      
      if (num_response > 1){
        if (response_is_string > 0){
          
          # if more than one response in string format, create c("a", "b", "c")
          str <- paste(response_vector, collapse = '", "')
          response_string <- glue::glue('c("{str}")') 
        } else {
          
          # if more than one response in numeric format, create c(1, 3, 5, 9) 
          str <- paste(response_vector, collapse = ', ')
          response_string <- glue::glue('c({str})')
        }
      } else {
        
        # if a single response ...
        if (sign == "not in") {sign == "!="}
        if (sign == "in") {sign == "=="}
        if (response_is_string > 0){
          
          # ... in string format, create "a"
          str <- response_vector[1]
          response_string <- glue::glue('"{str}"')
        } else {
          
          # ... in numeric format, create 1
          str <- response_vector[1]
          response_string <- glue::glue('{str}')
        }
      }
    }
    
    # get the & / | info before connecing the next condition 
    next_condition <- skip_filtered_for_q[i, "next_condition"]    
    
    # apend to previous condition and make it redy to append the condition string using the "next condition" string
    if (!is.na(var)){
      if (sign == "not in") {
        condition <- glue::glue("{condition} !({var} %in% {response_string}) {next_condition}")
      } else if(sign == "in") {
        condition <- glue::glue("{condition} {var} %in% {response_string} {next_condition}")
      } else {
        condition <- glue::glue("{condition} {var} {sign} {response_string} {next_condition}")
      }
    } else {
      condition <- glue::glue("{condition} {next_condition}")
    }
  }
  
  multiple_q = ifelse(substr(q_no,(nchar(q_no)+1)-1,nchar(q_no))=="_", T, F)
  
  apply_condn_on_data <- d_02 %>% 
    mutate(
      value = ifelse(is.na(eval(parse(text=condition))), F, eval(parse(text=condition))),
      condition = ifelse(value, "met", "un-met")
    )
  
  if (multiple_q == T){
    apply_condn_on_data <- apply_condn_on_data %>% 
      mutate(response = ifelse(rowSums(select(apply_condn_on_data, matches(q)) != "", na.rm=T) == 0, "blank", "value"))
  } else {
    apply_condn_on_data <- apply_condn_on_data %>% 
      mutate(response = ifelse(rowSums(select(apply_condn_on_data, all_of(q)) != "", na.rm=T) == 0, "blank", "value"))
  }
  
  row_count <- apply_condn_on_data %>% 
    nrow()
  
  value_count <- apply_condn_on_data %>% 
    filter(response == "value") %>% 
    nrow()
  
  met_count <- apply_condn_on_data %>% 
    filter(condition == "met") %>% 
    nrow()
  
  error_count <- apply_condn_on_data %>% 
    filter((response == "blank" & condition == "met") |
             (response == "value" & condition == "un-met")) %>% 
    nrow()
  
  value_when_cond_unmet <- apply_condn_on_data %>% 
    filter(response == "value" & condition == "un-met") %>% 
    nrow()
  
  blank_when_cond_met <- apply_condn_on_data %>% 
    filter(response == "blank" & condition == "met") %>% 
    nrow()
  
  skip_logic_log2 <- data.frame(var_to_be_checked = q_no, 
                               total_rows = row_count, 
                               num_values = value_count,
                               rows_that_satisfy_condition = met_count,
                               num_violations = error_count,
                               value_when_condition_unmet = value_when_cond_unmet,
                               blank_when_condition_met = blank_when_cond_met,
                               condition = condition) 
  
  skip_logic_log <- skip_logic_log %>% 
    rbind(skip_logic_log2)

  
  d_skip <- data.frame(q_no = q_no, 
                       condition = condition) %>%
    rbind(d_skip)
}

skip_logic_log %>%
  select(var_to_be_checked, 
         num_values,
         num_violations,
         value_when_condition_unmet,
         blank_when_condition_met,
         condition) %>%
  write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)

#====================================================

# Log of run ----
glue::glue("finished run in {round(Sys.time() - start_time, 0)} secs") %>% f_log_string(g_file_log)
glue::glue("\n\n") %>% f_log_string(g_file_log)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))

print(glue::glue("\n\nAll done!"))
for(i in 1:3){
  print(glue::glue("Finishing in: {4 - i} sec"))
  Sys.sleep(1)
}
