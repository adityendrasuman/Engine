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
if (args[6] == "refresh") {
  load("env.RData")
}

# load custom functions ----
source(do.call(file.path, as.list(strsplit(paste0(args[2], "00_functions.R"), "\\|")[[1]])), 
       print.eval = TRUE, echo = F)

# load libraries ----
error = f_libraries(
  necessary.std = c("glue"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

# global variables ----
g_excel_backend_temp_dir            <- do.call(file.path, as.list(strsplit(args[1], "\\|")[[1]]))
g_excel_backend_temp_nospace_dir_rf <- do.call(file.path, as.list(strsplit(args[2], "\\|")[[1]]))
g_excel_frontend_dir                <- do.call(file.path, as.list(strsplit(args[3], "\\|")[[1]]))
g_excel_backend_dir                 <- do.call(file.path, as.list(strsplit(args[4], "\\|")[[1]]))
g_file_name                         <- args[5]

g_file_path                         <- file.path(g_excel_frontend_dir, g_file_name)
g_wd                                <- g_excel_backend_temp_dir

g_file_log                          <- file.path(g_excel_frontend_dir, "Latest R logs.txt")
g_file_plot                         <- file.path(g_excel_frontend_dir, "Latest plots.pdf")

unlink(g_file_log)
unlink(g_file_plot)

Sys.sleep(0)
#====================================================

# Log of run ----
cat(glue::glue("===================== Running '01_initialise.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This will initialise a blank environment with all the global variables"), 
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