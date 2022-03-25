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
      parseEnum[ImGuiDir](node.getString())
    except ValueError:
      raise newException(ValueError, &"Invalid value \"{node.getString()}\" for ImGuiDir enum. Valid values are {getEnumValues[ImGuiDir]()}")
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

proc getStyle*(data: PObjectType): ImGuiStyle = 
  result.alpha = data["alpha"].toFloat().getFloat()
  result.windowPadding = data["windowPadding"].toFloat().getSeq().toImVec2()
  result.windowRounding = data["windowRounding"].toFloat().getFloat()
  result.windowBorderSize = data["windowBorderSize"].toFloat().getFloat()
  result.windowMinSize = data["windowMinSize"].toFloat().getSeq().toImVec2()
  result.windowTitleAlign = data["windowTitleAlign"].toFloat().getSeq().toImVec2()
  result.windowMenuButtonPosition = data["windowMenuButtonPosition"].toImGuiDir()
  result.childRounding = data["childRounding"].toFloat().getFloat()
  result.childBorderSize = data["childBorderSize"].toFloat().getFloat()
  result.popupRounding = data["popupRounding"].toFloat().getFloat()
  result.popupBorderSize = data["popupBorderSize"].toFloat().getFloat()
  result.framePadding = data["framePadding"].toFloat().getSeq().toImVec2()
  result.frameRounding = data["frameRounding"].toFloat().getFloat()
  result.frameBorderSize = data["frameBorderSize"].toFloat().getFloat()
  result.itemSpacing = data["itemSpacing"].toFloat().getSeq().toImVec2()
  result.itemInnerSpacing = data["itemInnerSpacing"].toFloat().getSeq().toImVec2() # FIXME
  result.cellPadding = data["cellPadding"].toFloat().getSeq().toImVec2()
  result.touchExtraPadding = data["touchExtraPadding"].toFloat().getSeq().toImVec2()
  result.indentSpacing = data["indentSpacing"].toFloat().getFloat()
  result.columnsMinSpacing = data["columnsMinSpacing"].toFloat().getFloat()
  result.scrollbarSize = data["scrollbarSize"].toFloat().getFloat()
  result.scrollbarRounding = data["scrollbarRounding"].toFloat().getFloat()
  result.grabMinSize = data["grabMinSize"].toFloat().getFloat()
  result.grabRounding = data["grabRounding"].toFloat().getFloat()
  result.logSliderDeadzone = data["logSliderDeadzone"].toFloat().getFloat()
  result.tabRounding = data["tabRounding"].toFloat().getFloat()
  result.tabBorderSize = data["tabBorderSize"].toFloat().getFloat()
  result.tabMinWidthForCloseButton = data["tabMinWidthForCloseButton"].toFloat().getFloat()
  result.colorButtonPosition = data["colorButtonPosition"].toImGuiDir()
  result.buttonTextAlign = data["buttonTextAlign"].toFloat().getSeq().toImVec2()
  result.selectableTextAlign = data["selectableTextAlign"].toFloat().getSeq().toImVec2()
  result.displayWindowPadding = data["displayWindowPadding"].toFloat().getSeq().toImVec2()
  result.displaySafeAreaPadding = data["displaySafeAreaPadding"].toFloat().getSeq().toImVec2()
  result.mouseCursorScale = data["mouseCursorScale"].toFloat().getFloat()
  result.antiAliasedLines = data["antiAliasedLines"].getBool()
  result.antiAliasedLinesUseTex = data["antiAliasedLinesUseTex"].getBool()
  result.antiAliasedFill = data["antiAliasedFill"].getBool()
  result.curveTessellationTol = data["curveTessellationTol"].toFloat().getFloat()
  # result.circleSegmentMaxError = data["circleSegmentMaxError"].toFloat().getFloat()
  result.colors = data["colors"].readColors()

proc getStyle*(data: PrefsNode): ImGuiStyle = 
  data.getObject().getStyle()

