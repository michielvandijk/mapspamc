#' Create land cover and crop distribution gdx files for use with GLOBIOM
#'
#'@export
create_globiom_input <- function(mapping, lc_map, param) {

  # Test if gdxrrw and gams are installed.
  setup_gams(param)

  # Aggregate land cover map to GLOBIOM land cover classes at simu level
  lc_df <- calc_lc_area(mapping, lc_map, param)

  # Aggregate mapspam crop distribution tif files to GLOBIOM crop classes at simu
  # level. We do this for physical area but if needed it can also be done for
  # harvested area by replacing "pa", with "ha".
  # Not that the area is expressed in 1000 ha, which is common in GLOBIOM!
  crop_df <- spam2simu("pa", param)

  # Merge simu_lc_df with simu_crop_df.
  # CrpLnd and OthAgri in the lc_map are replaced by CrpLnd and OthAgri
  # from from SPAM using the following rules:
  # If SimUarea > sum(CrpLnd, OthAgr, Forest, WetLnd, OthNatLnd, NotRel,
  # Grass), the surplus is added to OthNatLnd.

  # If SimUarea < sum(CrpLnd, OthAgr, Forest, WetLnd, OthNatLnd, NotRel, Grass),
  # the shortage is subtracted from from the classes in this order:
  # 1. OthNatLnd; 2. take from NotRel; 3. WetLnd; 4 Forest; 5 Grass
  lc_upd <- merge_lc_crop(lc_df, crop_df)

  # Land cover gdx file
  create_land_cover_gdx(lc_upd, param)

  # Crop distribution gdx file
  create_crop_distribution_gdx(crop_df, param)

}
