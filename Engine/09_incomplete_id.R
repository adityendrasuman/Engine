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

# load librarise ----
error = f_libraries(
  necessary.std = c("dplyr", "purrr", "stringr"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Searching for strings with over 30 characters..."))

list_of_variables <- d_01_B %>%
  colnames()

summary <- purrr::map_dfr(list_of_variables, function(var) {
  
  temp <- d_01_B %>%
    pull(!!var) %>%
    nchar() %>%
    max(na.rm = TRUE)
  
  if (temp >= 30) {
    d_01_B %>%
      select(response = !!var) %>%
      count(response) %>%
      mutate(no_of_char = nchar(response),
             variable = var) %>%
      filter(no_of_char >= 30) %>%
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

Sys.sleep(0)

#====================================================

# Acknowledgement of run ----
log_file = "log - incomplete.txt"
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

