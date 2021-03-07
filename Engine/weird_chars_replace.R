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
print(error)
#====================================================

map <- openxlsx::read.xlsx(g_file_path, namedRegion = "wc3_R", colNames = F) %>% 
  unique()

i = 0
pb <- txtProgressBar(min = 1, max = ncol(d_01), style = 3, width = 40)
print("Replacing weird characters...")

for (var in colnames(d_01)){
  for (name in map[,"X1"]){
    
    value <- map[map$X1 == name, "X2"]
      
    d_01[, var] <- gsub(name, value, d_01[, var])  
  }
  i = i + 1
  setTxtProgressBar(pb, i)
}
close(pb)

supplied_weird_chr <- openxlsx::read.xlsx(g_file_path, namedRegion = "wc1_R", colNames = F)
weird_chr <- paste(c("[^\x01-\x7F]", supplied_weird_chr[[1]]), collapse = "|")

summary <- f_id_char(d_01, weird_chr)

if(is.null(nrow(summary))) {
  print("No weird characters")
} else if(nrow(summary) > 0) {
  print("Weird characters could not be removed...")
  print("Please remove manually in the raw data")
}

Sys.sleep(3)

#====================================================

# Acknowledgement of run ----
log_file = "log - weird_chars_replace.txt"
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

