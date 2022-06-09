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

import std/[strformat, strutils]
import chroma
import niprefs
import parsetoml
import nimgl/imgui

export parsetoml

proc toFloat(node: PrefsNode): PrefsNode = 
  case node.kind
  of PInt:
    result = newPFloat(float32 node.getInt())
  of PFloat:
    result = node
  of PSeq:
    result = newPSeq()
    for i in node.getSeq():
      result.seqV.add(i.toFloat())
  else:
    raise newException(ValueError, &"Invalid value {node} of {node.kind} kind")

proc igVec2(s: PSeqType): ImVec2 = 
  ImVec2(x: s[0].getFloat(), y: s[1].getFloat())

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
  of TomlValueKind.Array:
    assert col.len == 4, &"{col} has to have lenght 4"
    assert col[0].kind == TomlValueKind.Float, &"{col} has to be an array of floats"

    result = igVec4(col[0].getFloat(), col[1].getFloat(), col[2].getFloat(), col[3].getFloat())
  of TomlValueKind.String:
    result = col.getStr().parseHtmlColor().igVec4()
  else:
    raise newException(ValueError, &"Got {col.kind} for {col} expected array or string")

proc toImGuiDir(node: PrefsNode): ImGuiDir = 
  case node.kind:
  of PInt:
    ImGuiDir(node.getInt())
  of PString:
    try:
      parseEnum[ImGuiDir](node.getString().capitalizeAscii())
    except ValueError:
      raise newException(ValueError, &"Invalid enum value \"{node.getString()}\" for ImGuiDir enum. Valid values are {{None, Left, Rigth}}")
  else:
    raise newException(ValueError, &"Invalid kind {node.kind} for ImGuiDir enum. Valid values are either PInt or PString")

proc readColors(data: PrefsNode): array[53, ImVec4] = 
  for name, color in data.getObject():
    var val: ImGuiCol
    try:
      val = parseEnum[ImGuiCol](name)
    except ValueError:
      continue

    case color.kind:
    of PString:
      result[ord val] = color.getString().parseHtmlColor().igVec4()
    of PSeq:
      result[ord val] = ImVec4(
        x: color[0].getFloat(), 
        y: color[1].getFloat(), 
        z: color[2].getFloat(), 
        w: color[3].getFloat()
      )
    else:
      raise newException(ValueError, &"Invalid kind {color.kind} for a color. Valid values are either PString or PSeq")

proc getIgStyle*(data: PObjectType): ImGuiStyle = 
  ## Return the style in `data`.
  if "alpha" in data: result.alpha = data["alpha"].toFloat().getFloat()
  if "disabledAlpha" in data: result.disabledAlpha = data["disabledAlpha"].toFloat().getFloat()
  if "windowPadding" in data: result.windowPadding = data["windowPadding"].toFloat().getSeq().igVec2()
  if "windowRounding" in data: result.windowRounding = data["windowRounding"].toFloat().getFloat()
  if "windowBorderSize" in data: result.windowBorderSize = data["windowBorderSize"].toFloat().getFloat()
  if "windowMinSize" in data: result.windowMinSize = data["windowMinSize"].toFloat().getSeq().igVec2()
  if "windowTitleAlign" in data: result.windowTitleAlign = data["windowTitleAlign"].toFloat().getSeq().igVec2()
  if "windowMenuButtonPosition" in data: result.windowMenuButtonPosition = data["windowMenuButtonPosition"].toImGuiDir()
  if "childRounding" in data: result.childRounding = data["childRounding"].toFloat().getFloat()
  if "childBorderSize" in data: result.childBorderSize = data["childBorderSize"].toFloat().getFloat()
  if "popupRounding" in data: result.popupRounding = data["popupRounding"].toFloat().getFloat()
  if "popupBorderSize" in data: result.popupBorderSize = data["popupBorderSize"].toFloat().getFloat()
  if "framePadding" in data: result.framePadding = data["framePadding"].toFloat().getSeq().igVec2()
  if "frameRounding" in data: result.frameRounding = data["frameRounding"].toFloat().getFloat()
  if "frameBorderSize" in data: result.frameBorderSize = data["frameBorderSize"].toFloat().getFloat()
  if "itemSpacing" in data: result.itemSpacing = data["itemSpacing"].toFloat().getSeq().igVec2()
  if "itemInnerSpacing" in data: result.itemInnerSpacing = data["itemInnerSpacing"].toFloat().getSeq().igVec2()
  if "cellPadding" in data: result.cellPadding = data["cellPadding"].toFloat().getSeq().igVec2()
  if "touchExtraPadding" in data: result.touchExtraPadding = data["touchExtraPadding"].toFloat().getSeq().igVec2()
  if "indentSpacing" in data: result.indentSpacing = data["indentSpacing"].toFloat().getFloat()
  if "columnsMinSpacing" in data: result.columnsMinSpacing = data["columnsMinSpacing"].toFloat().getFloat()
  if "scrollbarSize" in data: result.scrollbarSize = data["scrollbarSize"].toFloat().getFloat()
  if "scrollbarRounding" in data: result.scrollbarRounding = data["scrollbarRounding"].toFloat().getFloat()
  if "grabMinSize" in data: result.grabMinSize = data["grabMinSize"].toFloat().getFloat()
  if "grabRounding" in data: result.grabRounding = data["grabRounding"].toFloat().getFloat()
  if "logSliderDeadzone" in data: result.logSliderDeadzone = data["logSliderDeadzone"].toFloat().getFloat()
  if "tabRounding" in data: result.tabRounding = data["tabRounding"].toFloat().getFloat()
  if "tabBorderSize" in data: result.tabBorderSize = data["tabBorderSize"].toFloat().getFloat()
  if "tabMinWidthForCloseButton" in data: result.tabMinWidthForCloseButton = data["tabMinWidthForCloseButton"].toFloat().getFloat()
  if "colorButtonPosition" in data: result.colorButtonPosition = data["colorButtonPosition"].toImGuiDir()
  if "buttonTextAlign" in data: result.buttonTextAlign = data["buttonTextAlign"].toFloat().getSeq().igVec2()
  if "selectableTextAlign" in data: result.selectableTextAlign = data["selectableTextAlign"].toFloat().getSeq().igVec2()
  if "displayWindowPadding" in data: result.displayWindowPadding = data["displayWindowPadding"].toFloat().getSeq().igVec2()
  if "displaySafeAreaPadding" in data: result.displaySafeAreaPadding = data["displaySafeAreaPadding"].toFloat().getSeq().igVec2()
  if "mouseCursorScale" in data: result.mouseCursorScale = data["mouseCursorScale"].toFloat().getFloat()
  if "antiAliasedLines" in data: result.antiAliasedLines = data["antiAliasedLines"].getBool()
  if "antiAliasedLinesUseTex" in data: result.antiAliasedLinesUseTex = data["antiAliasedLinesUseTex"].getBool()
  if "antiAliasedFill" in data: result.antiAliasedFill = data["antiAliasedFill"].getBool()
  if "curveTessellationTol" in data: result.curveTessellationTol = data["curveTessellationTol"].toFloat().getFloat()
  if "circleTessellationMaxError" in data: result.circleTessellationMaxError = data["circleTessellationMaxError"].toFloat().getFloat()
  if "colors" in data: result.colors = data["colors"].readColors()

