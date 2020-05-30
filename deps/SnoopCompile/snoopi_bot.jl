using SnoopCompile

botconfig = BotConfig(
  "AcuteBenchmark";
  os = ["linux", "windows", "macos"],
  version = [v"1.4", v"1.3", v"1.2"],
  blacklist = [],
  exhaustive = false,
)

snoopi_bot(
  botconfig,
  "$(@__DIR__)/example_script.jl",
)
