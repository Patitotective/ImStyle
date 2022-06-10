## ImStyle is a library that helps you to manage your Dear ImGui application's style.  
## Load the style from a TOML file rather than hard-coding it into your app.  
## Using ImStyle also allows you to change your app's style without compiling it again (since the style is read from a file).
## 
## Without ImStyle you need to set the style in your code:
## ```nim
## import nimgl/imgui
## ...
## let style = igGetStyle()
## style.alpha = 1f
## style.windowPadding = ImVec2(x: 4f, y: 4f)
## style.windowMenuButtonPosition = ImGuiDir.Left
## style.colors[ord Text] = ImVec4(x: 0f, y: 0f, z: 0f, w: 1f) # RGBA
## ...
## ```
## Using ImStyle you will only need to create a TOML file (e.i.: `style.toml`), that will look like:
## ```nim
## # ImStyle
## alpha = 1 # -> 1.0
## windowPadding = [4, 4] # -> ImVec2(x: 4.0, y: 4.0) 
## windowMenuButtonPosition = "Left"
## ...
## [colors]
## Text = "#000000" # or "rgb(0, 0, 0)" or or "rgba(0, 0, 0, 1)" or [0, 0, 0, 1]
## ...
## ```
## And load it in your code:
## ```nim
## import imstyle
## ...
## igGetCurrentContext().style = styleFromToml("style.toml")
## ...
## ```

import std/[strformat, strutils, macros]
import chroma
import niprefs
import nimgl/imgui

export niprefs, imgui

const defaultIgnoreProps = ["touchExtraPadding", "logSliderDeadzone", "displayWindowPadding", "displaySafeAreaPadding", "mouseCursorScale", "antiAliasedLines", "antiAliasedFill", "antiAliasedLinesUseTex", "curveTessellationTol", "circleTessellationMaxError"]

macro setField*(obj: typed, field: static string, val: untyped): untyped = 
  expectKind(obj, nnkSym)
  newTree(nnkAsgn, newTree(nnkDotExpr, obj, newIdentNode(field)), val)

proc igVec2(x, y: float32): ImVec2 = ImVec2(x: x, y: y)

proc igVec4(color: Color): ImVec4 = 
  ImVec4(x: color.r, y: color.g, z: color.b, w: color.a)

proc igVec4(x, y, z, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

proc toTArray(vec: ImVec4): TomlValueRef = 
  result = newTArray()
  result.add vec.x.newTFLoat()
  result.add vec.y.newTFLoat()
  result.add vec.z.newTFLoat()
  result.add vec.w.newTFLoat()

proc toTArray(vec: ImVec2): TomlValueRef = 
  result = newTArray()
  result.add vec.x.newTFLoat()
  result.add vec.y.newTFLoat()

proc colorToVec4(col: TomlValueRef): ImVec4 = 
  case col.kind
  of TomlKind.Array:
    assert col.len == 4, &"{col} has to have lenght 4"
    assert col[0].kind == TomlKind.Float, &"{col} has to be an array of floats"

    result = igVec4(col[0].getFloat(), col[1].getFloat(), col[2].getFloat(), col[3].getFloat())
  of TomlKind.String:
    result = col.getString().parseHtmlColor().igVec4()
  else:
    raise newException(ValueError, &"Got {col.kind} for {col} expected array or string")

proc newImGuiStyle*(): ImGuiStyle = 
  result.alpha = 1.0f # Global alpha applies to everything in Dear ImGui.
  result.disabledAlpha = 0.60f # Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha.
  result.windowPadding = igVec2(8, 8) # Padding within a window
  result.windowRounding = 0.0f # Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.
  result.windowBorderSize = 1.0f # Thickness of border around windows. Generally set to 0.0f or 1.0f. Other values not well tested.
  result.windowMinSize = igVec2(32, 32) # Minimum window size
  result.windowTitleAlign = igVec2(0.0f, 0.5f) # Alignment for title bar text
  result.windowMenuButtonPosition = ImGuiDir.Left # Position of the collapsing/docking button in the title bar (left/right). Defaults to ImGuiDir_Left.
  result.childRounding = 0.0f # Radius of child window corners rounding. Set to 0.0f to have rectangular child windows
  result.childBorderSize = 1.0f # Thickness of border around child windows. Generally set to 0.0f or 1.0f. Other values not well tested.
  result.popupRounding = 0.0f # Radius of popup window corners rounding. Set to 0.0f to have rectangular child windows
  result.popupBorderSize = 1.0f # Thickness of border around popup or tooltip windows. Generally set to 0.0f or 1.0f. Other values not well tested.
  result.framePadding = igVec2(4, 3) # Padding within a framed rectangle (used by most widgets)
  result.frameRounding = 0.0f # Radius of frame corners rounding. Set to 0.0f to have rectangular frames (used by most widgets).
  result.frameBorderSize = 0.0f # Thickness of border around frames. Generally set to 0.0f or 1.0f. Other values not well tested.
  result.itemSpacing = igVec2(8, 4) # Horizontal and vertical spacing between widgets/lines
  result.itemInnerSpacing = igVec2(4, 4) # Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label)
  result.cellPadding = igVec2(4,2) # Padding within a table cell
  result.touchExtraPadding = igVec2(0, 0) # Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
  result.indentSpacing = 21.0f # Horizontal spacing when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
  result.columnsMinSpacing = 6.0f # Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).
  result.scrollbarSize = 14.0f # Width of the vertical scrollbar, Height of the horizontal scrollbar
  result.scrollbarRounding = 9.0f # Radius of grab corners rounding for scrollbar
  result.grabMinSize = 10.0f # Minimum width/height of a grab box for slider/scrollbar
  result.grabRounding = 0.0f # Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
  result.logSliderDeadzone = 4.0f # The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero.
  result.tabRounding = 4.0f # Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.
  result.tabBorderSize = 0.0f # Thickness of border around tabs.
  result.tabMinWidthForCloseButton = 0.0f # Minimum width for close button to appears on an unselected tab when hovered. Set to 0.0f to always show when hovering, set to FLT_MAX to never show close button unless selected.
  result.colorButtonPosition = ImGuiDir.Right # Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.
  result.buttonTextAlign = igVec2(0.5f, 0.5f) # Alignment of button text when button is larger than text.
  result.selectableTextAlign = igVec2(0.0f, 0.0f) # Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.
  result.displayWindowPadding = igVec2(19, 19) # Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows.
  result.displaySafeAreaPadding = igVec2(3, 3) # If you cannot see the edge of your screen (e.g. on a TV) increase the safe area padding. Covers popups/tooltips as well regular windows.
  result.mouseCursorScale = 1.0f # Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.
  result.antiAliasedLines = true # Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU.
  result.antiAliasedLinesUseTex = true # Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering).
  result.antiAliasedFill = true # Enable anti-aliased filled shapes (rounded rectangles, circles, etc.).
  result.curveTessellationTol = 1.25f # Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
  result.circleTessellationMaxError = 0.30f # Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry.

  igStyleColorsDark(result.addr)

proc styleToToml*(style: ImGuiStyle, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: ImVec4): TomlValueRef = toTArray): TomlValueRef = 
  ## Convert `style` into `TomlValueRef`.  
  ## Properties in `ignoreProps` are ignored.  
  ## Colors in `ignoreColors` are ignored.  
  ## `colorProc` is used to convert colors from `ImVec4` to `TomlValueRef`.
  result = newTTable()
  for name, field in style.fieldPairs:
    if name notin ignoreProps:
      when field is float32:
        result[name] = field.newTFLoat()
      elif field is ImVec2:
        result[name] = field.toTArray()
      elif field is ImGuiDir:
        result[name] = newTString($field)
      elif field is bool:
        result[name] = newTBool(field)

  result["colors"] = newTTable()
  for col in ImGuiCol:
    if $col notin ignoreColors:
      result["colors"][$col] = style.colors[ord col].colorProc()

