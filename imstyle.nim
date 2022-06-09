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

const defaultIgnoreProps = ["touchExtraPadding", "logSliderDeadzone", "displayWindowPadding", "displaySafeAreaPadding", "mouseCursorScale", "curveTessellationTol", "circleTessellationMaxError"]

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

  result["colors"] = newTTable()
  for col in ImGuiCol:
    if $col notin ignoreColors:
      result["colors"][$col] = style.colors[ord col].colorProc()

proc styleFromToml*(node: TomlValueRef, ignoreProps: openArray[string] = defaultIgnoreProps, ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4): ImGuiStyle = 
  ## Load ImGuiStyle from `node`.  
  ## Properties in `ignoreProps` are ignored.  
  ## Colors in `ignoreColors` are ignored.  
  ## `colorProc` is used to convert colors from `TomlValueRef` to `ImVec4`.

  for name, field in result.fieldPairs:
    if name != "colors" and name notin ignoreProps and name in node:
      case node[name].kind
      of TomlKind.Float, TomlKind.Int:
        when field is float32:
          if node[name].kind == TomlKind.Float:
            field = node[name].getFloat()
          else:
            field = float32 node[name].getInt()
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlKind.Array:
        when field is ImVec2:
          assert node[name].len == 2, name & "has to be of lenght 2"
          field = igVec2(node[name][0].getFloat(), node[name][1].getFloat())
        elif field is ImVec4:
          assert node[name].len == 4, name & "has to be of lenght 4"
          field = igVec4(node[name][0].getFloat(), node[name][1].getFloat(), node[name][2].getFloat(), node[name][3].getFloat())
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlKind.String:
        when field is ImGuiDir:
          field = parseEnum[ImGuiDir](node[name].getString())
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
