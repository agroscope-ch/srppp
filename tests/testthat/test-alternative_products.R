test_that("Alternative products are found", {
  lambda_delta_gaps <- alternative_products(psmv_test, c("Lambda-Cyhalothrin", "Deltamethrin"),
    missing = TRUE)
  expect_equal(nrow(lambda_delta_gaps), 108L)

  lambda_delta_gaps_it <- alternative_products(psmv_test, c("Lambda-Cialotrina", "Deltametrina"), 
    missing = TRUE, lang = "it")
  expect_equal(nrow(lambda_delta_gaps_it), 108L)

  expect_error(alternative_products(psmv_test, c("test"), lang = "at"))
})
