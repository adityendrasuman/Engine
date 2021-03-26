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

# load librarise ----
error = f_libraries(
  necessary.std = c("dplyr", "purrr", "stringr"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("\n"))

#====================================================

threshold = as.numeric(args[2])

print(glue::glue("Searching for strings with {threshold} or more characters..."))

list_of_variables <- d_01_B %>%
  colnames()

summary <- purrr::map_dfr(list_of_variables, function(var) {
  
  temp <- d_01_B %>%
    pull(!!var) %>%
    nchar() %>%
    max(na.rm = TRUE)
  
  if (temp >= threshold) {
    d_01_B %>%
      select(response = !!var) %>%
      count(response) %>%
      mutate(no_of_char = nchar(response),
             variable = var) %>%
      filter(no_of_char >= threshold) %>%
      select(-n) %>%
      return()
  }
}) %>%
  select(variable, everything()) %>% 
  arrange(-no_of_char) %>%
  select(variable, response) %>%
  mutate(replacement = "~") %>% 
  filter(!stringr::str_detect(variable, "(_OTH|_OE)$"))

if (nrow(summary) > 0) {
  summary %>% 
    write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)
}

#====================================================

# Log of run ----
cat(glue::glue("===================== Running '09_incomplete_id.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code identifies potentially incomplete responses in the dataset by looking at responses longer than user-provided chars"), 
    file=g_file_log, sep="\n", append=TRUE)

# Log of run ----
glue::glue("finished run in {round(Sys.time() - start_time, 0)} secs") %>% f_log_string(g_file_log)
glue::glue("\n\n") %>% f_log_string(g_file_log)

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