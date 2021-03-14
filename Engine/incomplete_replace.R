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
  necessary.std = c("dplyr", "stringr", "openxlsx", "rlang"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER ..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Picking mapping for incomplete responses from the excel interface..."))
map <- openxlsx::read.xlsx(g_file_path, namedRegion = "incomplete_R", colNames = F) %>% 
  filter(X3 != "--") %>% 
  unique()

if (nrow(map) == 0){
  print(glue::glue("Your input indicates no incomlete response"))
} else {
  print(glue::glue("Replacing incomplete responses..."))
  
  for (var in unique(map[, "X1"])){
    
    names <- map %>% 
      filter(X1 == var) %>% 
      select(X2) 
    
    for (name in names[[1]]){
      
      n_row_old <- d_01 %>% 
        select(var) %>% 
        filter(!!rlang::sym(var) == name) %>% 
        nrow()
      
      value <- map[map$X2 == name, "X3"]
      d_01[, var] <- ifelse(d_01[, var] == name, value, d_01[, var])
      
      n_row_old_after <- d_01 %>% 
        select(var) %>% 
        filter(!!rlang::sym(var) == name) %>% 
        nrow()
      
      n_row_new <- d_01 %>% 
        select(var) %>% 
        filter(!!rlang::sym(var) == value) %>% 
        nrow()
      
      if (n_row_new == n_row_old & n_row_old_after == 0){
        print(glue::glue("Replaced {n_row_new} instances of '{name}' with '{value}'"))
      }
      
      if (n_row_new != n_row_old | n_row_old_after > 0){
        print(glue::glue("Could NOT replace '{name}' with '{value}'"))
      }
    }
  }
}

Sys.sleep(5)

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

