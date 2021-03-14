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
  necessary.std = c("dplyr", "stringr", "openxlsx", "profvis"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Trimming whitespaces..."))
cols_to_be_rectified <- names(d_01)[vapply(d_01, is.character, logical(1))]
d_01[,cols_to_be_rectified] <- lapply(d_01[,cols_to_be_rectified], trimws)

whitespaces <- paste(c("^\\s+.+\\s+$", ".+\\s+$", "^\\s+.+$"), collapse = "|")
summary <- f_id_char(d_01, whitespaces)

if(is.null(nrow(summary))) {
  print(glue::glue("Any leading or lagging white spaces has been removed"))
} else if(nrow(summary) > 0) {
  print(glue::glue("All white spaces could not be removed"))
  print(glue::glue("Please remove manually in the raw data and upload it again"))
}

Sys.sleep(3)

#====================================================

# Acknowledgement of run ----
log_file = "log - whitespaces.txt"
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