proc getStyle*(path: string): ImGuiStyle = 
  readPrefs(path).getStyle()

proc setStyle*(data: PObjectType) = 
  var style = igGetStyle()

  style.alpha = data["alpha"].toFloat().getFloat()
  style.windowPadding = data["windowPadding"].toFloat().getSeq().toImVec2()
  style.windowRounding = data["windowRounding"].toFloat().getFloat()
  style.windowBorderSize = data["windowBorderSize"].toFloat().getFloat()
  style.windowMinSize = data["windowMinSize"].toFloat().getSeq().toImVec2()
  style.windowTitleAlign = data["windowTitleAlign"].toFloat().getSeq().toImVec2()
  style.windowMenuButtonPosition = data["windowMenuButtonPosition"].toImGuiDir()
  style.childRounding = data["childRounding"].toFloat().getFloat()
  style.childBorderSize = data["childBorderSize"].toFloat().getFloat()
  style.popupRounding = data["popupRounding"].toFloat().getFloat()
  style.popupBorderSize = data["popupBorderSize"].toFloat().getFloat()
  style.framePadding = data["framePadding"].toFloat().getSeq().toImVec2()
  style.frameRounding = data["frameRounding"].toFloat().getFloat()
  style.frameBorderSize = data["frameBorderSize"].toFloat().getFloat()
  style.itemSpacing = data["itemSpacing"].toFloat().getSeq().toImVec2()
  style.itemInnerSpacing = data["itemInnerSpacing"].toFloat().getSeq().toImVec2() # FIXME
  style.cellPadding = data["cellPadding"].toFloat().getSeq().toImVec2()
  style.touchExtraPadding = data["touchExtraPadding"].toFloat().getSeq().toImVec2()
  style.indentSpacing = data["indentSpacing"].toFloat().getFloat()
  style.columnsMinSpacing = data["columnsMinSpacing"].toFloat().getFloat()
  style.scrollbarSize = data["scrollbarSize"].toFloat().getFloat()
  style.scrollbarRounding = data["scrollbarRounding"].toFloat().getFloat()
  style.grabMinSize = data["grabMinSize"].toFloat().getFloat()
  style.grabRounding = data["grabRounding"].toFloat().getFloat()
  style.logSliderDeadzone = data["logSliderDeadzone"].toFloat().getFloat()
  style.tabRounding = data["tabRounding"].toFloat().getFloat()
  style.tabBorderSize = data["tabBorderSize"].toFloat().getFloat()
  style.tabMinWidthForCloseButton = data["tabMinWidthForCloseButton"].toFloat().getFloat()
  style.colorButtonPosition = data["colorButtonPosition"].toImGuiDir()
  style.buttonTextAlign = data["buttonTextAlign"].toFloat().getSeq().toImVec2()
  style.selectableTextAlign = data["selectableTextAlign"].toFloat().getSeq().toImVec2()
  style.displayWindowPadding = data["displayWindowPadding"].toFloat().getSeq().toImVec2()
  style.displaySafeAreaPadding = data["displaySafeAreaPadding"].toFloat().getSeq().toImVec2()
  style.mouseCursorScale = data["mouseCursorScale"].toFloat().getFloat()
  style.antiAliasedLines = data["antiAliasedLines"].getBool()
  style.antiAliasedLinesUseTex = data["antiAliasedLinesUseTex"].getBool()
  style.antiAliasedFill = data["antiAliasedFill"].getBool()
  style.curveTessellationTol = data["curveTessellationTol"].toFloat().getFloat()
  # style.circleSegmentMaxError = data["circleSegmentMaxError"].toFloat().getFloat()
  style.colors = data["colors"].readColors()

proc setStyle*(data: PrefsNode): ImGuiStyle = 
  data.getObject().setStyle()

proc setStyle*(path: string) = 
  readPrefs(path).setStyle()
