# cleanup the environment ----
rm(list = ls())
if (!is.null(dev.list())) dev.off()
cat("\014")
options(survey.lonely.psu = "adjust")

# capture variable coming from vba ----
args <- commandArgs(trailingOnly=T)
args <- c("C:|Users|adity|Dropbox (Dalberg)|INITIATIVES|EXCEL SURVEY v13|Temp|")

# set working director ---- 
setwd(do.call(file.path, as.list(strsplit(args[1], "\\|")[[1]])))

# load environment ----
load("env.RData")

# load librarise ----
error = f_libraries(
  necessary.std = c(),
  necessary.github = c()
)
print(error)
#====================================================

rm(list = ls(pattern = "^d_[0-9]+"))

#====================================================

# Acknowledgement of run ----
log_file = "log - clear_data.txt"
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