proc styleFromToml*(node: TomlValueRef, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4): ImGuiStyle = 
  ## Load ImGuiStyle from `node`.  
  ## Properties in `ignoreProps` are ignored.  
  ## Colors in `ignoreColors` are ignored.  
  ## `colorProc` is used to convert colors from `TomlValueRef` to `ImVec4`.
  assert node.kind == TomlKind.Table

  result = newImGuiStyle()

  for name, field in result.fieldPairs:
    if name != "colors" and name notin ignoreProps and name in node:
      case node[name].kind
      of TomlKind.Float, TomlKind.Int:
        when field is float32:
          if node[name].kind == TomlKind.Float:
            result.setField(name, node[name].getFloat())
          else:
            result.setField(name, float32 node[name].getInt())
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlKind.Array:
        when field is ImVec2:
          assert node[name].len == 2, name & "has to be of lenght 2"
          result.setField(name, igVec2(node[name][0].getFloat(), node[name][1].getFloat()))
        elif field is ImVec4:
          assert node[name].len == 4, name & "has to be of lenght 4"
          result.setField(name, igVec4(node[name][0].getFloat(), node[name][1].getFloat(), node[name][2].getFloat(), node[name][3].getFloat()))
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlKind.String:
        when field is ImGuiDir:
          result.setField(name, parseEnum[ImGuiDir](node[name].getString()))
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlKind.Bool:
        when field is bool:
          result.setField(name, node[name].getBool())
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      else:
        raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))

  if "colors" in node:
    for col in ImGuiCol:
      if $col notin ignoreColors and $col in node["colors"]:
        let colorNode = node["colors"][$col]
        result.colors[ord col] = colorNode.colorProc()

proc styleFromToml*(path: string, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4): ImGuiStyle = 
  ## Load `ImGuiStyle` from the toml file at `path`.
  styleFromToml(Toml.loadFile(path, TomlValueRef), ignoreProps, ignoreColors, colorProc)

proc setStyleFromToml*(node: TomlValueRef, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4) =
  let tomlStyle = node.styleFromToml(ignoreProps, ignoreColors, colorProc)
  let style = igGetStyle()
  for name, field in tomlStyle.fieldPairs:
    if name notin ignoreProps:
      style.setField(name, field)

proc setStyleFromToml*(path: string, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4) =
  setStyleFromToml(Toml.loadFile(path, TomlValueRef), ignoreProps, ignoreColors, colorProc)

