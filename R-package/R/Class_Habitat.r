#' Habitat Class
#'
#' Creates a Habitat Class
#'
#' @return a Habitat Class
#' @export
Habitat <- setClass(
  "Habitat",
  slots = c(
    models = "list",
    ref_samples = "list",
    switch = "vector",
    layer = "list",
    mod_all = "list",
    class_ind = "numeric",
    seeds = "numeric"
  )
)

