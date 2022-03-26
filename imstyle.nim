import std/[strutils, strformat]

import chroma
import niprefs
import nimgl/imgui

export imgui

proc getEnumValues[T: enum](): seq[string] = 
  for i in T:
    result.add($i)

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

proc toImVec2(s: PSeqType): ImVec2 = 
  ImVec2(x: s[0].getFloat(), y: s[1].getFloat())

proc toImVec4(color: Color): ImVec4 = 
  ImVec4(x: color.r, y: color.g, z: color.b, w: color.a)

proc toImGuiDir(node: PrefsNode): ImGuiDir = 
  case node.kind:
  of PInt:
    ImGuiDir(node.getInt())
  of PString:
    try:
      parseEnum[ImGuiDir](node.getString().capitalizeAscii())
    except ValueError:
      raise newException(ValueError, &"Invalid enum value \"{node.getString()}\" for ImGuiDir enum. Valid values are {getEnumValues[ImGuiDir]()}")
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
      result[ord val] = color.getString().parseHtmlColor().toImVec4()
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
  if "alpha" in data: result.alpha = data["alpha"].toFloat().getFloat()
  if "windowPadding" in data: result.windowPadding = data["windowPadding"].toFloat().getSeq().toImVec2()
  if "windowRounding" in data: result.windowRounding = data["windowRounding"].toFloat().getFloat()
  if "windowBorderSize" in data: result.windowBorderSize = data["windowBorderSize"].toFloat().getFloat()
  if "windowMinSize" in data: result.windowMinSize = data["windowMinSize"].toFloat().getSeq().toImVec2()
  if "windowTitleAlign" in data: result.windowTitleAlign = data["windowTitleAlign"].toFloat().getSeq().toImVec2()
  if "windowMenuButtonPosition" in data: result.windowMenuButtonPosition = data["windowMenuButtonPosition"].toImGuiDir()
  if "childRounding" in data: result.childRounding = data["childRounding"].toFloat().getFloat()
  if "childBorderSize" in data: result.childBorderSize = data["childBorderSize"].toFloat().getFloat()
  if "popupRounding" in data: result.popupRounding = data["popupRounding"].toFloat().getFloat()
  if "popupBorderSize" in data: result.popupBorderSize = data["popupBorderSize"].toFloat().getFloat()
  if "framePadding" in data: result.framePadding = data["framePadding"].toFloat().getSeq().toImVec2()
  if "frameRounding" in data: result.frameRounding = data["frameRounding"].toFloat().getFloat()
  if "frameBorderSize" in data: result.frameBorderSize = data["frameBorderSize"].toFloat().getFloat()
  if "itemSpacing" in data: result.itemSpacing = data["itemSpacing"].toFloat().getSeq().toImVec2()
  if "itemInnerSpacing" in data: result.itemInnerSpacing = data["itemInnerSpacing"].toFloat().getSeq().toImVec2()
  if "cellPadding" in data: result.cellPadding = data["cellPadding"].toFloat().getSeq().toImVec2()
  if "touchExtraPadding" in data: result.touchExtraPadding = data["touchExtraPadding"].toFloat().getSeq().toImVec2()
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
  if "buttonTextAlign" in data: result.buttonTextAlign = data["buttonTextAlign"].toFloat().getSeq().toImVec2()
  if "selectableTextAlign" in data: result.selectableTextAlign = data["selectableTextAlign"].toFloat().getSeq().toImVec2()
  if "displayWindowPadding" in data: result.displayWindowPadding = data["displayWindowPadding"].toFloat().getSeq().toImVec2()
  if "displaySafeAreaPadding" in data: result.displaySafeAreaPadding = data["displaySafeAreaPadding"].toFloat().getSeq().toImVec2()
  if "mouseCursorScale" in data: result.mouseCursorScale = data["mouseCursorScale"].toFloat().getFloat()
  if "antiAliasedLines" in data: result.antiAliasedLines = data["antiAliasedLines"].getBool()
  if "antiAliasedLinesUseTex" in data: result.antiAliasedLinesUseTex = data["antiAliasedLinesUseTex"].getBool()
  if "antiAliasedFill" in data: result.antiAliasedFill = data["antiAliasedFill"].getBool()
  if "curveTessellationTol" in data: result.curveTessellationTol = data["curveTessellationTol"].toFloat().getFloat()
  # if "circleSegmentMaxError" in data: result.circleSegmentMaxError = data["circleSegmentMaxError"].toFloat().getFloat()
  if "colors" in data: result.colors = data["colors"].readColors()

proc getIgStyle*(data: PrefsNode): ImGuiStyle = 
  data.getObject().getIgStyle()

proc getIgStyle*(path: string): ImGuiStyle = 
  readPrefs(path).getIgStyle()

