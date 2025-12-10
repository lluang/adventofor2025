part of [[Advent of OR]]

After three meetings, you've built a solid understanding of ABC Financial's [[portfolio rebalancing]] problem:

The business problem: ABC Financial needs to make centralized, informed quarterly decisions about rebalancing their loan portfolio while respecting [[business unit constraints]] and regulatory risk weight limits.

The [[objective]] seems to be the maximization of profitability while accounting for transaction costs (selling existing loans) and origination costs (creating new loans).

The [[constraints]]: Portfolio-level risk weight ≤ 50%, total exposure growth ≤ 20% per quarter, plus asset-specific growth and shrink limits from each business unit.

The process: Quarterly rebalancing decisions.

This sounds like an optimization problem. But, here's what many analytics professionals miss:

→ The data you have available determines whether you can actually build the solution you envision.


🔍 Data constrains your analytics approach
You might have a perfect understanding of the business problem, but if the data doesn't exist or isn't reliable, your sophisticated analytics approach becomes irrelevant.

Think about it:

If you don't have historical profitability data by segment, how would you know which segments to grow?

If you don't have asset-level constraint data, how would you respect business unit requirements?

If you don't have cost coefficients for transactions, how would you balance growth decisions against their costs?

This is why experienced OR professionals always ask to see the data early. Not to start modeling immediately, but to validate that the analytics approach they're considering is actually feasible.


📊 From [[problem framing]] to [[analytics framing]]
Inside the [[INFORMS Analytics Framework]] we can see there’s…

Domain 2 - [[Analytics Problem Framing]]: translating the business problem into an analytics problem you can solve.
Domain 3 - Data: understanding what inputs you have available and what they tell you about feasible solution approaches.
These domains are deeply intertwined. The data sample ABC Financial sends will help you:

Confirm your [[problem understanding]] - Does the data structure match what they described?
Identify analytics approach constraints - What methods are feasible given this data?
[[Surface hidden assumptions]] - What's missing? What's surprising?
[[Build trust]] - Show you understand their data before proposing solutions.
The key principle: Look before you model.

🧪 THE PRACTICE
Initial raw data from ABC Financial
The team shared four files with us. Normally, a client won't give you clean, pre-structured data. This is typical and actually valuable: raw data reveals how they actually store and use this information. Your first job is to understand what you have and how it connects to your problem.

We need to answer two core questions immediately:

Structure: How do we combine these files to get all the necessary parameters (Profitability, Risk, Costs, Exposure, and Constraints) in one place?
Model Input: How should we treat the time-series data? Since the rebalancing process is quarterly and we are not doing predictions, does it make sense to simplify the objective by taking averages of historical profitability, or should we ask for a forecast?
Take a look at the data tables provided:

segments.csv: Contains segment-level details (exposure, risk_weight, rel_sell_cost, rel_origination_cost). This is the grain for our final decision variables.
assets.csv: Contains the asset-level growth/shrink constraints (max_exposure_decrease, max_exposure_increase).
segment_profitability_means.csv & loan_profitability_per_quarter.csv: These are two different views on profitability. The first is segmented by risk level; the second is a long-term quarter-by-quarter history.

📋 What data structure would we prefer?
For optimization, we'd ideally want data at the same grain as our decisions.

Our decisions are: exposure levels by segment (asset type × risk level).

So we'd want:

One row per segment
Columns for: current exposure, profitability, risk weight, costs, constraints
Clear keys to join data tables
Looking at what we have: It's organized by loan type (asset) and separately by segment (asset × risk). We'll need to restructure this to get segment-level data that combines both dimensions.

This work is what transforms "raw business data" into "model-ready inputs".