
progress_bubble_hci <- function(
  value = 280,
  progress = 280,
  max_value = 325,
  title = "",
  txt.col = "white",
  radius = 1.7,
  value_size = 9,
  legend_title = NULL,
  legend_text_size = 8,
  legend_title_size = 9,
  legend_key_size = 0.2,
  legend_spacing_x = 0.0,  
  legend_key_width = 0.35
) {

  # normalize progress to [0,1]
  frac <- pmin(pmax(progress / max_value, 0), 1)

  big_r   <- radius
  small_r <- sqrt(frac) * radius

  baseline <- 0
  y_big    <- baseline + big_r
  y_small  <- baseline + small_r

  circles <- tibble::tibble(
    x = 0,
    y = c(y_big, y_small),
    r = c(big_r, small_r),
    key = factor(
      c("Potential Productivity", "Actual HCI+"),
      levels = c("Potential Productivity", "Actual HCI+")
    )
  )

  ggplot(circles, aes(x0 = x, y0 = y, r = r, fill = key)) +
    ggforce::geom_circle(color = NA) +
    coord_fixed(
      xlim = c(-2, 2),
      ylim = c(-0.2, 2 * big_r + 0.2),
      clip = "off"
    ) +
    scale_fill_manual(
      values = c(
        "Potential Productivity" = "#c8d7e3",
        "Actual HCI+"            = "#005990"
      ),
      name = legend_title %||% title,
      guide = guide_legend(
        nrow = 2,
        byrow = TRUE,
        override.aes = list(shape = 21, size = 3)
      )
    ) +
    annotate(
      "text",
      x = 0, y = y_small,
      label = value,
      size = 4,
      fontface = "bold",
      color = txt.col, family = "Andes"
    ) +
    theme(
      legend.position = "right",
      legend.text  = element_text(size = 5),
      legend.title = element_text(size = legend_title_size),
      legend.spacing.x = unit(legend_spacing_x, "cm"),
      legend.key.width = unit(legend_key_width, "cm"),
      legend.key.size  = unit(legend_key_size, "cm"),
      legend.margin = margin(l = -10),
      text = element_text(family = "Andes"),
      plot.margin = margin(-5, 0, 0, 0)
    )
}
