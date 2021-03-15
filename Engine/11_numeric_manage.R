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
  necessary.std = c("glue", "dplyr", "rlang"),
  necessary.github = c()
)
print(glue::glue("RUNNING R SERVER..."))
print(glue::glue("Package status: {error}"))
print(glue::glue("=============================================="))
#====================================================

print(glue::glue("Picking inputs on numeric columns from the excel interface..."))
map <- openxlsx::read.xlsx(g_file_path, namedRegion = "body_numeric", colNames = F) %>% 
  unique()%>% 
  filter_all(any_vars(!is.na(.)))

print(glue::glue("Ensuring all numeric columns are logged correctly..."))

numb <- map %>% 
  filter(X2 == "Yes")
var_numeric <- numb[["X1"]]

d_01_non_na <- d_01

if (length(var_numeric) > 0){
  for (var in var_numeric){
    
    var_sym <- var %>% rlang::sym()
    
    tryCatch(
      {
        # try part
        d_01[,var] = as.numeric(d_01[,var])
      },
      warning = function(w){
        # catch part
        print(glue::glue("Warning generated while translating '{var}' as numeric: {w}"))
        print(glue::glue("!! Values in numeric column '{var}' that generated 'NA':"))
        temp_data %>% 
          select(var) %>%
          table() %>% 
          as.data.frame() %>% 
          select(Value = 1, Freq) %>% 
          filter(stringr::str_detect(Value, "^[+-]?(\\d*\\.?\\d+|\\d+\\.?\\d*)$", negate = T)) %>%
          filter(stringr::str_detect(Value, "^\\s*$", negate = T)) %>%
          print()
        print(glue::glue("-------------------------"))
        return(NULL)
      },
      finally={
        # do part
        d_01 <- d_01 %>% 
          mutate(!!var_sym := ifelse(str_detect(!!var_sym, "^[+-]?(\\d*\\.?\\d+|\\d+\\.?\\d*)$", negate = T) &
                                     stringr::str_detect(!!var_sym, "^\\s*$", negate = T), "99999999", !!var_sym))
        
        d_01[,var] <- as.numeric(d_01[,var]) %>%
          suppressWarnings()
      }
    )
  }
}

char <- map %>% 
  filter(X2 == "No")
var_char <- char[["X1"]]

if (length(var_char) > 0){
  for (var in var_char){
    d_01[,var] = as.character(d_01[,var])
  }
}

print(glue::glue("Identifying NA responses..."))        # TODO ----
map_na <- map %>% 
  filter(X5 != "~")
var_na <- map_na[["X1"]]


print(glue::glue("Replacing outlier responses with NA entries..."))

outlier <- map %>% 
  filter(X2 == "Yes") %>% 
  mutate(X3 = ifelse(X3 == "~", -1000000000000000, X3),
         X4 = ifelse(X4 == "~", 1000000000000000, X4))

var_outlier <- outlier[["X1"]]

if (length(var_outlier) > 0){
  
  pb <- txtProgressBar(min = 1, max = max(length(var_outlier), 2), style = 3, width = 40)

  summary <- data.frame()
  
  for (i in 1:length(var_outlier)){
    
    var <- var_outlier[i]
    
    min_    <- min(d_01[, var], na.rm = T)
    mean_   <- mean(d_01[, var], na.rm = T)
    median_ <- median(d_01[, var], na.rm = T)
    max_    <- max(d_01[, var], na.rm = T)
    sd_     <- sd(d_01[, var], na.rm = T)
    th1_     <- as.numeric(outlier[outlier$X1 == var, "X3"])
    th2_     <- as.numeric(outlier[outlier$X1 == var, "X4"])
    
    summary[i, "var"] <- var
    summary[i, "# Values"] <- nrow(filter(d_01, !is.na(d_01[, var])))
    summary[i, "# NAed"] <- nrow(filter(d_01, d_01[, var] < th1_)) + nrow(filter(d_01, d_01[, var] > th2_))
    summary[i, "% NAed"] <- paste0(round(100*summary[i, "# NAed"]/nrow(filter(d_01, !is.na(d_01[, var]))),2), "%")
    summary[i, "min"] <- round(min_, 2)
    summary[i, "mean - 3 SD"] <- round(mean_ - 3*sd_, 2)
    summary[i, "mean"] <- round(mean_, 2)
    summary[i, "median"] <- round(median_, 2)
    summary[i, "mean + 3 SD"] <- round(mean_ + 3*sd_, 2)
    summary[i, "max"] <- round(max_, 2)
    summary[i, "count below -3SD"] <- nrow(filter(d_01, d_01[, var] < mean_ - 3*sd_))
    summary[i, "count above +3SD"] <- nrow(filter(d_01, d_01[, var] > mean_ + 3*sd_))
    
    d_01[, var] <- ifelse(d_01[, var] < th1_ | d_01[, var] > th2_, 99999999, d_01[, var])
    setTxtProgressBar(pb, i)
  }
  close(pb)
  
  if (nrow(summary) > 0) {
    summary %>% 
      write.table(file = file.path("temp.csv"), sep=",", col.names = F, row.names = F)
  }
}


Sys.sleep(5)

#====================================================

# Acknowledgement of run ----
log_file = "log - numeric_manage.txt"
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

