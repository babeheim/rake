
dir_init <- function(path, verbose = FALSE, overwrite = TRUE) {
  if (substr(path, 1, 1) %in% c("/", "~")) {
    stop("directory paths cannot be absolute")
  }
  if (dir.exists(path)) {
    if (overwrite) {
      contents <- dir(path, recursive = TRUE)
      if (verbose) {
        if (length(contents) == 0) {
          print(paste("folder ", path, " created.", sep = ""))
        } else {
          print(paste("folder ", path, " wiped of ", length(contents),
            " files/folders.", sep = ""))
        }
      }
      if (dir.exists(path)) unlink(path, recursive = TRUE)
      dir.create(path)
    }
  } else {
    if (verbose) {
      print(paste("folder ", path, " created.", sep = ""))
    }
    dir.create(path)
  }
}
