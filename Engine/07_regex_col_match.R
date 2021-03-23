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
  necessary.std = c("glue", "dplyr", "stringr", "purrr"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))

# Log of run ----
cat(glue::glue("===================== Running '07_regex_col_match.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code identifies list of columns corresponding to the regex input for 'Live Capture'"), 
    file=g_file_log, sep="\n", append=TRUE)

#====================================================

print(glue::glue("Getting user input on Regex strings"))

if (args[3] == ""){args[3] = ".+"}

if (args[2] == "") {
  
  print(glue::glue("Incomplete user input found for the 'Live Capture' columns. Please provide reg-ex inputs and retry."))

} else {
  
  # Get column names and questions for OHE
  columns <- d_01_A %>% 
    select(matches(args[3])) %>% 
    colnames() %>% 
    unique() %>% 
    na.omit() %>% 
    as.list()
    
  questions <- d_01_A %>% 
    select(matches(args[3])) %>% 
    colnames() %>% 
    stringr::str_extract(args[2]) %>% 
    unique() %>% 
    na.omit() %>% 
    as.list()
  
  summary <- matrix(ncol=2,nrow=0) %>% 
    data.frame() %>% 
    select(column_category = 1, column = 2)
  
  # Check if regex is identifying one column under one question uniquely 
  for (q in questions) {
    
    summary <- summary %>% 
      rbind(d_01_A %>%
              select(matches(paste0("^.*", q, ".*$"))) %>%
              colnames() %>% 
              intersect(columns) %>% 
              unlist() %>% 
              as.data.frame() %>% 
              rename(column = 1) %>% 
              mutate(column_category = q) %>% 
              select(2, 1))
  }
  
  summary_temp <- summary %>% 
    select(2) %>% 
    group_by_all() %>% 
    count() %>% 
    as.data.frame() %>% 
    filter(n > 1)
  
  if (nrow(summary_temp) > 0){
    
    print(glue::glue("CRITICAL ERROR: Regex needs to be refined. It currently identifies same column under various groupings"))
    print(glue::glue("Such cases are highlighted in red cells"))

  } else {
    
    print(glue::glue("{} questions identified for conversion into OH Encoding"))
    print(glue::glue("SUCCESS: Regex could map columns uniquely - i.e. each 'Live Capture' column will be combined in only one question"))
    
  }
  
  summary %>% 
    write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)
  
}

#====================================================

total_time = Sys.time() - start_time
cat(glue::glue("finished run in {round(total_time, 0)} secs"), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("\n"), 
    file=g_file_log, sep="\n", append=TRUE)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))

# Close the R code
print(glue::glue("\n\nAll done!"))
for(i in 1:3){
  print(glue::glue("Finishing in: {4 - i} sec"))
  Sys.sleep(1)
}