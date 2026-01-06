{parent}:[[Advent of OR]]

## Why risk matters (and how to handle it)

The team is satisfied with your demonstration from Day 11, and as often happens in real projects, they've continued thinking about what else might be possible. This is exactly what you expected: you have experience with [[Agile]] development, so new requirements at this stage are manageable, not catastrophic.

Here's what the ABC Financial team explained in your follow-up meeting:

The core request:

Beyond maximizing profitability, they've realized that assets in their portfolio exhibit important [[correlation patterns]]. For example, mortgages and credit card balances are only weakly correlated: someone might default on credit cards while still paying their mortgage, but the reverse is less common. These correlation structures matter when you're rebalancing billions of dollars quarterly.

The data they're providing:

The team has furnished you with:

- Expected return variance for each asset
    
- A covariance matrix showing how returns co-vary across all asset pairs
    

Their main challenge:

The portfolio team's biggest pain point is that variance-based risk measures require instance-specific tuning. Finding the right normalization factor that balances risk against expected profit varies dramatically across different market conditions and portfolio compositions.

They want to know: Can your optimization model incorporate this in a way that doesn't require them to manually tune normalization factors for every quarterly rebalancing?

### Understanding the technical challenge

This request reveals a sophisticated understanding of multi-objective optimization. The team is asking how to systematically explore tradeoffs between profit and risk.

The challenge lies in combining objectives with fundamentally different scales:

- Profit is measured in dollars (potentially millions)
    
- Covariance (a proxy for risk) is measured in squared units and can range dramatically
    

Traditional weighted-sum approaches require you to find the "right" weight λ for an objective like maximize (profit - λ·risk). But what should λ be? 1? 0.001? 1000? The answer changes with every instance, making this approach impractical for production systems.

### The solution: hierarchical optimization

Instead of wrestling with normalization, you can use hierarchical optimization (also called lexicographic or sequential optimization):

Step 1: Maximize profit

First, solve the model to find the maximum achievable net profit under all constraints:

#### maximize: net_profit

#### subject to: [all portfolio constraints]

  

Let's call this optimal value P*.

Step 2: Minimize risk at different profit levels

Next, solve a series of problems that minimize risk while requiring profit to be at least some percentage of P*:

#### minimize: covariance

#### subject to:

####     [all portfolio constraints]

####     net_profit ≥ α · P* where α ∈ {0.5, 0.7, 0.9, etc.}

####   

  
  

This approach generates a risk-return curve showing what risk levels are achievable at different profit targets. Critically, it requires no normalization because you're optimizing one objective at a time.

Why this works in production:

1. Interpretability: Stakeholders can say "I want at least 90% of maximum profit, what's my risk?" rather than trying to interpret a λ weight
    
2. Robustness: The approach works regardless of instance size or market conditions
    
3. Flexibility: Different stakeholders can pick different points on the curve based on their risk tolerance
    

  

### Why cloud deployment matters here

This is where the theory meets production reality. Your hierarchical optimization approach needs to run multiple model variants (profit maximization + several risk minimization [[scenarios]]). In a traditional setup, this means:

- Running the same code multiple times with different parameters
    
- Managing output files from each run
    
- Manually comparing results across scenarios
    
- Repeating this entire process for every data update
    

The Nextmv difference:

When you push your model to the Nextmv platform, you gain:

[[Parameterization]] without code changes

