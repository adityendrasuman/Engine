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
  necessary.std = c("dplyr", "stringr", "openxlsx"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Picking suggestions for weird characters from the excel interface..."))
supplied_weird_chr <- openxlsx::read.xlsx(g_file_path, namedRegion = "wc1_R", colNames = F)

weird_chr <- paste(c("[^\x01-\x7F]", supplied_weird_chr[[1]]), collapse = "|")

print(glue::glue("Searching for weird characters..."))
summary <- f_id_char(d_01, weird_chr)

summary %>% 
  write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)

Sys.sleep(0)

#====================================================

# Acknowledgement of run ----
log_file = "log - weird_chars_id.txt"
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

