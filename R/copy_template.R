copy_template <- function(path = ".") {
  template <- system.file("ghmapping_template.R", package = "ghmapping")
  file.copy(template, path)
}