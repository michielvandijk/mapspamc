#'@title
#'Creates a pdf file with maps of administrative unit locations
#'
#'@description
#'The function will create and save a pdf file with the location of the
#'administrative units in the `/processed_data/maps/adm` folder. Depening on the
#'adm level, maps are produced for level 1 and/or level 2 administrative units.
#'The function will automatically load the file with the polygon information on
#'the location of administrative units, that needs to be created first by the
#'user (see Articles).
#'
#'@param
#'@inheritParams create_grid
#'@param font_size Parameter to specify the font size of administrative unit
#'  name that is plotted on the map (default size = 3). If names are long or
#'  administrative unit polygons are small, the labels may get cluttered. Better
#'  results can be obtained by decreasing the font size.
#'
#'@return
#'An rds file with the created grid is saved in the `processed_data/maps/grid` folder.
#'
#'@examples
#'\dontrun{
#'create_adm_map_pdf(param)
#'}
#'
#'@import ggplot2
#'@export
create_adm_map_pdf <- function(param, font_size = 3) {

  stopifnot(inherits(param, "spam_par"))
  cat("\n############### Create pdf with the location of administrative units ############### ")
  load_data("adm_map", param, mess = FALSE, local = TRUE)

  if(param$adm_level %in% c(1,2)){

    # Create adm1 polygons
    adm1 <- adm_map %>%
      dplyr::group_by(adm1_name, adm1_code) %>%
      dplyr::summarize()

    # Labels at the centre of adm
    #adm1_name <- suppressWarnings(sf::st_centroid(adm1))
    adm1_name <- suppressWarnings(cbind(adm1, sf::st_coordinates(sf::st_centroid(adm1$geometry))))

    # Increase number of colours in palette
    cols <- scales::brewer_pal(palette = "Set1")(9)
    cols <- scales::gradient_n_pal(cols)(seq(0, 1, length.out = length(adm1$adm1_name)))

    # Plot
    adm1_plot <- ggplot() +
      geom_sf(data = adm1, colour = "grey30", aes(fill = adm1_name)) +
      scale_fill_manual(values = cols) +
      geom_text(data= adm1_name, aes(x = X, y = Y, label = adm1_name), size = font_size,
                check_overlap = FALSE) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(),
            panel.border = element_rect(colour = "black", fill = "transparent"), plot.title = element_text(hjust = 0.5)) +
      theme(panel.grid.major = element_line(colour = 'transparent')) +
      labs(fill = "", x = "", y = "", title = param$country) +
      guides(fill = FALSE)
    }


  if(param$adm_level %in% c(2)){

    # Create adm2 polygons
    adm2 <- adm_map

    # Labels at the centre of adm
    #adm2_name <- sf::st_centroid(adm2)
    adm2_name <- suppressWarnings(cbind(adm2, sf::st_coordinates(sf::st_centroid(adm2$geometry))))

    # Increase number of colours in palette
    cols <- scales::brewer_pal(palette = "Set1")(9)
    cols <- scales::gradient_n_pal(cols)(seq(0, 1, length.out = length(adm2$adm2_name)))

    # Plot
    adm2_plot <- ggplot() +
      geom_sf(data = adm2, colour = "grey30", aes(fill = adm2_name)) +
      scale_fill_manual(values = cols) +
      geom_text(data= adm2_name, aes(x = X, y = Y, label = adm2_name), size = font_size,,
                check_overlap = FALSE) +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), panel.background = element_blank(),
            panel.border = element_rect(colour = "black", fill = "transparent"), plot.title = element_text(hjust = 0.5)) +
      theme(panel.grid.major = element_line(colour = 'transparent')) +
      labs(fill = "", x = "", y = "", title = param$country) +
      guides(fill = FALSE)
  }


  ############### SAVE ###############
  temp_path <- file.path(param$spam_path, glue::glue("processed_data/maps/adm/{param$res}" ))
  dir.create(temp_path, recursive = T, showWarnings = F)

  pdf(file = file.path(temp_path, glue::glue("adm_map_{param$res}_{param$yea}_{param$iso3c}.pdf")),
        width = 8.27, height = 11.69)
    if(param$adm_level == 1) {
      print(adm1_plot)
    } else {
      if(param$adm_level %in% c(1,2)) {
      print(adm1_plot)
      print(adm2_plot)
      } else {
        cat("\nadm_level is set to 0, no pdf created")
      }
    }
    invisible(dev.off())
    cat("\n pdf file created")
}