Define profit threshold levels (50%, 70%, 90%) as configuration parameters (Nextmv calls these [Options](https://gamvzw.clicks.mlsend.com/ty/cl/eyJ2Ijoie1wiYVwiOjUyODU2NixcImxcIjoxNzM1NDI0Mzc5OTE0ODI5MDIsXCJyXCI6MTczNTYzMzA4MjMxNjIzNzYwfSIsInMiOiIzMzAzODI0YmI4MTBhYTkzIn0)!). Stakeholders can adjust these through the UI without touching your code.

[[Scenario testing]] at scale

Run all profit-risk combinations in parallel and compare results side-by-side. The platform handles orchestration and result aggregation automatically.

Audit trail

Every scenario run is logged with its inputs, outputs, and timestamps. When stakeholders ask "What risk level did we see at 85% profit in last quarter's data?" you have instant answers.

[[Version control]]

When you extend the model later (and you will), you can A/B test the old vs. new formulation on historical data before deploying to production.

This is the essence of [[DecisionOps]]: treating your optimization models like software products with proper development, testing, and deployment workflows.

  
  
  

## What you're building

Your goal is to generate a risk-return tradeoff curve that shows: "If I'm willing to accept X% of maximum profit, what's the minimum risk I can achieve?"

This requires two types of models working in sequence:

Model 1: Profit maximizer ([[Linear Program]])

- Same constraints as Day 11 (exposure limits, risk weights, transaction costs)
    
- Objective: Maximize net profit
    
- Output: The maximum achievable profit P*
    

Model 2: Risk minimizer ([[Quadratic Program]])

- Same constraints as Model 1
    
- Plus: New constraint requiring profit ≥ α · P* where α is your target (e.g., 0.9 for 90%)
    
- Objective: Minimize portfolio risk (measured by covariance)
    
- Output: Minimum achievable risk at that profit level
    

### The three-step workflow

Step 1: Establish the profit ceiling

Run Model 1 to find P*. This tells you the absolute best profit you can achieve under all constraints. Let's say P* = $50M.

Step 2: Map the tradeoff curve

For each profit target level you care about (50%, 70%, 90%, 95% of P*), run Model 2, so you answer the question “What’s the minimum risk at this level of profit?”. Each target level gives you one point on your tradeoff curve.

Step 3: Present results

Now stakeholders can have an interpretable conversation with the output in table format:

- "We need at least $45M profit for our targets → minimum risk is 95"
    
- "If we're willing to accept $35M profit → we could cut risk nearly in half to 45"
    
- "Going from 90% to 95% max profit increases risk by 58% - is it worth it?"
    

No magic weights needed. No normalization hassles. Just clear, instance-independent tradeoffs.

### The GAMSPy pattern

Here's how simple this looks in code:

  

#### # Step 1: Find maximum profit

#### max_net_profit.solve()

#### maximum_net_profit = max_net_profit.objective_value

#### # Step 2: For each profit level, minimize risk 

#### net_profit.lo = 0.8 * maximum_net_profit # Set lower bound

#### min_covariance.solve(solver="xpress")

That's it! The key is GAMSPy's .lo attribute - it sets a lower bound on your profit variable. Change the multiplier (0.8, 0.7, 0.5) and solve again to get different points on your tradeoff curve.

### Why this is quadratic (QCP)

The risk equation involves quadratic terms:

#### Risk = Σᵢ Σⱼ (exposureᵢ · Cov(i,j) · exposureⱼ)

This means Model 2 requires a QCP (Quadratically Constrained Program) solver, not just LP. FICO Xpress handles this - just specify problem=gp.Problem.QCP when defining your risk minimization model.

### Making it configurable for Nextmv

The key insight: those profit levels (50%, 70%, 90%, 95%) should be parameters, not hardcoded values.

Structure your model so stakeholders can adjust:

- Which profit levels to test (default: [0.5, 0.7, 0.9, 0.95])
    
- Whether to run risk minimization at all (select for profit-only vs. risk-aware)
    
- Visualization preferences (which scenarios to highlight)
    

When deployed to Nextmv, portfolio managers can change these through a UI without touching code. They run scenarios, compare results side-by-side, and pick their preferred risk-return position - all in minutes instead of days.

Hey, Louis Luangkesorn, did you notice that? It's the first time we have different domains at the same time... Going backwards! Why is that?

Today marks a critical evolution in your ABC Financial project.

The stakeholders initially asked you to maximize profit. After seeing your first version, they now want you to balance maximizing profit while minimizing risk.

Specifically, they want to understand how profit variability across different assets affects the portfolio's overall stability. And they also gave you different data scenarios. In other words: You have a model version 2 to build and present.

That's why you'll need to...

1. Frame the problem again to understand the new requirements.
    
2. Take a look at the new data.
    
3. Extend your model.
    
4. Deploy it to the Nextmv platform for comparison and scenario testing.
    

  
**