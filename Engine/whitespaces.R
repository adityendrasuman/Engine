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
print(error)
#====================================================

cols_to_be_rectified <- names(d_01)[vapply(d_01, is.character, logical(1))]
d_01[,cols_to_be_rectified] <- lapply(d_01[,cols_to_be_rectified], trimws)

weird_chr <- paste(c("^\\s+.+\\s+$", ".+\\s+$", "^\\s+.+$"), collapse = "|")
summary <- f_id_char(d_01, weird_chr)

if(is.null(nrow(summary))) {
  print("No leading or lagging white spaces")
} else if(nrow(summary) > 0) {
  print("White spaces could not be removed...")
  print("Please remove manually in the raw data")
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