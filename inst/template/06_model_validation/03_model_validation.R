#'========================================================================================
#' Project:  mapspamc
#' Subject:  Script validate the model
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("06_model_validation/01_alternative_model_setup.r"))


# COMPARE ALTERNATIVE MODEL WITH STATISTICS -----------------------------------------------------------------
# Aggregate gridded output to adm level of model specified by param
results_alt_ag <- aggregate_to_adm(param, alt_param) %>%
  mutate(source = "model")

# Prepare statistics
# We exclude zero and NA values
load_data("ha", param)
ha <- ha %>%
  pivot_longer(-c(adm_name, adm_code, adm_level), names_to = "crop", values_to = "value") %>%
  mutate(source = "statistics") %>%
  filter(adm_level == param$adm_level, value != -999, value != 0) %>%
  dplyr::select(-adm_level)

# Plot
# Statistics are created with the ggpubr package. Absolute positioning is used to place the
# labels and likely need to be set for each model. We use logs to account for very large and
# small values

# Create enough colors
cols <- colorRampPalette(brewer.pal(9, "Set1"))(n_distinct(ha$crop))

p_val1 <- bind_rows(ha, results_alt_ag)  %>%
  pivot_wider(names_from = source, values_from = value) %>%
  na.omit() %>%
  ggplot(aes(x = log(model+1), y = log(statistics+1), color = crop)) +
  scale_colour_manual(values = cols) +
  geom_point(alpha = 0.5, size = 1.5) +
  stat_cor(aes(label = ..r.label..), p.accuracy = 0.001, r.accuracy = 0.01, label.x = 3, label.y = 2) +
  facet_wrap(~crop) +
  geom_abline(slope = 1, linetype = "dashed") +
  labs(x = "mapspamc (log)", y = "Statistics (log)") +
  theme(legend.position = "none",
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = "transparent"),
        aspect.ratio = 1,
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
print(p_val1)


# COMPARE MODEL WITH STATISTICS -----------------------------------------------------------------
# Another type of model validation is to compare the subnational statistics with the preferred model,
# i.e. the model, which uses the most detailed subnational information as input as set by the
# adm_level parameter in param. The result should be near perfect correlation as the model uses the
# subnational data as a constraint to allocate crops. Slight deviations are the result of slack,
# which is added to the model to allow for some flexibility and prevents the model from becoming
# infeasible (see package documentation).

# Aggregate gridded output to adm level of model specified by param
results_ag <- aggregate_to_adm(param, param) %>%
  mutate(source = "model")

# Prepare statistics
# We exclude zero and NA values
load_data("ha", param)
ha <- ha %>%
  pivot_longer(-c(adm_name, adm_code, adm_level), names_to = "crop", values_to = "value") %>%
  mutate(source = "statistics") %>%
  filter(adm_level == param$adm_level, value != -999, value != 0) %>%
  dplyr::select(-adm_level)

# Plot
# Statistics are created with the ggpubr package. Absolute positioning is used to place the
# labels and likely need to be set for each model. We use logs to account for very large and
# small values
p_val2 <- bind_rows(ha, results_ag)  %>%
  pivot_wider(names_from = source, values_from = value) %>%
  na.omit() %>%
  ggplot(aes(x = log(model+1), y = log(statistics+1), color = crop)) +
  scale_colour_manual(values = cols) +
  geom_point(alpha = 0.5, size = 1.5) +
  stat_cor(aes(label = ..r.label..), p.accuracy = 0.001, r.accuracy = 0.01, label.x = 3, label.y = 2) +
  facet_wrap(~crop) +
  geom_abline(slope = 1, linetype = "dashed") +
  labs(x = "mapspamc (log)", y = "Statistics (log)") +
  theme(legend.position = "none",
        strip.background = element_blank(),
        panel.border = element_rect(colour = "black", fill = "transparent"),
        aspect.ratio = 1,
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank())
print(p_val2)
