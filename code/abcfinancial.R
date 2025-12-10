library(ompr)
library(dplyr)
library(ompr.roi)
library(ROI.plugin.glpk)

# --- 1. SETUP MOCK DATA (Representing the files provided) ---
# In a real scenario, these would be loaded via read.csv()
segments_df <- read.csv("data/segments.csv")
assets_df <- read.csv("data/assets.csv")

# # n = 72 segments
# segments_df <- data.frame(
#   id = 1:72,
#   segment_name = paste0("Seg_", 1:72),
#   asset = rep(1:18, each = 4), # Mapping 4 segments to each of 18 assets
#   exposure = runif(72, 10000, 100000),
#   risk_weight = runif(72, 0.2, 1.2),
#   profitability = rnorm(72, 0.05, 0.02),
#   cost_orig = 0.02,
#   cost_sell = 0.01
# )
# 
# # m = 18 asset classes
# assets_df <- data.frame(
#   id = 1:18,
#   asset_name = paste0("Asset_", 1:18),
#   max_inc = 0.15, # Example from assets.txt (e.g. 15%)
#   max_dec = 0.10  # Example from assets.txt (e.g. 10%)
# )

# Calculate aggregated current exposure per asset class for constraints
asset_current_total <- segments_df %>%
  group_by(asset) %>%
  summarise(total_exp = sum(exposure)) %>%
  pull(total_exp)

total_portfolio_exposure <- sum(segments_df$exposure)

# --- 2. DECLARATIVE MODELING WITH OMPR ---

model <- MIPModel() %>%
  
  # -- Decision Variables --
  # x[i]: Target exposure for segment i
  add_variable(x[i], type = "continuous", lb = 0, i = 1:72) %>%
  
  # buy[i] and sell[i]: Auxiliary variables for transaction costs
  add_variable(buy[i], type = "continuous", lb = 0, i = 1:72) %>%
  add_variable(sell[i], type = "continuous", lb = 0, i = 1:72) %>%
  
  # -- Objective Function --
  # Maximize Yield - Origination Costs - Selling Costs
  set_objective(
    sum_expr(x[i] * segments_df$profitability[i], i = 1:72) - 
    sum_expr(buy[i] * segments_df$cost_orig[i], i = 1:72) - 
    sum_expr(sell[i] * segments_df$cost_sell[i], i = 1:72), 
    sense = "max"
  ) %>%
  
  # -- Constraints --
  
  # 1. Flow Balance: Link Target Exposure to Trades
  # x_new = x_old + buy - sell
  add_constraint(
    x[i] == segments_df$exposure[i] + buy[i] - sell[i], 
    i = 1:72
  ) %>%
  
  # 2. Regulatory Risk Weight Limit (Linearized)
  # Sum(Exposure * Weight) <= 0.50 * Sum(Exposure)
  add_constraint(
    sum_expr(x[i] * segments_df$risk_weight[i], i = 1:72) <= 
    0.50 * sum_expr(x[i], i = 1:72)
  ) %>%
  
  # 3. Global Growth Limit (Total portfolio <= 120% of current)
  add_constraint(
    sum_expr(x[i], i = 1:72) <= 1.20 * total_portfolio_exposure
  ) %>%
  
  # 4. Asset Class Growth Limits
  # For each asset class 'a', the sum of its segments must not exceed limit
  add_constraint(
    sum_expr(x[i], i = 1:72, segments_df$asset[i] == a) <= 
    (1 + assets_df$max_inc[a]) * asset_current_total[a],
    a = 1:18
  ) %>%

  # 5. Asset Class Shrink Limits
  # For each asset class 'a', the sum of its segments must be at least limit
  add_constraint(
    sum_expr(x[i], i = 1:72, segments_df$asset[i] == a) >= 
    (1 - assets_df$max_dec[a]) * asset_current_total[a],
    a = 1:18
  )

# --- 3. INSPECT MODEL STRUCTURE ---
model
solve_model(model, with_ROI(solver = "glpk", verbose = TRUE))