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
  necessary.std = c("openxlsx", "glue"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Importing raw data from the excel interface..."))
d_01 <- openxlsx::read.xlsx(g_file_path, namedRegion = "raw_data", colNames = T)
print(glue::glue("Imported data has {ncol(d_01)} columns and {nrow(d_01)} rows"))

Sys.sleep(3)
#====================================================

# Log of run ----
cat(glue::glue("===================== Running '04_upload_rd.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code uploads raw data into R"), 
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