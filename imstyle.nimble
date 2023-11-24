# Package

version       = "3.0.0"
author        = "Patitotective"
description   = "A nice way to manage your Dear ImGui application style"
license       = "MIT"

# Dependencies

requires "nim >= 1.6.8"
requires "kdl >= 2.0.0"
requires "nimgl >= 1.3.2"

task docs, "Generate documentation":
  exec "nim doc --git.url:https://github.com/Patitotective/ImStyle --git.commit:main --project --outdir:docs imstyle.nim"
  exec "echo \"<meta http-equiv=\\\"Refresh\\\" content=\\\"0; url='imstyle.html'\\\" />\" >> docs/index.html"
