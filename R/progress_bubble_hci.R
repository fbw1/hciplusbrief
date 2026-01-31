#' HCI+ progress bubble chart
#'
#' Creates a two-circle "progress" chart where the outer circle represents the
#' maximum (potential) HCI+ and the inner circle represents progress toward that
#' maximum. The inner circle radius is scaled by \code{sqrt(progress / max_value)}
#' so its *area* is proportional to progress.
#'
#' @param value Numeric. The HCI+ value displayed as a label inside the inner
#'   circle. This is purely the text shown on the plot and does not affect sizing.
#' @param progress Numeric. The amount of achieved HCI+ used to scale the inner
#'   bubble relative to \code{max_value}. Values are clamped to \eqn{[0, max_value]}.
#' @param max_value Numeric. The maximum possible HCI+ used to normalize
#'   \code{progress}. Defaults to 325.
#' @param title Character. Used as the legend title when \code{legend_title} is
#'   \code{NULL}. Defaults to \code{""}.
#' @param txt.col Character. Text colour for the \code{value} label.
#' @param radius Numeric. Radius of the outer (potential) bubble, in plot units.
#' @param value_size Numeric. Font size for the \code{value} label.
#'
#' @param legend_title Character or \code{NULL}. Legend title. If \code{NULL},
#'   \code{title} is used.
#' @param legend_text_size Numeric. Legend text size.
#' @param legend_title_size Numeric. Legend title size.
#' @param legend_key_size Numeric. Legend key size (height/size of legend symbols).
#' @param legend_spacing_x Numeric. Horizontal spacing between legend items, in cm.
#' @param legend_key_width Numeric. Width of the legend key, in cm.
#'
#' @return A \code{ggplot} object.
#'
#' @details
#' The plot draws two filled circles via \code{ggforce::geom_circle()}:
#' \itemize{
#'   \item \strong{Potential Productivity}: outer bubble with radius \code{radius}.
#'   \item \strong{Actual HCI+}: inner bubble with radius \code{sqrt(progress / max_value) * radius}.
#' }
#' This scaling makes bubble \emph{area} proportional to progress, which is often
#' easier to interpret than scaling radius linearly.
#'
#' @examples
#' # Basic usage
#' progress_bubble_hci(value = 280, progress = 280)
#'
#' # Show lower progress (inner bubble shrinks)
#' progress_bubble_hci(value = 120, progress = 120, max_value = 325)
#'
#' # Custom legend title and styling
#' progress_bubble_hci(
#'   value = 280, progress = 280,
#'   legend_title = "HCI+",
#'   legend_title_size = 10,
#'   legend_text_size = 9
#' )
#'
#' @export
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

  # ---- font fallback ----
  font_family <- if ("Andes" %in% systemfonts::system_fonts()$family) {
    "Andes"
  } else {
    "sans"
  }

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

  # ---- themes ----
  base_theme <- ggplot2::theme_minimal(base_size = 8) +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "white", color = NA),
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      panel.grid       = ggplot2::element_blank(),

      axis.line  = ggplot2::element_blank(),
      axis.ticks = ggplot2::element_blank(),
      axis.text  = ggplot2::element_blank(),
      axis.title = ggplot2::element_blank(),

      text = ggplot2::element_text(family = font_family)
    )

  legend_theme <- ggplot2::theme(
    legend.position  = "right",
    legend.text      = ggplot2::element_text(
      size = legend_text_size,
      family = font_family
    ),
    legend.title     = ggplot2::element_text(
      size = legend_title_size,
      family = font_family
    ),
    legend.spacing.x = grid::unit(legend_spacing_x, "cm"),
    legend.key.width = grid::unit(legend_key_width, "cm"),
    legend.key.size  = grid::unit(legend_key_size, "cm"),
    legend.margin    = ggplot2::margin(l = -10)
  )

  layout_theme <- ggplot2::theme(
    plot.margin = ggplot2::margin(-5, 0, 0, 0)
  )

  # ---- plot ----
  ggplot2::ggplot(
    circles,
    ggplot2::aes(x0 = x, y0 = y, r = r, fill = key)
  ) +
    ggforce::geom_circle(color = NA) +
    ggplot2::coord_fixed(
      xlim = c(-2, 2),
      ylim = c(-0.2, 2 * big_r + 0.2),
      clip = "off"
    ) +
    ggplot2::scale_fill_manual(
      values = c(
        "Potential Productivity" = "#c8d7e3",
        "Actual HCI+" = "#005990"
      ),
      name = rlang::`%||%`(legend_title, title),
      guide = ggplot2::guide_legend(
        nrow = 2,
        byrow = TRUE,
        override.aes = list(shape = 21, size = 3)
      )
    ) +
    ggplot2::annotate(
      "text",
      x = 0,
      y = y_small,
      label = value,
      size = value_size,
      fontface = "bold",
      color = txt.col,
      family = font_family
    ) +
    base_theme + legend_theme + layout_theme
}
