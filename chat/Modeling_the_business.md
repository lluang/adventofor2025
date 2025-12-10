# Modeling the business

Hello and welcome to Day 6!

So far, you’ve done the crucial groundwork for ABC Financial:
You've identified the key pain point: manual, decentralized quarterly planning for their loans portfolio.

You’ve defined the objective: maximize profit while maintaining regulatory and internal guardrails.

Crucially, in Day 5, you thoroughly examined the data (exposures, profit, risk, cost, and asset-level constraints) and established data ownership.

Today, we translate everything you've learned into math.

 Your first optimization model for ABC Financial.

But here's what most courses won't tell you: the first model is never the final model. What matters is getting something down that's good enough to start the conversation

# Defining the business goals with mathematical precision

The desired outcome of ABC financial is to centralize and streamline this quarterly process that defines the target exposure in each sector for the next quarter.
Keep in mind, this will only be our first iteration, and to maximize our likelihood of successfully addressing the business problem, our approach needs to be flexible enough to incorporate feedback and make changes to improve decisions and outcomes.


This has been deeply engrained at FICO for many years, as can be seen in our Chief Product and Technology Officer’s blog post from back in 2019. Seeing the limitations in tooling for operationalizing analytics, FICO Xpress developed FICO Xpress Insight, our deployment platform that empowers analytics professionals to quickly incorporate feedback and redeploy their analytics applications to end-users.

# 
Structuring the optimization model
Because their business problem includes ensuring certain guardrails are met (constraints), with clear, measurable target KPIs (objective function) and deciding what the target exposure should be (decisions). The natural methodology for solving this business problem seems to be formulating an optimization problem.
Given the sample data that you’ve been given. Begin the process of formulating your initial optimization model. Remember to identify the key aspects of the optimization model.
Decisions (variables): What is the primary variable you need to calculate for the next quarter? Are there any auxiliary variables you might need to model costs or changes?
Constraints: Identify all the portfolio-level constraints as well as the loan type/asset-level constraints.
Criteria (Objectives): How will you mathematically represent the goal of “maximize profits from the portfolio”?
Ensure to document the assumptions you make in your modelling approach. Remember models are simplifications of the real world that guide our decisions. As the saying goes, “All models are wrong, some are useful”.

