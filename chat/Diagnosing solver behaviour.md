{parent}:[[Advent of OR]]

Every optimization model will perform differently and even individual instances of the same optimization model could have different behaviour for the same solver.

That’s the reason why with each solve, FICO Xpress produces a log life that provides “the stORy” of how your optimization problem is being solved.

In general, solving an optimization model to proven optimality is comprised of four actions:
 - presolve executed at the beginning to reduce the size of the original problem
- cutting to improve dual bound
- heuristics to find improving feasible solutions/primal bounds
- branching to create and explore different subproblems in a search tree

The first part of the solver log will contain the following elements:
- information on the solver version
- any non-default solver settings you’ve configured
- problem size details before and after presolve
- coefficient statistics before and after autoscaling
- solving the linear programming relaxation  

Things to look out for in this first section are to see the impact of presolve which, as seen in the image above, reduced the number of variables by 20% as well as the range of coefficients for which large ranges indicate risk of numerically unstable models. You can refer to this blog for other ways to detect and treat numerical instability.

Though the log for solving the linear relaxation will vary depending on which algorithm is used, the key information to note is the optimal value and the corresponding algorithm used.
When solving Mixed Integer Programs, the second part of the solver log corresponds to the creation and searching of the branch and bound tree. It’s displayed in a table-like format with each line informing the progress of the solver in chronological order. This can then itself be split into two sections:
- Solving the root node (adding valid cuts and running heuristics)
- Exploring subproblems defined by the branch-and-bound tree  

During the process, the solver will flag different types of cuts and heuristics it executes by printing either an asterisk, a small case letter, or an upper-case letter. For a detailed guide on identifying them you can refer to the following webpage.

Amongst the most important information to track in the MIP Log is the Gap, which provides an upper bound on how far away from the optimal solution your incumbent solution is. MIPs that keep having a large Gap after some time, are likely difficult to solve to proven optimality. This usually occurs either because the solver has a hard time finding high quality feasible solutions, or the dual bounds are weak and require significant exploration to close the gap.

A priori, it’s difficult to tell with certainty which is the culprit. However, looking at other instances of the same model that you’re able to solve to proven optimality can provide some insight. Things to look out for are how far away the linear programming relaxation is from the provenly optimal solution, indicating weak dual bounds, and how early a high-quality feasible solution is found and improved.

Overall, the solver log will display the symptoms and you’re the doctor that will diagnose and cure by reading it and prescribing the medicine which usually comes in the form of tuning the solver’s control parameters or reformulating the model.


## Exposing solver logs



You initiated a model run. You step away from your computer. But when you come back, it’s still running. Hmmm… It’s taking longer than you expected. You wait just a bit more and the run finally completes. What happened? To answer this, we go to the logs! 
While it’s common to create a separate logs file to log the logs, with Nextmv you don’t have to do that. As you saw with the local development experience, your solver logs got saved to a directory alongside the model run it’s associated with.
The same pattern holds true when you make remote runs with Nextmv: solver logs are accessible alongside all the other run information (e.g., input, output, visuals, etc.)
As a bonus, you can use the Nextmv Python SDK to write additional logs to track additional information.








nextmv.log("I logged a message to stderr using the nextmv module directly")




What’s more: When all of your logs are housed within a single collaboration platform, they’re accessible across teammates. So when your colleague goes on vacation and you can’t figure out why something’s going sideways, you have access to their run history and their run logs. That’s pretty nice. That’s good practice. 







