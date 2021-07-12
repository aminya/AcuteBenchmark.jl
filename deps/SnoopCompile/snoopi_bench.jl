using SnoopCompile

botconfig = BotConfig(
  "AcuteBenchmark";
  os = ["linux", "windows", "macos"],
  version = [v"1.4", v"1.3", v"1.2"],
  blacklist = [],
  exhaustive = false,
)


println("Benchmarking the inference time of `using AcuteBenchmark`")
snoopi_bench(
  botconfig,
  :(using AcuteBenchmark),
)


println("Benchmarking the inference time of `using AcuteBenchmark` & basic function test")
snoopi_bench(
  botconfig,
  "$(@__DIR__)/example_script.jl",
)
