spark_dependencies <- function(spark_version, scala_version, ...) {
  sparklyr::spark_dependency(
    jars = c(
      system.file(
        sprintf("java/bkm.jar", spark_version, scala_version),
        package = "bisectingkmeans"
      )
    ),
    packages = c(
    )
  )
}

#' @import sparklyr
.onLoad <- function(libname, pkgname) {
  sparklyr::register_extension(pkgname)
}
