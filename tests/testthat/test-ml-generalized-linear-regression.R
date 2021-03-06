context("glm")

sc <- testthat_spark_connection()

test_that("'ml_generalized_linear_regression' and 'glm' produce similar fits and residuals", {
  skip_on_cran()

  if (spark_version(sc) < "2.0.0")
    skip("requires Spark 2.0.0")

  mtcars_tbl <- testthat_tbl("mtcars")

  r <- glm(mpg ~ cyl + wt, data = mtcars, family = gaussian(link = "identity"))
  s <- ml_generalized_linear_regression(mtcars_tbl, "mpg", c("cyl", "wt"), family = gaussian(link = "identity"))
  expect_equal(coef(r), coef(s))
  expect_equal(residuals(r) %>% unname(), residuals(s))
  df_r <- mtcars %>%
    mutate(residuals = unname(residuals(r)))
  df_s <- sdf_residuals(s) %>%
    collect() %>%
    as.data.frame()
  expect_equal(df_r, df_s)

  beaver <- beaver2
  beaver_tbl <- testthat_tbl("beaver2")

  r <- glm(data = beaver, activ ~ temp, family = binomial(link = "logit"))
  s <- ml_generalized_linear_regression(beaver_tbl, "activ", "temp", family = binomial(link = "logit"))
  expect_equal(coef(r), coef(s))
  expect_equal(residuals(r) %>% unname(), residuals(s))
  df_r <- beaver %>%
    mutate(residuals = unname(residuals(r)))
  df_s <- sdf_residuals(s) %>%
    as.data.frame()
  expect_equal(df_r, df_s)

})
