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
  necessary.std = c("dplyr", "openxlsx", "rlang"),
  necessary.github = c()
)
print(error)
#====================================================

print("Importing summariser info ...")
d_summ <- openxlsx::read.xlsx(g_file_path, namedRegion = "all_summ", colNames = T, rowNames = T)

for (name1 in colnames(d_summ)){
  name_sym <- name1 %>% 
    rlang::sym()
  
  filled <- d_summ %>% 
    filter(!is.na(!!name_sym), !(!!name_sym %in% c("", " ", "-"))) %>% 
    nrow()
  
  if (filled == 0) {
    d_summ <- d_summ %>% select(-all_of(name1))
    print(paste0("summariser '", name1, "' is blank and hence dropped"))
  }
  
  if (filled == 1 | filled == 2) {
    print(paste0("summariser '", name1, "' is incomplete. It will not be loaded"))
    d_summ <- d_summ %>% select(-all_of(name1))
  }
  
  if (filled == 3) {
    print(paste0("summariser '", name1, "' loaded"))
  }
}

Sys.sleep(3)
#====================================================

# Acknowledgement of run ----
log_file = "log - upload_summ.txt"
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

