#' Set the objective function to maximize net profit.
#'
#' @param model The OMPR model.
#' @param profitability A named vector of profitability for each segment.
#' @param cost_orig A named vector of origination costs for each segment.
#' @param cost_sell A named vector of selling costs for each segment.
#' @param segment_ids A vector of segment IDs.
#' @return The model with the objective function set.
set_objective_net_profit <- function(model, profitability, cost_orig, cost_sell, segment_ids) {
  set_objective(model,
    sum_expr(x[i] * profitability[i], i = segment_ids) -
    sum_expr(buy[i] * cost_orig[i], i = segment_ids) -
    sum_expr(sell[i] * cost_sell[i], i = segment_ids),
    sense = "max"
  )
}

#' Add the flow balance constraint.
#'
#' This constraint links the new exposure to the old exposure and the buy/sell decisions.
#' The formula is: x_new = x_old + buy - sell.
#'
#' @param model The OMPR model.
#' @param exposure A named vector of current exposure for each segment.
#' @param segment_ids A vector of segment IDs.
#' @return The model with the flow balance constraint added.
add_flow_balance_constraint <- function(model, exposure, segment_ids) {
  add_constraint(model,
    x[i] == exposure[i] + buy[i] - sell[i],
    i = segment_ids
  )
}

#' Add the portfolio-level average risk weight constraint.
#'
#' This constraint ensures that the weighted average risk of the portfolio does not exceed a certain threshold (0.50).
#'
#' @param model The OMPR model.
#' @param risk_weight A named vector of risk weights for each segment.
#' @param segment_ids A vector of segment IDs.
#' @return The model with the risk weight constraint added.
add_portfolio_risk_weight_constraint <- function(model, risk_weight, segment_ids) {
  add_constraint(model,
    sum_expr(x[i] * (risk_weight[i] - 0.50), i = segment_ids) <= 0
  )
}

#' Add the global growth limit for the total portfolio.
#'
#' This constraint limits the total portfolio exposure to 120% of the current total exposure.
#'
#' @param model The OMPR model.
#' @param total_portfolio_exposure The sum of the current exposure across all segments.
#' @param segment_ids A vector of segment IDs.
#' @return The model with the global growth constraint added.
add_global_growth_constraint <- function(model, total_portfolio_exposure, segment_ids) {
  add_constraint(model,
    sum_expr(x[i], i = segment_ids) <= 1.20 * total_portfolio_exposure
  )
}

#' Add lower and upper bound constraints on exposure change for each asset class.
#'
#' @param model The OMPR model.
#' @param segments_df A dataframe with segment data, including asset information.
#' @param asset_ids A vector of asset IDs.
#' @param max_inc A named vector of maximum exposure increase for each asset.
#' @param max_dec A named vector of maximum exposure decrease for each asset.
#' @param asset_current_total A named vector of the current total exposure for each asset.
#' @return The model with the asset exposure constraints added.
add_asset_exposure_constraints <- function(model, segments_df, asset_ids, max_inc, max_dec, asset_current_total) {
  for (a in asset_ids) {
    current_asset_segments <- segments_df$segment_id[segments_df$asset == a]
    
    # Upper bound on exposure change
    model <- add_constraint(
      model,
      sum_expr(x[i], i = current_asset_segments) <= (1 + max_inc[a]) * asset_current_total[a]
    )
    
    # Lower bound on exposure change
    model <- add_constraint(
      model,
      sum_expr(x[i], i = current_asset_segments) >= (1 - max_dec[a]) * asset_current_total[a]
    )
  }
  return(model)
}