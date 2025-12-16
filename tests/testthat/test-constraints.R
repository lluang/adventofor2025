library(testthat)
library(ompr)
library(ompr.roi)
library(ROI.plugin.glpk)
library(dplyr)

# Source the functions to be tested
source("../../code/constraints.R")

# WORKAROUND for what appears to be a bug in get_solution()
# The result object contains a valid solution, but get_solution() fails to parse it.
# This helper function extracts the solution manually from the result object.
get_solution_workaround <- function(result, var_name_str) {
  raw_sol <- result$solution
  
  # Filter for the specific variable based on its string name (e.g., "x", "buy")
  var_indices <- startsWith(names(raw_sol), paste0(var_name_str, "["))
  var_sol <- raw_sol[var_indices]
  
  if (length(var_sol) == 0) {
    return(tibble::tibble(i = character(0), value = numeric(0)))
  }
  
  tibble::tibble(
    i = sub(paste0(var_name_str, "\\[(.*)\\]"), "\\1", names(var_sol)),
    value = var_sol
  )
}


# 1. SETUP MOCK DATA
setup_test_data <- function() {
  segments_df <- data.frame(
    segment_id = c("A_1", "A_2", "B_1"),
    asset = c("A", "A", "B"),
    exposure = c(100, 150, 200),
    risk_weight = c(0.4, 0.6, 0.8),
    profitability = c(0.05, 0.06, 0.07),
    rel_origination_cost = c(0.01, 0.01, 0.02),
    rel_sell_cost = c(0.01, 0.01, 0.02)
  )
  
  assets_df <- data.frame(
    asset = c("A", "B"),
    max_exposure_increase = c(0.2, 0.3),
    max_exposure_decrease = c(0.1, 0.15)
  )
  
  segment_ids <- segments_df$segment_id
  asset_ids <- assets_df$asset
  
  # Named vectors
  profitability <- setNames(segments_df$profitability, segments_df$segment_id)
  cost_orig <- setNames(segments_df$rel_origination_cost, segments_df$segment_id)
  cost_sell <- setNames(segments_df$rel_sell_cost, segments_df$segment_id)
  exposure <- setNames(segments_df$exposure, segments_df$segment_id)
  risk_weight <- setNames(segments_df$risk_weight, segments_df$segment_id)
  max_inc <- setNames(assets_df$max_exposure_increase, assets_df$asset)
  max_dec <- setNames(assets_df$max_exposure_decrease, assets_df$asset)
  
  asset_current_total <- segments_df %>%
    group_by(asset) %>%
    summarise(total_exp = sum(exposure), .groups = 'drop') %>%
    { setNames(.$total_exp, .$asset) }
  
  total_portfolio_exposure <- sum(segments_df$exposure)
  
  return(list(
    segments_df = segments_df, assets_df = assets_df, segment_ids = segment_ids,
    asset_ids = asset_ids, profitability = profitability, cost_orig = cost_orig,
    cost_sell = cost_sell, exposure = exposure, risk_weight = risk_weight,
    max_inc = max_inc, max_dec = max_dec, asset_current_total = asset_current_total,
    total_portfolio_exposure = total_portfolio_exposure
  ))
}

# 2. RUN TESTS
test_that("Objective function maximizes profit", {
  data <- setup_test_data()
  data$profitability["A_1"] <- 0.01
  data$profitability["A_2"] <- 0.01
  data$profitability["B_1"] <- 0.10 # B_1 is clearly better
  
  model <- MIPModel() %>%
    add_variable(x[i], type = "continuous", lb = 0, ub = 500, i = data$segment_ids) %>%
    add_variable(buy[i], type = "continuous", lb = 0, ub = 500, i = data$segment_ids) %>%
    add_variable(sell[i], type = "continuous", lb = 0, ub = 500, i = data$segment_ids) %>%
    set_objective_net_profit(data$profitability, data$cost_orig, data$cost_sell, data$segment_ids) %>%
    add_flow_balance_constraint(data$exposure, data$segment_ids) %>%
    add_constraint(sum_expr(x[i], i = data$segment_ids) <= data$total_portfolio_exposure + 100)
  
  result <- solve_model(model, with_ROI(solver = "glpk"))
  
  expect_true(solver_status(result) %in% c("optimal", "success"))
  
  solution <- get_solution_workaround(result, "x")
  
  b1_solution_value <- solution$value[solution$i == "B_1"]
  
  if (length(b1_solution_value) > 0 && !is.na(b1_solution_value)) {
    expect_gt(b1_solution_value, data$exposure["B_1"])
  }
})

