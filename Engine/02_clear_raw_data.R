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

source(file.path(g_excel_backend_temp_nospace_dir_rf, "00_functions.R"))

# load librarise ----
error = f_libraries(
  necessary.std = c(),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

rm(list = ls(pattern = "^d_[0-9]+"))
print(glue::glue("Success: All datasets deleted"))
Sys.sleep(2)

#====================================================

# Log of run ----
cat(glue::glue("===================== Running '03_clear_raw_data.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code deletes raw data and all subsequent datasets from R"), 
    file=g_file_log, sep="\n", append=TRUE)

total_time = Sys.time() - start_time
cat(glue::glue("finished run in {round(total_time, 0)} secs"), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("\n"), 
    file=g_file_log, sep="\n", append=TRUE)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))