# cleanup the environment ----
rm(list = ls())
if (!is.null(dev.list())) dev.off()
cat("\014")

# capture variable coming from vba ----
args <- commandArgs(trailingOnly=T)

# set working director ----
setwd(do.call(file.path, as.list(strsplit(args[1], "\\|")[[1]])))

# load environment ----
load("env.RData")

source(file.path(g_excel_backend_temp_nospace_dir_rf, "functions.R"))

# load libraries ----
error = f_libraries(
  necessary.std = c("purrr", "dplyr", "rlang", "tidyselect", "tibble", "glue", "srvyr", "ggplot2"),
  necessary.github = c()
)
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================
question_creator <- function(query, i){
  
  # Get question row
  q <- query %>% 
    slice(i)
  
  # Get summariser
  s <- q %>% 
    pull(5)
  
  # get y
  y <- q %>% 
    pull(3)
  
  # get x
  x <- q %>% 
    pull(4)
  
  # get y label
  y_label <- q %>% 
    pull(6)
  
  # get x label
  x_label <- q %>% 
    pull(7)
  
  condition <- d_skip %>% 
    filter(q_no == y) %>% 
    pull(condition)
  
  condition <- ifelse(is_empty(condition), "T", glue::glue("({trimws(condition)})"))
  
  question <- list(s, y, condition, x, x_label, y_label)
  return(question)
}

graph <- list()

if (args[2] == "all") {
  
  query <- openxlsx::read.xlsx(g_file_path, namedRegion = "xy_one_one_all", colNames = T, rowNames = F) %>% 
    filter(!is.na(sl)) %>% 
    filter(sl != "")
  
  pb <- txtProgressBar(min = 0, max = nrow(query), style = 3, width = 40)
  
  for (row in 1:nrow(query)){
    
    q <- query %>% 
      question_creator(row)
    
    answer <- d_02 %>% 
      f_answer_creator(q[[1]], q[[2]], q[[3]], q[[4]]) %>% 
      suppressWarnings()
    
    numeric_y = ifelse(class(d_02[[q[[2]]]]) == "numeric", T, F)
    
    graph[[row]] <- answer %>% 
      f_graph_1(q[[4]], q[[5]], q[[6]], q[[3]], numeric_y)
    
    setTxtProgressBar(pb, row)
    
  }
  
} else {
  
  row = 1
  
  json_str <- gsub("~", '"', args[2]) 
  query <- jsonlite::fromJSON(json_str) %>% 
    mutate_all(na_if,"")
  
  q <- query %>% 
    question_creator(row)
  
  answer <- d_02 %>% 
    f_answer_creator(q[[1]], q[[2]], q[[3]], q[[4]]) %>% 
    suppressWarnings()
  
  numeric_y = ifelse(class(d_02[[q[[2]]]]) == "numeric", T, F)
  
  graph[[row]] <- answer %>% 
    f_graph_1(q[[4]], q[[5]], q[[6]], q[[3]], numeric_y)
  
}

graph %>% 
  f_plotter()

#====================================================

# Acknowledgement of run ----
log_file = "log - analysis_1.txt"
unlink(log_file)
cat("... Run completed", file=log_file, sep="\n", append=TRUE)
cat(glue::glue("environment contains: {sapply(ls(pattern = '^(d_|g_|f_)'), toString)}"),
    file=log_file, sep="\n", append=TRUE)
cat(glue::glue("error: {error}"), file=log_file, sep="\n", append=TRUE)
# shell.exec(log_file)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))