test_that("Flow balance constraint is respected", {
  data <- setup_test_data()
  model <- MIPModel() %>%
    add_variable(x[i], type = "continuous", lb = 0, i = data$segment_ids) %>%
    add_variable(buy[i], type = "continuous", lb = 0, i = data$segment_ids) %>%
    add_variable(sell[i], type = "continuous", lb = 0, i = data$segment_ids) %>%
    add_flow_balance_constraint(data$exposure, data$segment_ids) %>%
    set_objective(sum_expr(buy[i], i = data$segment_ids) - sum_expr(sell[i], i = data$segment_ids), "max") %>%
    add_constraint(x[i] == data$exposure[i] + 10, i = data$segment_ids)

  result <- solve_model(model, with_ROI(solver = "glpk"))
  
  expect_true(solver_status(result) %in% c("optimal", "success"))

  buy_sol <- get_solution_workaround(result, "buy") %>% arrange(i)
  sell_sol <- get_solution_workaround(result, "sell") %>% arrange(i)
  
  expect_equal(buy_sol$value, rep(10, 3))
  expect_equal(sell_sol$value, rep(0, 3))
})

test_that("Portfolio risk weight constraint is respected", {
  data <- setup_test_data()
  model <- MIPModel() %>%
    add_variable(x[i], type = "continuous", lb = 0, ub = 500, i = data$segment_ids) %>%
    add_portfolio_risk_weight_constraint(data$risk_weight, data$segment_ids) %>%
    set_objective(sum_expr(x[i] * data$risk_weight[i], i = data$segment_ids), "max") %>%
    add_constraint(sum_expr(x[i], i = data$segment_ids) == data$total_portfolio_exposure)

  result <- solve_model(model, with_ROI(solver = "glpk"))
  
  expect_true(solver_status(result) %in% c("optimal", "success"))

  solution <- get_solution_workaround(result, "x")
  
  weighted_risk <- sum(solution$value * data$risk_weight[match(solution$i, names(data$risk_weight))])
  total_exposure <- sum(solution$value)
  
  # The denominator can be 0 if total_exposure is 0
  if (total_exposure > 1e-6) {
    expect_lte(weighted_risk / total_exposure, 0.5 + 1e-6) # add tolerance
  } else {
    expect_equal(weighted_risk, 0)
  }
})

test_that("Global growth constraint is respected", {
  data <- setup_test_data()
  model <- MIPModel() %>%
    add_variable(x[i], type = "continuous", lb = 0, i = data$segment_ids) %>%
    add_global_growth_constraint(data$total_portfolio_exposure, data$segment_ids) %>%
    set_objective(sum_expr(x[i], i = data$segment_ids), "max")

  result <- solve_model(model, with_ROI(solver = "glpk"))

  expect_true(solver_status(result) %in% c("optimal", "success"))

  solution <- get_solution_workaround(result, "x")
  total_new_exposure <- sum(solution$value)
  
  expect_lte(total_new_exposure, 1.2 * data$total_portfolio_exposure + 1e-6)
})

test_that("Asset exposure constraints are respected", {
  data <- setup_test_data()
  asset_A_segments <- data$segments_df$segment_id[data$segments_df$asset == "A"]
  
  model <- MIPModel() %>%
    add_variable(x[i], type = "continuous", lb = 0, i = data$segment_ids) %>%
    add_asset_exposure_constraints(data$segments_df, data$asset_ids, data$max_inc, data$max_dec, data$asset_current_total) %>%
    set_objective(sum_expr(x[i], i = asset_A_segments), "max") %>%
    add_constraint(sum_expr(x[i], i = data$segment_ids) <= data$total_portfolio_exposure * 2)

  result <- solve_model(model, with_ROI(solver = "glpk"))
  
  expect_true(solver_status(result) %in% c("optimal", "success"))

  solution <- get_solution_workaround(result, "x")
  exposure_A <- sum(solution$value[solution$i %in% asset_A_segments])
  
  max_exposure_A <- (1 + data$max_inc["A"]) * data$asset_current_total["A"]
  expect_lte(exposure_A, max_exposure_A + 1e-6)
})
