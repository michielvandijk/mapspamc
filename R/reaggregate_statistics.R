#'Reaggregates subnational statistics from the bottom up so they are consistent
#'
#'@param df tbl or data.frame
#'@param param
#'@inheritParams create_spam_folders
#'
#'@return same class as `df`.
#'
#'@examples
#'
#'@export
reaggregate_statistics <- function(df, param){
    stopifnot(inherits(param, "spam_par"))
    unit <- names(df)[names(df) %in% c("ha", "pa")]
    names(df)[names(df) %in% c("ha", "pa")] <- "value"

    load_data("adm_list", param, local = TRUE, mess = FALSE)
    if(param$adm_level == 2) {

        # Aggregate adm2
        adm2_reag <- df %>%
            filter(adm_level == 2) %>%
            rename(adm2_name = adm_name, adm2_code = adm_code) %>%
            left_join(adm_list %>%
                          dplyr::select(adm2_name, adm2_code, adm1_name, adm1_code) %>%
                          unique(), by = c("adm2_code", "adm2_name")) %>%
            group_by(adm1_name, adm1_code, crop) %>%
            summarize(adm2_tot = plus(value, na.rm = F)) %>% #NB use plus with na.rm = F because we want NA+NA = NA but NA + 0 = NA
            rename(adm_name = adm1_name, adm_code = adm1_code)

        # Reveal inconsistencies in subtotal, i.e. if adm2 subtotal != adm1 total
        adm1_replace <- df %>%
            filter(adm_level == 1) %>%
            dplyr::rename(adm1_tot = value) %>%
            left_join(adm2_reag, by = c("adm_code", "adm_name", "crop")) %>%
            mutate(update = case_when(
                is.na(adm2_tot) ~ "N",
                adm1_tot ==  adm2_tot ~ "N",
                TRUE ~ "Y")) %>%
            filter(update == "Y") %>%
            mutate(adm_code_crop = paste(adm_code, crop, sep = "_")) %>%
            dplyr::select(adm_code, adm_name, adm_level, value = adm2_tot, crop) %>%
            mutate(adm_code_crop = paste(adm_code, crop, sep = "_"))

        # update stat
        message("Rebalanced adm1 level")
        df <- bind_rows(
            df %>%
                mutate(adm_code_crop = paste(adm_code, crop, sep = "_")) %>%
                filter(!adm_code_crop %in% adm1_replace$adm_code_crop) %>%
                ungroup,
            adm1_replace) %>%
            dplyr::select(-adm_code_crop)
    }

    if(param$adm_level %in% c(1,2)) {

        # Aggregate adm1
        adm1_reag <- df %>%
            filter(adm_level == 1) %>%
            rename(adm1_name = adm_name, adm1_code = adm_code) %>%
            left_join(adm_list  %>%
                          dplyr::select(adm1_name, adm1_code, adm0_name, adm0_code) %>%
                          unique, by = c("adm1_code", "adm1_name")) %>%
            group_by(adm0_name, adm0_code, crop) %>%
            summarize(adm1_tot = plus(value, na.rm = F)) %>%
            rename(adm_name = adm0_name, adm_code = adm0_code)

        # Reveal inconsistencies in subtotal, i.e. if adm2 subtotal != adm1 total
        adm0_replace <- df %>%
            filter(adm_level == 0) %>%
            dplyr::rename(adm0_tot = value) %>%
            left_join(adm1_reag, by = c("adm_code", "adm_name", "crop")) %>%
            mutate(update = case_when(
                is.na(adm1_tot) ~ "N",
                adm0_tot ==  adm1_tot ~ "N",
                TRUE ~ "Y")) %>%
            filter(update == "Y") %>%
            mutate(adm_code_crop = paste(adm_code, crop, sep = "_")) %>%
            dplyr::select(adm_code, adm_name, adm_level, value = adm1_tot, crop) %>%
            mutate(adm_code_crop = paste(adm_code, crop, sep = "_"))

        # update stat
        message("Rebalanced adm0 level")
        df <- bind_rows(
            df %>%
                mutate(adm_code_crop = paste(adm_code, crop, sep = "_")) %>%
                filter(!adm_code_crop %in% adm0_replace$adm_code_crop) %>%
                ungroup,
            adm0_replace) %>%
            dplyr::select(-adm_code_crop)
    }
    names(df)[names(df) %in% c("value")] <- unit
    return(df)
}
