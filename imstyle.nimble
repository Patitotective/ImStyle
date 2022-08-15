# Package

version       = "0.3.4"
author        = "Patitotective"
description   = "A nice way to manage your ImGui application's style"
license       = "MIT"

# Dependencies

requires "nim >= 1.6.2"
requires "nimgl >= 1.3.2"
requires "chroma >= 0.2.4"
requires "niprefs >= 0.3.0"

task docs, "Generate documentation":
  exec "nim doc --git.url:https://github.com/Patitotective/ImStyle --git.commit:main --project --outdir:docs imstyle.nim"
  exec "echo \"<meta http-equiv=\\\"Refresh\\\" content=\\\"0; url='imstyle.html'\\\" />\" >> docs/index.html"
