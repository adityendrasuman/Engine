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
  necessary.std = c("dplyr", "stringr"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

summary <- data.frame(matrix(ncol = 3, nrow = 0))
colnames(summary) <- c("variable", "value", "n")
pb <- txtProgressBar(min = 1, max = ncol(d_01_B), style = 3, width = 40)
print(glue::glue("Checking columns for one or more numeric responses..."))
i = 0

for (var in colnames(d_01_B)) {
  summary <- d_01_B %>%
    select(all_of(var)) %>%
    group_by_all() %>% 
    count() %>% 
    as.data.frame() %>% 
    rename(value = 1) %>% 
    mutate(variable = var) %>% 
    rbind(summary)
  
  i = i + 1
  setTxtProgressBar(pb, i)
}
close(pb)

summary <- summary %>% 
  filter(stringr::str_detect(value, "^[+-]?(\\d*\\.?\\d+|\\d+\\.?\\d*)$")) %>%
  select(-n, -value) %>% 
  group_by_all() %>% 
  count() %>% 
  as.data.frame() %>% 
  select(variable)

summary %>% 
  mutate(is_numeric = "Yes",
         outlier_min = "~",
         outlier_max = "~",
         na_values = "~") %>% 
  write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)

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

