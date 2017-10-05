#' Spark ML -- Bisecting K-Means Clustering
#'
#' Perform Bisecting k-means clustering on a Spark DataFrame.
#'
#' @template roxlate-ml-x
#' @param centers The number of cluster centers to compute.
#' @param impute_strategy takes mean|median|mode by default mean
#' @template roxlate-ml-iter-max
#' @template roxlate-ml-features
#' @template roxlate-ml-compute-cost
#' @template roxlate-ml-options
#' @template roxlate-ml-dots
#'
#' @seealso For information on how Spark k-means clustering is implemented, please see
#'   \url{http://spark.apache.org/docs/latest/ml-clustering.html#bisecting-k-means}.
#'
#' @family Spark ML routines
#'
#'
#' @return \link{ml_model} object of class \code{bisectingkmeans} with overloaded \code{print}, \code{fitted} and \code{predict} functions.
#'
#' @export
#' @importFrom dplyr tbl_vars
ml_bisectingkmeans <- function(x,
                      centers,
                      iter.max = 100,
                      features = tbl_vars(x),
                      compute.cost = TRUE,
                      ml.options = ml_options(),
                      ...)
{
  ml_backwards_compatibility_api()

  df <- spark_dataframe(x)
  sc <- spark_connection(df)

  df <- ml_prepare_features(
    x = df,
    features = features,
    envir = environment(),
    ml.options = ml.options
  )

  centers <- ensure_scalar_integer(centers)
  iter.max <- ensure_scalar_integer(iter.max)
  only.model <- ensure_scalar_boolean(ml.options$only.model)

  envir <- new.env(parent = emptyenv())

  envir$id <- ml.options$id.column
  df <- df %>%
    sdf_with_unique_id(envir$id) %>%
    spark_dataframe()

  tdf <- ml_prepare_dataframe(df, features, ml.options = ml.options, envir = envir)

  envir$model <- "org.apache.spark.ml.clustering.BisectingKMeans"
  bkmeans <- invoke_new(sc, envir$model)

  model <- bkmeans %>%
    invoke("setK", centers) %>%
    invoke("setMaxIter", iter.max) %>%
    invoke("setFeaturesCol", envir$features)

  if (is.function(ml.options$model.transform))
    model <- ml.options$model.transform(model)

  if (only.model)
    return(model)

  fit <- model %>%
    invoke("fit", tdf)

  # extract cluster centers
  bkmmCenters <- invoke(fit, "clusterCenters")

  # compute cost for k-means
  if (compute.cost) {
    bkmmCost <- tryCatch(
      invoke(fit, "computeCost", tdf),
      error = function(e) NULL
    )
  }

  centersList <- transpose_list(lapply(bkmmCenters, function(center) {
    as.numeric(invoke(center, "toArray"))
  }))

  names(centersList) <- features
  centers <- as.data.frame(centersList, stringsAsFactors = FALSE, optional = TRUE)

  ml_model("BisectingKMeans", fit,
           centers = centers,
           features = features,
           data = df,
           ml.options = ml.options,
           model.parameters = as.list(envir),
           cost = ifelse(compute.cost, bkmmCost, NULL)
  )
}

#' @export
print.ml_model_bisectingkmeans <- function(x, ...) {

  preamble <- sprintf(
    "Bisecting K-means clustering with %s %s",
    nrow(x$centers),
    if (nrow(x$centers) == 1) "cluster" else "clusters"
  )

  cat(preamble, sep = "\n")
  print_newline()
  ml_model_print_centers(x)

  print_newline()
  cat("Within Set Sum of Squared Errors = ",
      if (is.null(x$cost)) "not computed." else x$cost
  )

}

#' @export
fitted.ml_model_bisectingkmeans <- function(object, ...) {
  predict(object)
}

transpose_list <- function(list) {
  do.call(Map, c(c, list, USE.NAMES = FALSE))
}
