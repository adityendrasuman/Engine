# INSTRUCTIONS:
  # name of the input file: df_in
  # pipe operator:          %>% | (shortcut = ctrl+M) https://uc-r.github.io/pipe
  # create a new column:    mutate
  # if else condition:      case_when
  # (in)equality:           ==, >, <, <=, >=, %in%, |, &, is.na(), !


# ************* For manual run, Run this part ***************
library(rstudioapi)
file_loc <- dirname(rstudioapi::getActiveDocumentContext()$path)
load(file.path(file_loc,"env.RData"))
error = f_libraries(
  necessary.std = c("dplyr"),
  necessary.github = c()
)
df_in <- d_01_D
# ******************** End of manual run *********************

# #####################################################################
# DO NOT ADD ANY NEW LINE TILL HERE. MAIN CODE SHOULD START AT LINE 23
# #####################################################################

create_new_col <- function(df_in){
  
  df_out <- df_in
  
  # ****************************************
  # FORMULA FOR NEW COLUMNS IN THIS SECTION:
  
  # EXAMPLE:
  # df_out <- df_out %>% 
  #   mutate(new_var = case_when(
  #     old_var_1 %in% c("A", "B") ~ "Value 1",       Meaning: when old_var_1 is EITHER A OR B then new_var = Value 1
  #     !(old_var_2 %in% c("C", "D")) ~ "Value 2",    Meaning: else when old_var_2 is NEITHER C NOR D then new_var = value 2
  #     T                          ~ "value 3"        Meaning: else new_var = "Value 3"
  # ))
  # ****************************************
  
  # C00: Delete due to skip logic issue ----
  df_out %>% nrow()
  
  df_out <- df_out %>%
    filter(!(vhl_seca_a1 %in% c("No")))
  df_out %>% nrow()
  
  
  df_out <- df_out %>% 
    filter(!(ServerId %in% c(4752036, 4776827, 4776845, 4776846, 4776984, 4776985)))
  df_out %>% nrow()
  
  
  # C00: Not vaccinated column ----
  # df_out <- df_out %>%
  #   mutate(gen_sec_e_e1 = case_when(
  #     gen_sec_e_e1 == "" & gen_sec_e_e1_shift == "No, I dont have any vaccine" ~ "No",
  #     T ~ gen_sec_e_e1
  #   ))

  df_out <- df_out %>%
    mutate(gen_sec_e_e1 = case_when(
      gen_sec_e_e1_shift == "No, I dont have any vaccine" ~ "No",
      T ~ gen_sec_e_e1
    ))
  
  df_out <- df_out %>%
    mutate(gen_sec_e_e2 = case_when(
      gen_sec_e_e1_shift == "No, I dont have any vaccine" ~ "Proxy",
      T ~ gen_sec_e_e2
    ))
  
  # RR: Commented the above 2 and added an alternate filter below
  df_out <- df_out %>%
    filter(!(gen_sec_e_e1_shift %in% c("Yes, I had my first dose", "Yes, I had both my doses")))
  df_out %>% nrow()
  
  df_out <- df_out %>%
    filter(gen_sec_e_e1 %in% c("Yes", "No"))
  df_out %>% nrow()
  
 
  # 
  # df_out <- df_out %>%
  #   filter(gen_sec_e_e3 %in% c("Yes", "No", ""))
  # df_out %>% nrow()
  
  
  # C01: weight calculation -----
  weight_data <- read.csv("C:\\Users\\User\\Dropbox (Dalberg)\\VHL - ALL PROJECTS\\01. Mon, Nagaland\\04 Survey Analysis\\00. Inputs\\Weights Final.csv" ,
                     encoding = "UTF-8-BOM") %>%
    select("gen_sec_b_b4" = 1, "gen_sec_b_b5" = 2, "gen_sec_b_b2"= 3, everything()) 
  
  weight_calc <- df_out %>% 
    left_join(weight_data,by=c("gen_sec_b_b4", "gen_sec_b_b5", "gen_sec_b_b2")) %>% 
    select(gen_sec_b_b4, gen_sec_b_b5, gen_sec_b_b2, Population) %>% 
    group_by_all() %>% 
    count() %>% 
    as.data.frame() %>% 
    mutate(z_weight=Population/n) %>% 
    select(gen_sec_b_b4, gen_sec_b_b5, gen_sec_b_b2, z_weight)
  
  df_out <- df_out %>%
    left_join (weight_calc,by = c("gen_sec_b_b4", "gen_sec_b_b5", "gen_sec_b_b2")) %>% 
    mutate(z_weight = case_when (
      is.na(z_weight)~1,
      TRUE~z_weight))
  
  #c02: Hesitant flag  ----
  
  df_out <- df_out %>% 
    mutate(z_hesitant = ((gen_sec_e_e1 %in% "No" & 
                            !(gen_sec_e_e2 %in% "I will take the vaccine when available")) | 
                           (gen_sec_e_e1 %in% "Yes" & 
                              !(gen_sec_e_e3 %in% "Yes") & 
                              !(gen_sec_e_e4 %in% "I will take the second dose when available"))))
  
  # C03: -----
  
  df_out <- df_out %>% 
    mutate(z_pre_persona = case_when(
      
      # None of the doses and against religious beliefs 
      gen_sec_e_e1 %in% c("No", "Don't know") & 
        (gen_sec_d_d3_multiselect_7 == "Mentioned" | hesi_sec_i_i1 == "TRUE" | 
           driver_sec_p_p1 == "TRUE") ~ "L99",
  
      # None of the doses and believes it to be a scam 
      gen_sec_e_e1  %in% c("No", "Don't know") & 
        (hesi_sec_g_g3_3 == "TRUE" | driver_sec_n_n3 == "TRUE" | 
           hesi_sec_g_g3_7 == "FALSE" | driver_sec_n_n7 == "TRUE" | 
           hesi_sec_g_g3_8 == "TRUE" | driver_sec_n_n8 == "TRUE" | 
           hesi_sec_g_g3_10 == "TRUE" | driver_sec_n_n11 == "TRUE") ~ "L98",
      
      # None of the doses and believes it to be have limited effectiveness 
      gen_sec_e_e1  %in% c("No", "Don't know") & 
        (hesi_sec_g_g3_1 == "TRUE" | driver_sec_n_n1 == "TRUE" | 
           hesi_sec_g_g3_2 == "TRUE" | driver_sec_n_n2 == "TRUE" | 
           hesi_sec_g_g3_4 == "FALSE" | driver_sec_n_n4 == "TRUE" | 
           hesi_sec_g_g3_5 == "FALSE" | driver_sec_n_n5 == "TRUE" | 
           hesi_sec_g_g3_6 == "TRUE" | driver_sec_n_n6 == "TRUE" | 
           hesi_sec_g_g3_9 == "TRUE" | driver_sec_n_n9 == "TRUE" | 
           hesi_sec_g_g3_11 == "TRUE" | driver_sec_n_n10 == "TRUE") ~ "L97",
      
      # None of the doses and may face logistic challanges 
      gen_sec_e_e1  %in% c("No", "Don't know") & 
        (hesi_sec_j_j1 == "Yes" | driver_sec_q_q1 == "FALSE") ~ "L96",

      # First dose with negligible chance of getting 2nd dose and against religious beliefs 
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") & 
        gen_sec_e_e4 %in% c("Don't know",
                            "Prefer Not to say",
                            "I will Not take the second dose at all",
                            "I will take the second dose, but Not for the next year") & 
        (gen_sec_d_d3_multiselect_7 == "Mentioned" | hesi_sec_i_i1 == "TRUE" | 
           driver_sec_p_p1 == "TRUE") ~ "L89",
      
      # First dose with negligible chance of getting 2nd dose and believes it to be a scam 
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") & 
        gen_sec_e_e4 %in% c("Don't know",
                            "Prefer Not to say",
                            "I will Not take the second dose at all",
                            "I will take the second dose, but Not for the next year") & 
        (hesi_sec_g_g3_3 == "TRUE" | driver_sec_n_n3 == "TRUE" | 
           hesi_sec_g_g3_7 == "FALSE" | driver_sec_n_n7 == "TRUE" | 
           hesi_sec_g_g3_8 == "TRUE" | driver_sec_n_n8 == "TRUE" | 
           hesi_sec_g_g3_10 == "TRUE" | driver_sec_n_n11 == "TRUE") ~ "L88",
      
      # First dose with negligible chance of getting 2nd dose and believes it to be have limited effectiveness 
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") & 
        gen_sec_e_e4 %in% c("Don't know",
                            "Prefer Not to say",
                            "I will Not take the second dose at all",
                            "I will take the second dose, but Not for the next year") & 
        (hesi_sec_g_g3_1 == "TRUE" | driver_sec_n_n1 == "TRUE" | 
           hesi_sec_g_g3_2 == "TRUE" | driver_sec_n_n2 == "TRUE" | 
           hesi_sec_g_g3_4 == "FALSE" | driver_sec_n_n4 == "TRUE" | 
           hesi_sec_g_g3_5 == "FALSE" | driver_sec_n_n5 == "TRUE" | 
           hesi_sec_g_g3_6 == "TRUE" | driver_sec_n_n6 == "TRUE" | 
           hesi_sec_g_g3_9 == "TRUE" | driver_sec_n_n9 == "TRUE" | 
           hesi_sec_g_g3_11 == "TRUE" | driver_sec_n_n10 == "TRUE") ~ "L87",
      
      # First dose with negligible chance of getting 2nd dose and may face logistic challanges 
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") & 
        gen_sec_e_e4 %in% c("Don't know",
                            "Prefer Not to say",
                            "I will Not take the second dose at all",
                            "I will take the second dose, but Not for the next year") & 
        (hesi_sec_j_j1 == "Yes" | driver_sec_q_q1 == "FALSE") ~ "L86",
      
      # First dose with some chance of 2nd dose and against religious beliefs
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose, but Not in the next three months") &
        (gen_sec_d_d3_multiselect_7 == "Mentioned" | hesi_sec_i_i1 == "TRUE" |
           driver_sec_p_p1 == "TRUE") ~ "L79",

      # First dose with some chance of getting 2nd dose and believes it to be a scam
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose, but Not in the next three months") &
        (hesi_sec_g_g3_3 == "TRUE" | driver_sec_n_n3 == "TRUE" | 
           hesi_sec_g_g3_7 == "FALSE" | driver_sec_n_n7 == "TRUE" | 
           hesi_sec_g_g3_8 == "TRUE" | driver_sec_n_n8 == "TRUE" | 
           hesi_sec_g_g3_10 == "TRUE" | driver_sec_n_n11 == "TRUE") ~ "L78",

      # First dose with some chance of getting 2nd dose and may face logistic challanges
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose, but Not in the next three months") &
        (hesi_sec_j_j1 == "Yes" | driver_sec_q_q1 == "FALSE") ~ "L76",
      
      # First dose with some chance of getting 2nd dose and believes it to be have limited effectiveness
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose, but Not in the next three months") &
        (hesi_sec_g_g3_1 == "TRUE" | driver_sec_n_n1 == "TRUE" | 
           hesi_sec_g_g3_2 == "TRUE" | driver_sec_n_n2 == "TRUE" | 
           hesi_sec_g_g3_4 == "FALSE" | driver_sec_n_n4 == "TRUE" | 
           hesi_sec_g_g3_5 == "FALSE" | driver_sec_n_n5 == "TRUE" | 
           hesi_sec_g_g3_6 == "TRUE" | driver_sec_n_n6 == "TRUE" | 
           hesi_sec_g_g3_9 == "TRUE" | driver_sec_n_n9 == "TRUE" | 
           hesi_sec_g_g3_11 == "TRUE" | driver_sec_n_n10 == "TRUE") ~ "L77",
      
      # First dose with good chance of 2nd dose and against religious beliefs
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose when available") &
        (gen_sec_d_d3_multiselect_7 == "Mentioned" | hesi_sec_i_i1 == "TRUE" |
           driver_sec_p_p1 == "TRUE") ~ "L69",
      
      # First dose with good chance of getting 2nd dose and believes it to be a scam
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose when available") &
        (hesi_sec_g_g3_3 == "TRUE" | driver_sec_n_n3 == "TRUE" | 
           hesi_sec_g_g3_7 == "FALSE" | driver_sec_n_n7 == "TRUE" | 
           hesi_sec_g_g3_8 == "TRUE" | driver_sec_n_n8 == "TRUE" | 
           hesi_sec_g_g3_10 == "TRUE" | driver_sec_n_n11 == "TRUE") ~ "L68",
      
      # First dose with good chance of getting 2nd dose and may face logistic challanges
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose when available") &
        (hesi_sec_j_j1 == "Yes" | driver_sec_q_q1 == "FALSE") ~ "L66",
      
      # First dose with good chance of getting 2nd dose and believes it to be have limited effectiveness
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("No") &
        gen_sec_e_e4 %in% c("I will take the second dose when available") &
        (hesi_sec_g_g3_1 == "TRUE" | driver_sec_n_n1 == "TRUE" | 
           hesi_sec_g_g3_2 == "TRUE" | driver_sec_n_n2 == "TRUE" | 
           hesi_sec_g_g3_4 == "FALSE" | driver_sec_n_n4 == "TRUE" | 
           hesi_sec_g_g3_5 == "FALSE" | driver_sec_n_n5 == "TRUE" | 
           hesi_sec_g_g3_6 == "TRUE" | driver_sec_n_n6 == "TRUE" | 
           hesi_sec_g_g3_9 == "TRUE" | driver_sec_n_n9 == "TRUE" | 
           hesi_sec_g_g3_11 == "TRUE" | driver_sec_n_n10 == "TRUE") ~ "L67",
      
      # Took both dosage
      gen_sec_e_e1 %in% c("Yes") & gen_sec_e_e3 %in% c("Yes") ~ "L59",
      
      # Ready to take second dosage with no challenges except awaiting for it to become available
      gen_sec_e_e2 %in% c("I will take the second dose when available") | 
        gen_sec_e_e4 %in% c("I will take the second dose when available") ~ "L56",
      
      # ELSE
      T ~ "Unassigned"
    ))
  
  df_out <- df_out %>% 
    mutate(z_persona = case_when(
      z_pre_persona %in% c("L59") ~ "Vaccinated",
      z_pre_persona %in% c("L99", "L89", "L79", "L69") ~ "01 Conventional confromist",
      z_pre_persona %in% c("L98", "L88", "L78", "L68") ~ "02 Misinformed misleads",
      z_pre_persona %in% c("L97", "L87", "L77", "L67") ~ "03 Sensible skeptic",
      z_pre_persona %in% c("L96", "L86", "L76", "L66", "L56") ~ "04 Blase Believers",
      T ~ "Unassigned"
    ))
  
  df_out %>% 
    select(z_pre_persona, z_persona) %>%
    f_grouper()
  
  df_out %>% 
    select(z_persona) %>%
    f_grouper()
  
  # df_out %>%

  #   filter(z_persona == "Unassigned") %>% 
  #   write.table(file = file.path("Unassigned.csv"), sep=",", col.names = T, row.names = F)
  
  # C04:Concern -----
  # checking if a person is concerned. True if concerned. False for lack of concern
  # Need to mention question for each clearly in data columns tab
  df_out <- df_out %>% 
    mutate(
      z_com_concern1 = ifelse(hesi_sec_h_h2_1 == "TRUE" | 
                                driver_sec_o_o2_1 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_1 == "" & driver_sec_o_o2_1 == "","NULL", "FALSE")),
      z_com_concern2 = ifelse(hesi_sec_h_h2_2 == "TRUE" | 
                                driver_sec_o_o2_2 == "TRUE",  "TRUE", ifelse(hesi_sec_h_h2_2 == "" & driver_sec_o_o2_2 == "","NULL", "FALSE")),
      z_com_concern3 = ifelse(hesi_sec_h_h2_3 == "TRUE" | 
                                driver_sec_o_o2_3 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_3 == "" & driver_sec_o_o2_3 == "","NULL", "FALSE")),
      z_com_concern4 = ifelse(hesi_sec_h_h2_4 == "TRUE" | 
                                driver_sec_o_o2_4 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_4 == "" & driver_sec_o_o2_4 == "","NULL", "FALSE")),
      z_com_concern5 = ifelse(hesi_sec_h_h2_5 == "TRUE" | 
                                driver_sec_o_o2_5 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_5 == "" & driver_sec_o_o2_5 == "","NULL", "FALSE")),
      z_com_concern6 = ifelse(hesi_sec_h_h2_6 == "TRUE" | 
                                driver_sec_o_o2_6 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_6 == "" & driver_sec_o_o2_6 == "","NULL", "FALSE")),
      z_com_concern7 = ifelse(hesi_sec_h_h2_7 == "TRUE" | 
                                driver_sec_o_o2_7 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_7 == "" & driver_sec_o_o2_7 == "","NULL", "FALSE")),
      z_com_concern8 = ifelse(hesi_sec_h_h2_8 == "TRUE" | 
                                driver_sec_o_o2_8 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_8 == "" & driver_sec_o_o2_8 == "","NULL", "FALSE")),
      z_com_concern9 = ifelse(hesi_sec_h_h2_9 == "TRUE" | 
                                driver_sec_o_o2_9 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_9 == "" & driver_sec_o_o2_9 == "","NULL", "FALSE")),
      z_com_concern10 = ifelse(hesi_sec_h_h2_10 == "TRUE" | 
                                driver_sec_o_o2_10 == "TRUE", "TRUE", ifelse(hesi_sec_h_h2_10 == "" & driver_sec_o_o2_10 == "","NULL", "FALSE"))
      
      
      )
  
  df_out %>% 
    select(z_com_concern10, hesi_sec_h_h2_10, driver_sec_o_o2_10) %>% 
    f_grouper()
  
  
  # C05:Behaviors and Incentives -----
  df_out <- df_out %>% 
    mutate(
      z_com_behavior1 = ifelse(hesi_sec_k_k1_1 == "TRUE" | 
                                 driver_sec_r_r1_1 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_1 == "" & driver_sec_r_r1_1 == "","NULL", "FALSE")),
      z_com_behavior2 = ifelse(hesi_sec_k_k1_2 == "TRUE" | 
                                 driver_sec_r_r1_2 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_2 == "" & driver_sec_r_r1_2 == "","NULL", "FALSE")),
      z_com_behavior3 = ifelse(hesi_sec_k_k1_3 == "TRUE" | 
                                 driver_sec_r_r1_3 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_3 == "" & driver_sec_r_r1_3 == "","NULL", "FALSE")),
      z_com_behavior4 = ifelse(hesi_sec_k_k1_4 == "TRUE" | 
                                 driver_sec_r_r1_4 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_4 == "" & driver_sec_r_r1_4 == "","NULL", "FALSE")),
      z_com_behavior5 = ifelse(hesi_sec_k_k1_5 == "TRUE" | 
                                 driver_sec_r_r1_5 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_5 == "" & driver_sec_r_r1_5 == "","NULL", "FALSE")),
      z_com_behavior6 = ifelse(hesi_sec_k_k1_6 == "TRUE" | 
                                 driver_sec_r_r1_6 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_6 == "" & driver_sec_r_r1_6 == "","NULL", "FALSE")),
      z_com_behavior7 = ifelse(hesi_sec_k_k1_7 == "TRUE" | 
                                 driver_sec_r_r1_7 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_7 == "" & driver_sec_r_r1_7 == "","NULL", "FALSE")),
      z_com_behavior8 = ifelse(hesi_sec_k_k1_8 == "TRUE" | 
                                 driver_sec_r_r1_8 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_8 == "" & driver_sec_r_r1_8 == "","NULL", "FALSE")),
      z_com_behavior9 = ifelse(hesi_sec_k_k1_9 == "TRUE" | 
                                 driver_sec_r_r1_9 == "TRUE", "TRUE", ifelse(hesi_sec_k_k1_9 == "" & driver_sec_r_r1_9 == "","NULL", "FALSE"))
        )
  
  df_out %>% 
    select(z_com_behavior1, hesi_sec_k_k1_1, driver_sec_r_r1_1) %>% 
    f_grouper()
  
  df_out %>% 
    select(z_com_behavior8, hesi_sec_k_k1_8, driver_sec_r_r1_8) %>% 
    f_grouper()
  
  # C06:Information required -----
  df_out <- df_out %>% 
    mutate(
      z_com_info1 = ifelse(hesi_sec_k_k2_1 == "TRUE" | 
                             driver_sec_r_r2_2 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_1 == "" & driver_sec_r_r2_2 == "","NULL", "FALSE")),
      z_com_info2 = ifelse(hesi_sec_k_k2_2 == "TRUE" | 
                             driver_sec_r_r2_3 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_2 == "" & driver_sec_r_r2_3 == "","NULL", "FALSE")),
      z_com_info3 = ifelse(hesi_sec_k_k2_3 == "TRUE" | 
                             driver_sec_r_r2_4 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_3 == "" & driver_sec_r_r2_4 == "","NULL", "FALSE")),
      z_com_info4 = ifelse(hesi_sec_k_k2_4 == "TRUE" | 
                             driver_sec_r_r2_5 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_4 == "" & driver_sec_r_r2_5 == "","NULL", "FALSE")),
      z_com_info5 = ifelse(hesi_sec_k_k2_5 == "TRUE" | 
                             driver_sec_r_r2_6 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_5 == "" & driver_sec_r_r2_6 == "","NULL", "FALSE")),
      z_com_info6 = ifelse(hesi_sec_k_k2_6 == "TRUE" | 
                             driver_sec_r_r2_7 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_6 == "" & driver_sec_r_r2_7 == "","NULL", "FALSE")),
      z_com_info7 = ifelse(hesi_sec_k_k2_7 == "TRUE" | 
                             driver_sec_r_r2_8 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_7 == "" & driver_sec_r_r2_8 == "","NULL", "FALSE")),
      z_com_info8 = ifelse(hesi_sec_k_k2_8 == "TRUE" | 
                             driver_sec_r_r2_9 == "TRUE", "TRUE", ifelse(hesi_sec_k_k2_8 == "" & driver_sec_r_r2_9 == "","NULL", "FALSE"))
    )
  
  df_out %>% 
    select(z_com_info6, hesi_sec_k_k2_6, driver_sec_r_r2_7) %>% 
    f_grouper()
  
  # C07:Reasons -----
  df_out <- df_out %>% 
    mutate(
      z_com_reason1 = ifelse(driver_sec_m_m1_livecap_1 == "Mentioned", "Took" 
              , ifelse(hesi_sec_f_f1_livecap_1 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason2 = ifelse(driver_sec_m_m1_livecap_2 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_2 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason3 = ifelse(driver_sec_m_m1_livecap_3 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_3 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason4 = ifelse(driver_sec_m_m1_livecap_4 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_4 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason5 = ifelse(driver_sec_m_m1_livecap_5 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_5 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason6 = ifelse(driver_sec_m_m1_livecap_6 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_6 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason7 = ifelse(driver_sec_m_m1_livecap_7 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_7 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason8 = ifelse(driver_sec_m_m1_livecap_8 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_8 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason9 = ifelse(driver_sec_m_m1_livecap_9 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_9 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason10 = ifelse(driver_sec_m_m1_livecap_10 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_10 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason11 = ifelse(driver_sec_m_m1_livecap_11 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_11 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason12 = ifelse(driver_sec_m_m1_livecap_12 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_12 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason13 = ifelse(driver_sec_m_m1_livecap_13 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_13 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason14 = ifelse(driver_sec_m_m1_livecap_14 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_14 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason15 = ifelse(driver_sec_m_m1_livecap_15 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_15 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason16 = ifelse(driver_sec_m_m1_livecap_16 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_16 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason17 = ifelse(driver_sec_m_m1_livecap_17 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_17 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason18 = ifelse(driver_sec_m_m1_livecap_18 == "Mentioned", "Took" 
                             , ifelse(hesi_sec_f_f1_livecap_18 == "Mentioned" ,"Not taking", "Null")),
      z_com_reason19 = ifelse(driver_sec_m_m1_livecap_19 == "Mentioned", "Took" 
                              , ifelse(hesi_sec_f_f1_livecap_19 == "Mentioned" ,"Not taking", "Null"))
    )

  
  
  # C08:MUTANT VARIATIONS CONCERN -----
  
  # df_out <- df_out %>% 
  #   mutate(
  #     z_concern_variant = case_when(
  #       "Very concerned"
  #       
  #     )
  #   )
  
  # C09:EDUCATION LEVEL -----
  
  df_out <- df_out %>%
    mutate(
      z_education_years = case_when(
        gen_sec_b_b11 == "Illiterate" ~ 0,
        gen_sec_b_b11 == "Literate but no formal schooling/School upto 4 years" ~ 3,
        gen_sec_b_b11 == "School up to 5 to 9 years" ~ 7,
        gen_sec_b_b11 == "SSC/HSC" ~ 10,
        gen_sec_b_b11 == "Some College (includes a Diploma) but not Graduate" ~ 14,
        gen_sec_b_b11 == "Graduate/ Postgraduate - General" ~ 17,
        gen_sec_b_b11 == "Graduate/ Postgraduate - Professional" ~ 18
      )
    )
  
  df_out %>% 
    select(z_education_years, gen_sec_b_b11) %>% 
    f_grouper()
  
  # C10: TRUSTED SOURCE ----
  df_out <- df_out %>% 
    mutate(
      z_trusted_source_family_friends = case_when(
        gen_sec_d_d3_multiselect_1 == "Mentioned" | 
          gen_sec_d_d3_multiselect_2 == "Mentioned" | 
          gen_sec_d_d3_multiselect_3 == "Mentioned" ~ "Mentioned",
        T ~ "Not mentioned"
      )
    )
  
  df_out %>% 
    select(z_trusted_source_family_friends, gen_sec_d_d3_multiselect_1, gen_sec_d_d3_multiselect_2,gen_sec_d_d3_multiselect_3) %>% 
    f_grouper()
  
  # C11: Village ----
  df_out <- df_out %>%
      mutate(
        z_location = case_when(
          gen_sec_b_b3 %in% c("Aboi", "Aboi mon", "Aboi town", "Aboi Town", "Aboi Village", "Angphang", "Angphang Village", 
                              "Changlang", "Changlang village", "Chinglang", "Jakphand", "Langneing", "Langpaok", 
                              "Langphaoh", "Langphoah", "Longpaok", "Longphaoh", "Lonkai", "Mohung") ~ "ABOI",
          
          gen_sec_b_b3 %in% c("Bumei", "Bumei village", "Changlangshu village","Changlangshu Village", "Pesao Village", "Tobu",
                              "Tobu village", "Tobu Village", "Toby village", "Ukha") ~ "TOBU",
          
          gen_sec_b_b3 %in% c("Chen Loisho village" , "Chen Moho village", "Chen village", "Chen Wetnyu Village", "Chenloisho village", 
                              "Chingkao village", "Chingkao village,Mon", "Chingkao village.", "Chingkaochingha village",
                              "Chingkhao village", "Choknyu", "Chonknyu", "Loisho village", "Longmeing",
                              "Wangshu Village", "Wangti village") ~ "Chen",
          
          gen_sec_b_b3 %in% c("ADC Colony, Mon town","Chi","Chi village", "Chi Village", "Chui", "Chui village", "Fire Brigade Colony, Jahjon ward, Mon town", 
                              "Fire Brigade Colony, Mon town", "Fire brigade, Jahjon ward", 
                              "Goching village", "Goching village Mon town", "Goching village mon", 
                              "Hongphoi village", "Hongphoi","Jahjon ward, Mon town", "Jahkon ward no 7,Mon town", 
                              "Leangha village", "Leangha Village", "Leangha village mon", "Leangha village Mon town",
                              "Leangnyu", "Longkei village", "Mon", "Mon town", "Mon Town", "Mon Town Nagaland",
                              "Mon village", "Mon Village", "NST Colony", "NST Colony, Mon town", "NST Colony, Mon town",
                              "Papong mon", "Tabi area, Mon town", "Takum village", "Tamkoang village", 
                              "Tamkong","Tammong village", "Tamong Village", "Tanlao ward, Mon town",
                              "Tokok chingha mon", "Totok chingkho mon", "Totok chingkho village mon", "Totok chingnyu Mon town",
                              "Walo ward, mon town", "Zaklom ward Mon town", "Zaklom ward, Mon town", "Zaklon ward, Mon town",
                              "Zuklom ward, Mon town", "NST colony. Mon Town") ~ "MON",
          
          gen_sec_b_b3 %in% c("Chinchoi", "Chingchoi", "Chinghoi", "Chingdang Village", "Chingphoi", "Chingphoi Village", 
                              "Chingphoi village Mon","Chinhoi", "Hingphoi", "Chingphoi village Mon", "Kongon", 
                              "Tanhai village", "Tanhai Village", "Tiru", "Wakching", "Wakching Town", "Wakching Village",  "Wanching",
                              "Wanching village", "Wanching village") ~ "WAKCHING",
          
          gen_sec_b_b3 %in% c("Jaboka", "Jaboka village", "Lapa","Lapa Village","Loakan village","Longting", "Longting village",
                              "Nokzang Village", "Oting", "Oting under tizit area", "Tapi village", "Tezit town", "Tizik",
                              "Tizit", "Tizit town", "Tizit Town", "Tizit village", "Tizit Village", "Uting", "Zakho", 
                              "Zangkham Village", "Zangkhan") ~ "TIZIT",
          
          gen_sec_b_b3 %in% c("Longwa", "Longwa village", "Tang village", "Tangnyu", "Yuching village") ~ "PHOMCHING",
          gen_sec_b_b3 %in% c("Longchin", "Longching village", "Longching") ~ "LONGSHEN",
          gen_sec_b_b3 %in% c("Mon Village", "Monyakshu", "Monyakshu village", "Monyakshu Village", "Nonyakshu village", 
                              "Monyakhu") ~ "MONYAKSHU",
          gen_sec_b_b3 %in% c("Naganimora", "Namsa mon", "Noklak village", "Noklak Village") ~ "NAGANIMORA",
          gen_sec_b_b3 %in% c("Shamnyu ward Mon town", "Shantham ward, Mon town", "Sheanghah Chingnyu Village", "Shingnyu Village",
                              "Shiyong Village", "Shiyong village mon") ~ "SHANGNYU",
        T                          ~ "NULL"
    ))

  df_out %>%
    select(z_location, gen_sec_b_b3) %>%
    f_grouper()
  
 # C12: Matriarch education----
  
  df_out <- df_out %>% 
    mutate(
      z_matriarch_ed = case_when(
        close_sec_s_s3 %in% c("Middle", "Primary or below, or not literate") ~ "Middle or below / Illiterate",
        T ~ close_sec_s_s3
      )
    )
  
  df_out %>% 
    select(z_matriarch_ed, close_sec_s_s3) %>% 
    f_grouper()
  
  
  # C13: PERSONAL COVID EXPERIENCE ----
  df_out <- df_out %>% 
    mutate(
      z_personal_covid_experience = case_when(
        
        (gen_sec_c_c1 == "Covid with Severe symptoms" | 
           gen_sec_c_c2 %in% c("Yes, hospitalised and needed oxygen / ICU support", "Yes, hospitalised")) & 
          gen_sec_c_c5 == "Yes" ~ "01. Have severe personal experience and know others who died",
        
        (gen_sec_c_c1 == "Covid with Severe symptoms" | 
           gen_sec_c_c2 %in% c("Yes, hospitalised and needed oxygen / ICU support", 
                               "Yes, hospitalised")) ~ "02. Have severe personal experience",
        
        gen_sec_c_c5 == "Yes" ~ "03. Know others who passed away",
        
        (gen_sec_c_c1 %in% c("Covid with No symptoms", "Covid with Minor symptoms") | 
           gen_sec_c_c2 %in% c("Yes, at home", "Yes, at isolation center")) ~ "04. Minor personal experience",
        
        gen_sec_c_c3 %in% c("Yes") ~ "05. Have heard of others with Covid",
        
        gen_sec_c_c1 %in% c("Don't know", "Don't remember", "Did not have Covid") ~ "06. No Covid experience",
      )
    )
  
  df_out %>% 
    select(z_personal_covid_experience, gen_sec_c_c1, gen_sec_c_c2, gen_sec_c_c3, gen_sec_c_c4, gen_sec_c_c5) %>% 
    f_grouper()
  
  # C14: INCOME ----
  
  df_out <- df_out %>% 
    mutate(z_income_numeric = case_when(
      close_sec_s_s1 == "0-1000" ~ 500,
      close_sec_s_s1 == "1000 - 3000" ~ 2000,
      close_sec_s_s1 == "3000 - 6000" ~ 4500,
      close_sec_s_s1 == "6000 - 10000" ~ 8000,
      close_sec_s_s1 == "10000 - 15000" ~ 12500,
      close_sec_s_s1 == "15000 - 20000" ~ 17500,
      close_sec_s_s1 == "20000 - 30000" ~ 25000,
      close_sec_s_s1 == "Over 30000" ~ 30000
    ))
  
  df_out %>% 
    select(z_income_numeric, close_sec_s_s1) %>% 
    f_grouper()
  
  
   return (df_out)
}

   