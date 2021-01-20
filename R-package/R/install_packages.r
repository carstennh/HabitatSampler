#' Install missing packages
#'
#' The function checks if the packages passed as arguments are installed and loaded.
#'
#' @param ... list of packages to be installed and loaded.
#'
#' @export
usePack <- function(...) {
    libs <- unlist(list(...))
    req <- unlist(lapply(libs, require, character.only = TRUE))
    need <- libs[req == FALSE]
    if (length(need) > 0) {
        install.packages(need, repos = "https://cran.uni-muenster.de/")
        lapply(need, require, character.only = TRUE)
    }

    need <- grep(need, pattern = "velox")
    if (length(need) > 0) {
        if (.Platform$OS.type == "windows") {
            install.Rtools(choose_version = F, check = T)
        }
        install_version("velox",
                        version = "0.2.0",
                        repos = "https://cran.uni-muenster.de/")
        require(velox)

        install_version("leafem",
                        version = "0.0.1",
                        repos = "https://cran.uni-muenster.de/")
        require(leafem)
    }
}