proc toToml*(style: ImGuiStyle, ignoreProps: openArray[string] = [], ignoreColors: openArray[string] = [], colorProc: proc(col: ImVec4): TomlValueRef = toTArray): TomlValueRef = 
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

proc styleFromToml*(node: TomlValueRef, ignoreProps: openArray[string] = [], ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4): ImGuiStyle = 
  ## Load ImGuiStyle from `node`.  
  ## Properties in `ignoreProps` are ignored.  
  ## Colors in `ignoreColors` are ignored.  
  ## `colorProc` is used to convert colors from `TomlValueRef` to `ImVec4`.

  for name, field in result.fieldPairs:
    if name != "colors" and name notin ignoreProps and name in node:
      case node[name].kind
      of TomlValueKind.Float, TomlValueKind.Int:
        when field is float32:
          if node[name].kind == TomlValueKind.Float:
            field = node[name].getFloat()
          else:
            field = float32 node[name].getInt()
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlValueKind.Array:
        when field is ImVec2:
          assert node[name].len == 2, name & "has to be of lenght 2"
          field = igVec2(node[name][0].getFloat(), node[name][1].getFloat())
        elif field is ImVec4:
          assert node[name].len == 4, name & "has to be of lenght 4"
          field = igVec4(node[name][0].getFloat(), node[name][1].getFloat(), node[name][2].getFloat(), node[name][3].getFloat())
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      of TomlValueKind.String:
        when field is ImGuiDir:
          field = parseEnum[ImGuiDir](node[name].getStr())
        else:
          raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))
      else:
        raise newException(ValueError, "Got " & $node[name].kind & " for " & name & " expected " & $typeof(field))

  if "colors" in node:
    for col in ImGuiCol:
      if $col notin ignoreColors and $col in node["colors"]:
        let colorNode = node["colors"][$col]
        result.colors[ord col] = colorNode.colorProc()

proc styleFromToml*(path: string, ignoreProps: openArray[string] = [], ignoreColors: openArray[string] = [], colorProc: proc(col: TomlValueRef): ImVec4 = colorToVec4): ImGuiStyle = 
  ## Load `ImGuiStyle` from the toml file at `path`.
  styleFromToml(parsetoml.parseFile(path), ignoreProps, ignoreColors, colorProc)

proc niprefsToToml*(path: string, ignoreProps: openArray[string] = [], ignoreColors: openArray[string] = []): TomlValueRef = 
  ## Reads a niprefs file, get its style using `getIgStyle` and conver it to `TomlValueRef` using `toToml`.
  readPrefs(path).getIgStyle().toToml(ignoreProps, ignoreColors)