proc setIgStyle*(data: PObjectType) = 
  var style = igGetStyle()

  if "alpha" in data: style.alpha = data["alpha"].toFloat().getFloat()
  if "windowPadding" in data: style.windowPadding = data["windowPadding"].toFloat().getSeq().toImVec2()
  if "windowRounding" in data: style.windowRounding = data["windowRounding"].toFloat().getFloat()
  if "windowBorderSize" in data: style.windowBorderSize = data["windowBorderSize"].toFloat().getFloat()
  if "windowMinSize" in data: style.windowMinSize = data["windowMinSize"].toFloat().getSeq().toImVec2()
  if "windowTitleAlign" in data: style.windowTitleAlign = data["windowTitleAlign"].toFloat().getSeq().toImVec2()
  if "windowMenuButtonPosition" in data: style.windowMenuButtonPosition = data["windowMenuButtonPosition"].toImGuiDir()
  if "childRounding" in data: style.childRounding = data["childRounding"].toFloat().getFloat()
  if "childBorderSize" in data: style.childBorderSize = data["childBorderSize"].toFloat().getFloat()
  if "popupRounding" in data: style.popupRounding = data["popupRounding"].toFloat().getFloat()
  if "popupBorderSize" in data: style.popupBorderSize = data["popupBorderSize"].toFloat().getFloat()
  if "framePadding" in data: style.framePadding = data["framePadding"].toFloat().getSeq().toImVec2()
  if "frameRounding" in data: style.frameRounding = data["frameRounding"].toFloat().getFloat()
  if "frameBorderSize" in data: style.frameBorderSize = data["frameBorderSize"].toFloat().getFloat()
  if "itemSpacing" in data: style.itemSpacing = data["itemSpacing"].toFloat().getSeq().toImVec2()
  if "itemInnerSpacing" in data: style.itemInnerSpacing = data["itemInnerSpacing"].toFloat().getSeq().toImVec2()
  if "cellPadding" in data: style.cellPadding = data["cellPadding"].toFloat().getSeq().toImVec2()
  if "touchExtraPadding" in data: style.touchExtraPadding = data["touchExtraPadding"].toFloat().getSeq().toImVec2()
  if "indentSpacing" in data: style.indentSpacing = data["indentSpacing"].toFloat().getFloat()
  if "columnsMinSpacing" in data: style.columnsMinSpacing = data["columnsMinSpacing"].toFloat().getFloat()
  if "scrollbarSize" in data: style.scrollbarSize = data["scrollbarSize"].toFloat().getFloat()
  if "scrollbarRounding" in data: style.scrollbarRounding = data["scrollbarRounding"].toFloat().getFloat()
  if "grabMinSize" in data: style.grabMinSize = data["grabMinSize"].toFloat().getFloat()
  if "grabRounding" in data: style.grabRounding = data["grabRounding"].toFloat().getFloat()
  if "logSliderDeadzone" in data: style.logSliderDeadzone = data["logSliderDeadzone"].toFloat().getFloat()
  if "tabRounding" in data: style.tabRounding = data["tabRounding"].toFloat().getFloat()
  if "tabBorderSize" in data: style.tabBorderSize = data["tabBorderSize"].toFloat().getFloat()
  if "tabMinWidthForCloseButton" in data: style.tabMinWidthForCloseButton = data["tabMinWidthForCloseButton"].toFloat().getFloat()
  if "colorButtonPosition" in data: style.colorButtonPosition = data["colorButtonPosition"].toImGuiDir()
  if "buttonTextAlign" in data: style.buttonTextAlign = data["buttonTextAlign"].toFloat().getSeq().toImVec2()
  if "selectableTextAlign" in data: style.selectableTextAlign = data["selectableTextAlign"].toFloat().getSeq().toImVec2()
  if "displayWindowPadding" in data: style.displayWindowPadding = data["displayWindowPadding"].toFloat().getSeq().toImVec2()
  if "displaySafeAreaPadding" in data: style.displaySafeAreaPadding = data["displaySafeAreaPadding"].toFloat().getSeq().toImVec2()
  if "mouseCursorScale" in data: style.mouseCursorScale = data["mouseCursorScale"].toFloat().getFloat()
  if "antiAliasedLines" in data: style.antiAliasedLines = data["antiAliasedLines"].getBool()
  if "antiAliasedLinesUseTex" in data: style.antiAliasedLinesUseTex = data["antiAliasedLinesUseTex"].getBool()
  if "antiAliasedFill" in data: style.antiAliasedFill = data["antiAliasedFill"].getBool()
  if "curveTessellationTol" in data: style.curveTessellationTol = data["curveTessellationTol"].toFloat().getFloat()
  # if "circleSegmentMaxError" in data: style.circleSegmentMaxError = data["circleSegmentMaxError"].toFloat().getFloat()
  if "colors" in data: style.colors = data["colors"].readColors()

proc setIgStyle*(data: PrefsNode): ImGuiStyle = 
  data.getObject().setIgStyle()

proc setIgStyle*(path: string) = 
  readPrefs(path).setIgStyle()
