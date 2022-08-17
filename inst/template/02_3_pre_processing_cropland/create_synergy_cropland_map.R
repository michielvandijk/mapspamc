#'========================================================================================================================================
#' Project:  mapspamc
#' Subject:  Code to create synergy cropland map
#' Author:   Michiel van Dijk
#' Contact:  michiel.vandijk@wur.nl
#'========================================================================================================================================

# SOURCE PARAMETERS ----------------------------------------------------------------------
source(here::here("scripts/01_model_setup/01_model_setup.r"))


# PROCESS --------------------------------------------------------------------------------
temp_path <- file.path(param$spamc_path, glue("processed_data/maps/cropland/{param$res}"))
dir.create(temp_path, showWarnings = FALSE, recursive = TRUE)

# H2 -------------------------------------------------------------------------------------

# Cropmask from different sources
gl30 <- readRDS(file.path(proc_path, paste0("synergistic_cropmask/cropmask_gl30_", grid_sel, "_", year_sel, "_", iso3c_sel, ".rds"))) %>%
  ungroup()
glc2000 <- readRDS(file.path(proc_path, paste0("synergistic_cropmask/cropmask_glc2000_", grid_sel, "_", year_sel, "_", iso3c_sel, ".rds"))) %>%
  ungroup()
esa <- readRDS(file.path(proc_path, paste0("synergistic_cropmask/cropmask_esa_", grid_sel, "_", year_sel, "_", iso3c_sel, ".rds"))) %>%
  ungroup()


# Grid
grid <- raster(file.path(proc_path, paste0("maps/grid/grid_", grid_sel, "_r_", year_sel, "_", iso3c_sel, ".tif")))
names(grid) <- "gridID"

# Scoring table
st_raw <- read_excel(file.path(mappings_path, paste0("synergistic_cropmask_score_table.xlsx")), sheet = "score4")


### VISUALISE
# grid_df
grid_df <- as.data.frame(rasterToPoints(grid))

# gl30 raster
gl30_r <- rasterFromXYZ(left_join(grid_df, gl30) %>% dplyr::select(x, y, area))
crs(gl30_r) <- crs(adm)

# glc2000 raster
glc2000_r <- rasterFromXYZ(left_join(grid_df, glc2000) %>% dplyr::select(x, y, area))
crs(glc2000_r) <- crs(adm)

# esa raster
esa_r <- rasterFromXYZ(left_join(grid_df, esa) %>% dplyr::select(x, y, area))
crs(esa_r) <- crs(adm)


### CREATE CROPLAND EXTENT FROM TP1
# spam cm raster
cropmask_tp1 <- spam_tp1 %>%
  group_by(gridID) %>%
  summarize(area = sum(alloc, na.rm = T)) %>%
  mutate(source = "cropmask_tp1")

cropmask_tp1_r <- rasterFromXYZ(left_join(grid_df, cropmask_tp1) %>% 
                                  dplyr::select(x, y, area))
crs(cropmask_tp1_r) <- crs(adm)

pal = mapviewPalette("mapviewSpectralColors")
pal2 = mapviewPalette("mapviewTopoColors")

mapview(gl30_r, col.regions = pal(100)) + 
  mapview(glc2000_r, col.regions = "red") + 
  mapview(esa_r, col.regions = pal2(100)) + 
  mapview(cropmask_tp1_r) + 
  mapview(adm, alpha.regions = 0)


### ADD SCORE TO DATA
# Create combined codes in scoring table
st <- st_raw %>%
  gather(source, code_digit, -agreement, -lc_rank) %>%
  mutate(code = ifelse(code_digit == 1, source, 0)) %>%
  group_by(agreement, lc_rank) %>%
  summarize(code = paste0(code, collapse = "-"))

# Code combinations. NOTE ORDER FACTOR SHOULD BE THE SAME AS SCORING TABLE!
lc_code <- bind_rows(glc2000, esa, gl30, cropmask_tp1) %>%
  mutate(code = source,
         source = factor(source, levels = c("esa", "gl30", "cropmask_tp1", "glc2000"))) %>%
  dplyr::select(-area) %>%
  spread(source, code, fill = "0") %>%
  gather(source, code, -gridID) %>%
  group_by(gridID) %>%
  summarize(code = paste0(code, collapse = "-")) %>%
  left_join(st)
summary(lc_code)
table(lc_code$lc_rank)


### CALCULATE MEAN AREA PER GRID CELL AND COMBINE
# We do not use glc2000 as this source is too coarse, and cropmask_tp1 as it covers a different period
# This means we are removing all grid cells with rank 13, 14, 15, which do not have esa or gl30.
# TO_UPDATE if this is a problem
lc_area <-  bind_rows(esa, gl30) %>%
  group_by(gridID) %>%
  summarize(lc1 = mean(area, na.rm = T),
            lc_max = max(area, na.rm = T))
summary(lc_area)  

# combine
lc_df <- left_join(lc_code, lc_area) %>%
  filter(!is.na(lc1))
summary(lc_df)


### CREATE RASTER FILES
# syneristic cropmask
lc <- rasterFromXYZ(left_join(grid_df, lc_df) %>% 
                      dplyr::select(x, y, lc1))
crs(lc) <- crs(adm)

# syneristic cropmask max
lc_max <- rasterFromXYZ(left_join(grid_df, lc_df) %>% 
                          dplyr::select(x, y, lc_max))
crs(lc_max) <- crs(adm)

# syneristic cropmask rank
lc_rank <- rasterFromXYZ(left_join(grid_df, lc_df) %>% 
                           dplyr::select(x, y, lc_rank))
crs(lc_rank) <- crs(adm)

mapview(lc) +
  mapview(lc_max) +
  mapview(lc_rank)


### SAVE
temp_path <- file.path(proc_path, paste0("maps/cropmask"))
dir.create(temp_path, recursive = T, showWarnings = F)

# lc_df
saveRDS(lc_df, file.path(proc_path, paste0("synergistic_cropmask/lc_df_", grid_sel, "_", year_sel, "_", iso3c_sel, ".rds")))

# lc
comment(lc@crs) <- "" # fix because of changes in raster/rgdal
writeRaster(lc, file.path(temp_path, paste0("lc_", grid_sel, "_", year_sel, "_", iso3c_sel, ".tif")), overwrite = T)

# lc_max
comment(lc_max@crs) <- "" # fix because of changes in raster/rgdal
writeRaster(lc_max, file.path(temp_path, paste0("lc_max_", grid_sel, "_", year_sel, "_", iso3c_sel, ".tif")), overwrite = T)

# lc_rank
comment(lc_rank@crs) <- "" # fix because of changes in raster/rgdal
writeRaster(lc_rank, file.path(temp_path, paste0("lc_rank_", grid_sel, "_", year_sel, "_", iso3c_sel, ".tif")), overwrite = T)


### CLEAN Up
rm(lc, lc_area, lc_code, lc_df, lc_max, lc, lc_rank, spam_cm, spam_cm_r, st, st_raw, year_cm,
   adm, esa, esa_r, gl30, gl30_r, glc2000, glc2000_r, grid, grid_df)
