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
  necessary.std = c("dplyr", "stringr", "openxlsx"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Picking mapping for weird characters from the excel interface..."))
map <- openxlsx::read.xlsx(g_file_path, namedRegion = "wc3_R", colNames = F) %>% 
  unique() %>% 
  filter_all(any_vars(!is.na(.)))

d_01_A <- d_01

i = 0
pb <- txtProgressBar(min = 1, max = ncol(d_01_A), style = 3, width = 40)
print(glue::glue("Replacing weird characters..."))

for (var in colnames(d_01_A)){
  for (name in map[,"X1"]){
    
    value <- map[map$X1 == name, "X2"]
      
    d_01_A[, var] <- gsub(name, value, d_01_A[, var])  
  }
  i = i + 1
  setTxtProgressBar(pb, i)
}
close(pb)

print(glue::glue("Double checking..."))
supplied_weird_chr <- openxlsx::read.xlsx(g_file_path, namedRegion = "wc1_R", colNames = F)
weird_chr <- paste(c("[^\x01-\x7F]", supplied_weird_chr[[1]]), collapse = "|")
summary <- f_id_char(d_01_A, weird_chr)

if(is.null(nrow(summary))) {
  print(glue::glue("Any occurance of weird characters has been replaced"))
} else if(nrow(summary) > 0) {
  print(glue::glue("All occurances of weird characters could not be removed."))
  print(glue::glue("Please check log file for the values that could not be removed"))
  print(glue::glue("Please remove manually in the raw data and upload it again"))
}

Sys.sleep(3)

#====================================================

# Log of run ----
cat(glue::glue("===================== Running '07_weird_chars_replace.R' ====================="), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("This code attempts to remove unrecognised characters from the data, based on user suggestions in the excel interface"), 
    file=g_file_log, sep="\n", append=TRUE)

f_log_table(summary, "List of Unrecognised Characters that could not be removed", g_file_log)

total_time = Sys.time() - start_time
cat(glue::glue("finished run in {round(total_time, 0)} secs"), 
    file=g_file_log, sep="\n", append=TRUE)

cat(glue::glue("\n"), 
    file=g_file_log, sep="\n", append=TRUE)

# remove unnecessary variables from environment ----
rm(list = setdiff(ls(), ls(pattern = "^(d_|g_|f_)")))

# save environment in a session temp variable ----
save.image(file=file.path(g_wd, "env.RData"))