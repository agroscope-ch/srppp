test_that("Alternative products are found", {
  lambda_delta_gaps <- alternative_products(psmv_test, c("Lambda-Cyhalothrin", "Deltamethrin"), missing = TRUE)
  expect_equal(nrow(lambda_delta_gaps), 108L)
})
