part of [[Advent of OR]]

## 

Yesterday [[The data-analytics approach connection]] you explored four files: segment exposures, asset constraints, quarterly profitability history, and segment-level profitability means.

The key question was: How should we turn historical profitability into a single number we can optimize?

After discussing with ABC Financial, we've made a modeling decision:

### ![📊](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEgAAABICAYAAABV7bNHAAADhklEQVR4Aeybz08TURDHhyYELEghAYIHEAzGg71wMoaY0MSDV+4ab3rw4n8ARv8FjyZG/wD0DzBITCUcgJLU8Ds0rQZDaEpbWgi01T72vXYX3uy0TSlddgjfne1Md97OZ1+bN93WA/xnS4AB2eIBKAGamf0xMfMtOM2SDGbnhwW7EiAoeCZaWmBKqK/HN+VWdd/sOGMAkDsHSOCSGh+7D26V/+6IpGAYj2F4ixFgQBgZ6WdAEgRmGBBGRvoZkASBGQaEkZF+BiRBYIYBYWSkXwtoPRIDp2lp+w+8Wcja6tNKgqwrtrsn0RhGC2g/kQJUTRp7Hz6F6YWMrZ7P5ci6kocZg4zcagE5sc0YGuiXJdkbqjZuNez5XYhqZ9CFZ7nYwYCIi8+AGBBBgAjzDGJABAEizDOoFkDB5V/gNEX/WlsErG6qrvDmjuVQ7Qzq7ekCp8nb3mYpDHtA1eXr7LAcqgV0b3gQnKbebp+lMOwBVdfgLWvLogWEJXejvxGAHM2VARGXr2pA8WwMPodew4fFF6i+rL4lhnVOuGpA0WQITvJZ2woFxN30hu1znBKsGpBTCqvXeTIggiQDqgWQ3XI8eu5Tfyx/eGunoe1K07Qa3vZ2jInFL5bs1LK+nvGmaTVEURYSyIPB4l0Gallfzzi3GsiFuGw3v0kThBlQMwPKB+cg8/iBrY5ePiNKuNzwlc6gwvamvjqTt7C9AfmVJZOnsbtXCqixpdY2GgMiuDGgWgB9nf0JmNZ2YkRKIxwMhdEcKvdapMJcy/XLpcbGbLA4llGBsdXOoPExP2Cq9Hs4/tERNIfKPTTQZ5wFsRXf2VHHYLbSXNjxyi/GMp+OFlBvd/G2DyLvjcpur5z1YkgOlb+qvq5OudTYmBXnTQIyP8Ht+9oZ5HYo5voZkJmGZp8BaaCYXQzITEOzz4A0UMwuBmSmodm/LoA0pdXHpQWELcOFn1uNIni17NZZbjWKgLBluPBzq1EExP9lAtr3oHKY9xgQMQcYEAMiCBBhnkEMiCBAhLUzaP8gBZiOs63Qmh8glU6fojlU7nibFxK3R0nFcwUyV2fhEPwdR6TU2Jit6Ee94pN9THvRLvBlnpBaXU8ClkP5F/qHYfHpK1LzqRMy1+jxFry785uUGhuzFf1Wg5h1rgqXX2Iez8d/LYWAa0TUCpALiZlQAjQZeBiZDDz6zlIMAgcC0H8AAAD//89wtDwAAAAGSURBVAMA/X3M687Q/aUAAAAASUVORK5CYII=) Assumption: Average historical profitability

We'll use the mean profitability per segment across all available quarters.

Why averages? Three reasons:

1. We're not forecasting. ABC Financial wants quarterly rebalancing decisions, not predictions. Building a forecasting model would be a separate project.
    
2. Simplicity first. The historical average is an unbiased estimator when we have no reason to believe the future will differ systematically from the past. It's the simplest reasonable assumption.
    
3. Baseline before complexity. Once we have a working model with averages, we can explore alternatives: weighted recent averages, worst-case scenarios, or even stochastic optimization. But we need the baseline first.
    

This is a modeling assumption, not a fact. Document it. Communicate it to stakeholders. And be ready to revisit it if the business context changes.

### The five data problems that break trust

Even with clean, consolidated data, your job isn't done.

Every assumption we made -using averages, trusting the cost coefficients, accepting the constraint values- needs to be validated. And five types of data problems can still break your model:

[[Missing data]]. Null values or collection failures. A missing risk weight could mean treating a high-risk segment as risk-free.

[[Wrong data]]. Values recorded incorrectly. A segment marked as "Prime" when the underlying loans are subprime.

Correct data with [[poor quality]]. Inconsistent naming. Is it "PersonalLoans" or "Personal_Loans"?

[[Conflicting data]]. Two sources say different things about the same segment.

[[Contextually-incomplete data]]. Data that looks fine but misses business rules the model should respect.

→ Owning the inputs means you detect, classify, and handle these explicitly before running any model.

  
  
**