I have created a suite of tests for the model's constraints. Here’s what I did:

1.  **Test Structure:** I’ve set up a standard R testing structure using the `testthat` package. This includes:
    *   A `tests/testthat` directory.
    *   A `tests/testthat.R` script to run your tests.
    *   A `tests/testthat/test-constraints.R` file containing the actual tests.

2.  **Test Coverage:** The tests cover all the functions we previously refactored into `code/constraints.R`:
    *   `set_objective_net_profit()`
    *   `add_flow_balance_constraint()`
    *   `add_portfolio_risk_weight_constraint()`
    *   `add_global_growth_constraint()`
    *   `add_asset_exposure_constraints()`

3.  **Mock Data:** Inside the test script, I created a small, self-contained set of mock data. This ensures the tests are predictable and don't rely on the external CSV files.

To run these tests, you would typically execute the `tests/testthat.R` script from your R console or use `testthat::test_dir("tests/testthat")`. This will give you a report on whether each constraint function is behaving as expected.
