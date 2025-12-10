{parent}:[[Advent of OR]]

When evaluating which [[solver]] to use, it’s important to consider what type of [[optimization problem]] you are solving.
Is it a Mixed Integer Program, Quadratic Program, Mixed Integer Quadratically Constrained Program, Second Order-Cone Program, Non-linear program, Constraint Program, Mixed-Integer Non-linear Program or Black Box Optimization?
When asked, optimizers believe the most important feature for solver selection is solve speed. This unfortunately doesn’t make the solver selection process any easier as solve times can be significantly reduced by tuning the individual solvers’ parameters instead of using the default settings.

We’ll get to this in a future post.

Despite what individual solver marketing assets say, the truth is that there is no one solver that is fastest on all types of optimization problems that exist. As such, when evaluating solvers, the best strategy is to ensure you test all solvers capable of solving the problem and tuning each of their parameters to get the best performance.

Solver tuning has been shown to improve performance by up to 600x in some instances.

## Getting the right solver

One concern you may have is having to write your model using the API of each of the solvers you evaluate.
Luckily, this is not necessary as there exists an industry standard output file that can be read in by any solver. This is how benchmarking was done and published openly before 2018.

Finally, another factor you should consider is how your choice reduces time to value. Beyond just a state-of-the-art solver, FICO Xpress also developed a free algebraic programming language and a deployment platform.

The [[algebraic programming language]] named Mosel allows writing models using lexicon similar to English but with the performance of efficient C-code.

These features, which are not usually top of mind, make a huge difference on the impact your data science team can have on your organization.

