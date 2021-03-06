metadata_packages = [
    "BinDeps",
    "Cairo",
    "Calculus",
    "Clustering",
    "Compose",
    "DataArrays",
    "DataFrames",
    "DataFramesMeta",
    "Dates",
    "DecisionTree",
    "Distributions",
    "Distances",
    "Gadfly",
    "GLM",
    "HDF5",
    "HypothesisTests",
    "FunctionalDataUtils",
    "JSON",
    "KernelDensity",
    "Lora",
    "Loess",
    "MLBase",
    "MultivariateStats",
    "NMF",
    "Optim",
    "PDMats",
    "RDatasets",
    "SQLite",
    "StatsBase",
    "TextAnalysis",
    "TimeSeries",
    "ZipFile",
    "IJulia",
    "JLD"]


Pkg.init()
Pkg.update()

for package=metadata_packages
    Pkg.add(package)
end

Pkg.resolve()


# need to build XGBoost version for it to work
Pkg.clone("https://github.com/antinucleon/XGBoost.jl.git")
Pkg.build("XGBoost")

Pkg.clone("https://github.com/mschauer/CausalInference.jl")
Pkg.pin("CausalInference")


Pkg.clone("https://github.com/benhamner/MachineLearning.jl")
Pkg.pin("MachineLearning")

Pkg.resolve()

Pkg.add("ProgressMeter")

https://github.com/dysonance/Strategems.jl
