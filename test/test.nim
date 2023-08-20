import std/unittest

import kdl
import imstyle
import nimgl/imgui

test "can load style":
  check initImGuiStyle().encode().decode(ImGuiStyle) == initImGuiStyle()
