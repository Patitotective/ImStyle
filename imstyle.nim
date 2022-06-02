## ImStyle is a library that helps you to manage your Dear ImGui application's style.  
## Load the style from a [niprefs](https:#github.com/Patitotective/niprefs) file rather than hard-coding it into your app.  
## Using ImStyle also allows you to change your app's style without compiling it again (since the style is read from a file).
## 
## Without ImStyle you need to set the style from code:
## ```nim
## import nimgl/imgui
## ...
## var style = igGetStyle()
## style.alpha = 1f
## style.windowPadding = ImVec2(x: 4f, y: 4f)
## style.windowMenuButtonPosition = ImGuiDir.Left
## style.colors[ord Text] = ImVec4(x: 0f, y: 0f, z: 0f, w: 1f) # RGBA
## ...
## ```
## Using ImStyle you need to create a `niprefs` file (e.i.: `style.niprefs`), that will look like:
## ```nim
## # ImStyle
## alpha = 1 # -> 1f
## windowPadding = [4, 4] # -> ImVec2(x: 4f, y: 4f) 
## windowMenuButtonPosition = "Left" # Or 0
## colors=>
##  Text = "#000000" # or "rgb(0, 0, 0)" or [0, 0, 0]
## ```
## And load it in your code:
## ```nim
## import imstyle
## ...
## setIgStyle("style.niprefs")
## ...
## ```

import std/[strformat, strutils, macros]

import chroma
import niprefs
import nimgl/imgui

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

proc newPNode*(vec: ImVec4): PrefsNode = 
  ## Helper proc to conver an ImVec4 to a PrefsNode sequence.
  toPrefs([vec.x, vec.y, vec.z, vec.w])

proc newPNode*(vec: ImVec2): PrefsNode = 
  ## Helper proc to conver an ImVec2 to a PrefsNode sequence.
  toPrefs([vec.x, vec.y])

proc newPNode*(node: PrefsNode): PrefsNode = 
  ## Helper to trick the toPrefs macro to accept PrefsNode objects.
  node

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
  ## Return an ImGuiStyle object from `data`.

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
  ## Change the current style from `data`.
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

proc toString*(style: ImGuiStyle, colorProc: proc(col: ImVec4): PrefsNode = proc(col: ImVec4): PrefsNode = col.newPNode()): string = 
  ## Convert `style` to a niprefs representation.  
  ## Use `colorProc` to change the color format, for example to write hex using chroma: `proc(col: ImVec4): PrefsNode = color(col.x, col.y, col.z, col.w).toHex().newPNode()`.
  toPrefs({
    alpha: style.alpha, 
    windowPadding: style.windowPadding, 
    windowRounding: style.windowRounding, 
    windowBorderSize: style.windowBorderSize, 
    windowMinSize: style.windowMinSize, 
    windowTitleAlign: style.windowTitleAlign, 
    windowMenuButtonPosition: $style.windowMenuButtonPosition, 
    childRounding: style.childRounding, 
    childBorderSize: style.childBorderSize, 
    popupRounding: style.popupRounding, 
    popupBorderSize: style.popupBorderSize, 
    framePadding: style.framePadding, 
    frameRounding: style.frameRounding, 
    frameBorderSize: style.frameBorderSize, 
    itemSpacing: style.itemSpacing, 
    itemInnerSpacing: style.itemInnerSpacing, 
    cellPadding: style.cellPadding, 
    touchExtraPadding: style.touchExtraPadding, 
    indentSpacing: style.indentSpacing, 
    columnsMinSpacing: style.columnsMinSpacing, 
    scrollbarSize: style.scrollbarSize, 
    scrollbarRounding: style.scrollbarRounding, 
    grabMinSize: style.grabMinSize, 
    grabRounding: style.grabRounding, 
    logSliderDeadzone: style.logSliderDeadzone, 
    tabRounding: style.tabRounding, 
    tabBorderSize: style.tabBorderSize, 
    tabMinWidthForCloseButton: style.tabMinWidthForCloseButton, 
    colorButtonPosition: $style.colorButtonPosition, 
    buttonTextAlign: style.buttonTextAlign, 
    selectableTextAlign: style.selectableTextAlign, 
    displayWindowPadding: style.displayWindowPadding, 
    displaySafeAreaPadding: style.displaySafeAreaPadding, 
    mouseCursorScale: style.mouseCursorScale, 
    antiAliasedLines: style.antiAliasedLines, 
    antiAliasedLinesUseTex: style.antiAliasedLinesUseTex, 
    antiAliasedFill: style.antiAliasedFill, 
    curveTessellationTol: style.curveTessellationTol, 
    # circleSegmentMaxError: style.circleSegmentMaxError, 
    colors: {
      Text: style.colors[ord ImGuiCol.Text].colorProc(), 
      TextDisabled: style.colors[ord ImGuiCol.TextDisabled].colorProc(), 
      WindowBg: style.colors[ord ImGuiCol.WindowBg].colorProc(), 
      ChildBg: style.colors[ord ImGuiCol.ChildBg].colorProc(), 
      PopupBg: style.colors[ord ImGuiCol.PopupBg].colorProc(),
      Border: style.colors[ord ImGuiCol.Border].colorProc(), 
      BorderShadow: style.colors[ord ImGuiCol.BorderShadow].colorProc(), 
      FrameBg: style.colors[ord ImGuiCol.FrameBg].colorProc(), 
      FrameBgHovered: style.colors[ord ImGuiCol.FrameBgHovered].colorProc(),
      FrameBgActive: style.colors[ord ImGuiCol.FrameBgActive].colorProc(), 
      TitleBg: style.colors[ord ImGuiCol.TitleBg].colorProc(), 
      TitleBgActive: style.colors[ord ImGuiCol.TitleBgActive].colorProc(), 
      TitleBgCollapsed: style.colors[ord ImGuiCol.TitleBgCollapsed].colorProc(),
      MenuBarBg: style.colors[ord ImGuiCol.MenuBarBg].colorProc(), 
      ScrollbarBg: style.colors[ord ImGuiCol.ScrollbarBg].colorProc(), 
      ScrollbarGrab: style.colors[ord ImGuiCol.ScrollbarGrab].colorProc(),
      ScrollbarGrabHovered: style.colors[ord ImGuiCol.ScrollbarGrabHovered].colorProc(), 
      ScrollbarGrabActive: style.colors[ord ImGuiCol.ScrollbarGrabActive].colorProc(), 
      CheckMark: style.colors[ord ImGuiCol.CheckMark].colorProc(),
      SliderGrab: style.colors[ord ImGuiCol.SliderGrab].colorProc(), 
      SliderGrabActive: style.colors[ord ImGuiCol.SliderGrabActive].colorProc(), 
      Button: style.colors[ord ImGuiCol.Button].colorProc(), 
      ButtonHovered: style.colors[ord ImGuiCol.ButtonHovered].colorProc(),
      ButtonActive: style.colors[ord ImGuiCol.ButtonActive].colorProc(), 
      Header: style.colors[ord ImGuiCol.Header].colorProc(), 
      HeaderHovered: style.colors[ord ImGuiCol.HeaderHovered].colorProc(), 
      HeaderActive: style.colors[ord ImGuiCol.HeaderActive].colorProc(),
      Separator: style.colors[ord ImGuiCol.Separator].colorProc(), 
      SeparatorHovered: style.colors[ord ImGuiCol.SeparatorHovered].colorProc(), 
      SeparatorActive: style.colors[ord ImGuiCol.SeparatorActive].colorProc(), 
      ResizeGrip: style.colors[ord ImGuiCol.ResizeGrip].colorProc(),
      ResizeGripHovered: style.colors[ord ImGuiCol.ResizeGripHovered].colorProc(), 
      ResizeGripActive: style.colors[ord ImGuiCol.ResizeGripActive].colorProc(), 
      Tab: style.colors[ord ImGuiCol.Tab].colorProc(), 
      TabHovered: style.colors[ord ImGuiCol.TabHovered].colorProc(),
      TabActive: style.colors[ord ImGuiCol.TabActive].colorProc(), 
      TabUnfocused: style.colors[ord ImGuiCol.TabUnfocused].colorProc(), 
      TabUnfocusedActive: style.colors[ord ImGuiCol.TabUnfocusedActive].colorProc(), 
      PlotLines: style.colors[ord ImGuiCol.PlotLines].colorProc(),
      PlotLinesHovered: style.colors[ord ImGuiCol.PlotLinesHovered].colorProc(), 
      PlotHistogram: style.colors[ord ImGuiCol.PlotHistogram].colorProc(), 
      PlotHistogramHovered: style.colors[ord ImGuiCol.PlotHistogramHovered].colorProc(),
      TableHeaderBg: style.colors[ord ImGuiCol.TableHeaderBg].colorProc(), 
      TableBorderStrong: style.colors[ord ImGuiCol.TableBorderStrong].colorProc(), 
      TableBorderLight: style.colors[ord ImGuiCol.TableBorderLight].colorProc(),
      TableRowBg: style.colors[ord ImGuiCol.TableRowBg].colorProc(), 
      TableRowBgAlt: style.colors[ord ImGuiCol.TableRowBgAlt].colorProc(), 
      TextSelectedBg: style.colors[ord ImGuiCol.TextSelectedBg].colorProc(), 
      DragDropTarget: style.colors[ord ImGuiCol.DragDropTarget].colorProc(),
      NavHighlight: style.colors[ord ImGuiCol.NavHighlight].colorProc(), 
      NavWindowingHighlight: style.colors[ord ImGuiCol.NavWindowingHighlight].colorProc(), 
      NavWindowingDimBg: style.colors[ord ImGuiCol.NavWindowingDimBg].colorProc(),
      ModalWindowDimBg: style.colors[ord ImGuiCol.ModalWindowDimBg].colorProc()
    } 
  }).toString()

proc writeTo*(style: ImGuiStyle, path: string, colorProc: proc(col: ImVec4): PrefsNode = proc(col: ImVec4): PrefsNode = col.newPNode()) = 
  ## Write `style.toString()` to `path`.
  writeFile(path, style.toString(colorProc))

proc igHelpMarker(text: string, sameLineBefore = true) = 
  if sameLineBefore: igSameLine()

  igTextDisabled("(?)")
  if igIsItemHovered():
    igBeginTooltip()
    igPushTextWrapPos(igGetFontSize() * 35.0)
    igTextUnformatted(text)
    igPopTextWrapPos()
    igEndTooltip()

template drawVec2StyleVar(styleVar: untyped, minVal: float32 = 0, maxVal: float32 = 12, format = "%.1f") = 
  var styleVar = [style.styleVar.x, style.styleVar.y]
  igText(cstring (astToStr(styleVar) & ": ").capitalizeAscii().alignLeft(alignCount)); igSameLine()
  if igSliderFloat2(cstring "##" & astToStr(styleVar), styleVar, minVal, maxVal, format):
    style.styleVar = ImVec2(x: styleVar[0], y: styleVar[1])

template drawFloatStyleVar(styleVar: untyped, minVal: float32 = 0, maxVal: float32 = 12, format = "%.1f") = 
  igText(cstring (astToStr(styleVar) & ": ").capitalizeAscii().alignLeft(alignCount)); igSameLine()
  igSliderFloat(cstring "##" & astToStr(styleVar), style.styleVar.addr, minVal, maxVal, format)

template drawComboStyleVar[T: enum](styleVar: untyped, enumElems: openArray[T]) = 
  let currentItem = style.styleVar.int32
  igText(cstring (astToStr(styleVar) & ": ").capitalizeAscii().alignLeft(alignCount)); igSameLine()
  if igBeginCombo(cstring "##" & astToStr(styleVar), cstring $T(currentItem)):
    for elem in enumElems:
      if igSelectable(cstring $elem, currentItem == elem.int32):  
        style.styleVar = elem

    igEndCombo()

template drawBoolStyleVar(styleVar: untyped) = 
  igText(cstring (astToStr(styleVar) & ": ").capitalizeAscii().alignLeft(alignCount)); igSameLine()
  igCheckbox(cstring "##" & astToStr(styleVar), style.styleVar.addr)

proc drawImStyleEditor*(refStyle: ptr ImGuiStyle = nil) = 
    let style = if refStyle.isNil: igGetStyle() else: refStyle
    const
      alignCount = 28
      properties = [
        proc() = drawFloatStyleVar(alpha, 0.1, 1, format = "%.2f"); igHelpMarker("Global alpha applies to everything in Dear ImGui."), 
        proc() = drawVec2StyleVar(windowPadding); igHelpMarker("Padding within a window."), 
        proc() = drawVec2StyleVar(framePadding); igHelpMarker("Padding within a framed rectangle (used by most widgets)."), 
        proc() = drawVec2StyleVar(cellPadding); igHelpMarker("Padding within a table cell"), 
        proc() = drawVec2StyleVar(touchExtraPadding); igHelpMarker("Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!"), 
        proc() = drawVec2StyleVar(displayWindowPadding); igHelpMarker("Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows."), 
        proc() = drawVec2StyleVar(displaySafeAreaPadding); igHelpMarker("If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!"), 
        proc() = drawVec2StyleVar(itemSpacing); igHelpMarker("Horizontal and vertical spacing between widgets/lines."), 
        proc() = drawVec2StyleVar(itemInnerSpacing); igHelpMarker("Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label)."), 
        proc() = drawFloatStyleVar(indentSpacing); igHelpMarker("Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2)."), 
        proc() = drawFloatStyleVar(columnsMinSpacing); igHelpMarker("Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1)."), 
        proc() = drawVec2StyleVar(windowMinSize); igHelpMarker("Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints()."), 
        proc() = drawFloatStyleVar(scrollbarSize); igHelpMarker("Width of the vertical scrollbar, Height of the horizontal scrollbar."), 
        proc() = drawFloatStyleVar(grabMinSize); igHelpMarker("Minimum width/height of a grab box for slider/scrollbar."), 
        proc() = drawFloatStyleVar(tabMinWidthForCloseButton); igHelpMarker("Minimum width for close button to appears on an unselected tab when hovered. Set to 0.0f to always show when hovering, set to FLT_MAX to never show close button unless selected."), 
        proc() = drawFloatStyleVar(windowBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly)."), 
        proc() = drawFloatStyleVar(childBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly)."), 
        proc() = drawFloatStyleVar(popupBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly)."), 
        proc() = drawFloatStyleVar(frameBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly)."), 
        proc() = drawFloatStyleVar(tabBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around tabs."), 
        proc() = drawFloatStyleVar(windowRounding); igHelpMarker("Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended."), 
        proc() = drawFloatStyleVar(childRounding); igHelpMarker("Radius of child window corners rounding. Set to 0.0f to have rectangular windows."), 
        proc() = drawFloatStyleVar(frameRounding); igHelpMarker("Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets)."), 
        proc() = drawFloatStyleVar(popupRounding); igHelpMarker("Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)"), 
        proc() = drawFloatStyleVar(scrollbarRounding); igHelpMarker("Radius of grab corners for scrollbar."), 
        proc() = drawFloatStyleVar(grabRounding); igHelpMarker("Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs."), 
        proc() = drawFloatStyleVar(tabRounding); igHelpMarker("Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs."), 
        proc() = drawVec2StyleVar(windowTitleAlign); igHelpMarker("Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered."), 
        proc() = drawComboStyleVar(windowMenuButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left."), 
        proc() = drawComboStyleVar(colorButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right."), 
        proc() = drawVec2StyleVar(buttonTextAlign); igHelpMarker("Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered)."), 
        proc() = drawVec2StyleVar(selectableTextAlign); igHelpMarker("Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line."), 
        proc() = drawFloatStyleVar(logSliderDeadzone); igHelpMarker("The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero."), 
        proc() = drawFloatStyleVar(mouseCursorScale); igHelpMarker("Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later."), 
        proc() = drawBoolStyleVar(antiAliasedLines); igHelpMarker("Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList)."), 
        proc() = drawBoolStyleVar(antiAliasedLinesUseTex); igHelpMarker("Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). Latched at the beginning of the frame (copied to ImDrawList)."), 
        proc() = drawBoolStyleVar(antiAliasedFill); igHelpMarker("Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList)."), 
        proc() = drawFloatStyleVar(curveTessellationTol, 0.1); igHelpMarker("Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality."), 
        proc() = drawFloatStyleVar(circleTessellationMaxError, 0.1); igHelpMarker("Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry."), 
      ]

    if igBeginTabBar("##tabs"):
      if igBeginTabItem("Sizes"):
        drawFloatStyleVar(alpha, 0.1, 1, format = "%.2f"); igHelpMarker("Global alpha applies to everything in Dear ImGui.")
        if igCollapsingHeader("Padding & Spacing"):
          drawVec2StyleVar(windowPadding); igHelpMarker("Padding within a window.")
          drawVec2StyleVar(framePadding); igHelpMarker("Padding within a framed rectangle (used by most widgets).")
          drawVec2StyleVar(cellPadding); igHelpMarker("Padding within a table cell")
          drawVec2StyleVar(touchExtraPadding); igHelpMarker("Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!")
          drawVec2StyleVar(displayWindowPadding); igHelpMarker("Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows.")
          drawVec2StyleVar(displaySafeAreaPadding); igHelpMarker("If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!")
          drawVec2StyleVar(itemSpacing); igHelpMarker("Horizontal and vertical spacing between widgets/lines.")
          drawVec2StyleVar(itemInnerSpacing); igHelpMarker("Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).")
          drawFloatStyleVar(indentSpacing); igHelpMarker("Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).")
          drawFloatStyleVar(columnsMinSpacing); igHelpMarker("Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).")
          drawVec2StyleVar(windowMinSize); igHelpMarker("Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().")
          drawFloatStyleVar(scrollbarSize); igHelpMarker("Width of the vertical scrollbar, Height of the horizontal scrollbar.")
          drawFloatStyleVar(grabMinSize); igHelpMarker("Minimum width/height of a grab box for slider/scrollbar.")
          drawFloatStyleVar(tabMinWidthForCloseButton); igHelpMarker("Minimum width for close button to appears on an unselected tab when hovered. Set to 0.0f to always show when hovering, set to FLT_MAX to never show close button unless selected.")
        if igCollapsingHeader("Borders"):
          drawFloatStyleVar(windowBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
          drawFloatStyleVar(childBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
          drawFloatStyleVar(popupBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
          drawFloatStyleVar(frameBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
          drawFloatStyleVar(tabBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around tabs.")
        if igCollapsingHeader("Rounding"):
          drawFloatStyleVar(windowRounding); igHelpMarker("Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.")
          drawFloatStyleVar(childRounding); igHelpMarker("Radius of child window corners rounding. Set to 0.0f to have rectangular windows.")
          drawFloatStyleVar(frameRounding); igHelpMarker("Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).")
          drawFloatStyleVar(popupRounding); igHelpMarker("Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)")
          drawFloatStyleVar(scrollbarRounding); igHelpMarker("Radius of grab corners for scrollbar.")
          drawFloatStyleVar(grabRounding); igHelpMarker("Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.")
          drawFloatStyleVar(tabRounding); igHelpMarker("Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.")
        if igCollapsingHeader("Alignment"):
          drawVec2StyleVar(windowTitleAlign); igHelpMarker("Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.")
          drawComboStyleVar(windowMenuButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.")
          drawComboStyleVar(colorButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.")
          drawVec2StyleVar(buttonTextAlign); igHelpMarker("Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).")
          drawVec2StyleVar(selectableTextAlign); igHelpMarker("Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.")
        if igCollapsingHeader("Extra"):
          drawFloatStyleVar(logSliderDeadzone); igHelpMarker("The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero.")
          drawFloatStyleVar(mouseCursorScale); igHelpMarker("Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.")
          drawBoolStyleVar(antiAliasedLines); igHelpMarker("Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).")
          drawBoolStyleVar(antiAliasedLinesUseTex); igHelpMarker("Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering (NOT point/nearest filtering). Latched at the beginning of the frame (copied to ImDrawList).")
          drawBoolStyleVar(antiAliasedFill); igHelpMarker("Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).")
          drawFloatStyleVar(curveTessellationTol, 0.1); igHelpMarker("Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.")
          drawFloatStyleVar(circleTessellationMaxError, 0.1); igHelpMarker("Maximum error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry.")

        igEndTabItem()

      #[
      if igBeginTabItem("Colors"):
            static int output_dest = 0
            static bool output_only_modified = true
            if igButton("Export"):
                if output_dest == 0:
                    igLogToClipboard()
                else
                    igLogToTTY()
                igLogText("ImVec4* colors = igGetStyle().Colors;" IM_NEWLINE)
                for (int i = 0; i < ImGuiCol_COUNT i++)
                    const ImVec4& col = style.Colors[i]
                    const char* name = igGetStyleColorName(i)
                    if !output_only_modified || memcmp(&col, &ref->Colors[i], sizeof(ImVec4)) != 0:
                        igLogText("colors[ImGuiCol_%s]%*s= ImVec4(%.2ff, %.2ff, %.2ff, %.2ff)" IM_NEWLINE,
                            name, 23 - (int)strlen(name), "", col.x, col.y, col.z, col.w)
                igLogFinish()
            igSameLine(); igSetNextItemWidth(120); igCombo("##output_type", &output_dest, "To Clipboard\0To TTY\0")
            igSameLine(); igCheckbox("Only Modified Colors", &output_only_modified)

            static ImGuiTextFilter filter
            filter.Draw("Filter colors", igGetFontSize() * 16)

            static ImGuiColorEditFlags alpha_flags = 0
            if igRadioButton("Opaque", alpha_flags == ImGuiColorEditFlags_None))             { alpha_flags = ImGuiColorEditFlags_None; } igSameLine(:
            if igRadioButton("Alpha",  alpha_flags == ImGuiColorEditFlags_AlphaPreview))     { alpha_flags = ImGuiColorEditFlags_AlphaPreview; } igSameLine(:
            if igRadioButton("Both",   alpha_flags == ImGuiColorEditFlags_AlphaPreviewHalf)) { alpha_flags = ImGuiColorEditFlags_AlphaPreviewHalf; } igSameLine(:
            igHelpMarker(
                "In the color list:\n"
                "Left-click on color square to open color picker,\n"
                "Right-click to open edit options menu.")

            igBeginChild("##colors", ImVec2(0, 0), true, ImGuiWindowFlags_AlwaysVerticalScrollbar | ImGuiWindowFlags_AlwaysHorizontalScrollbar | ImGuiWindowFlags_NavFlattened)
            igPushItemWidth(-160)
            for (int i = 0; i < ImGuiCol_COUNT i++)
                const char* name = igGetStyleColorName(i)
                if !filter.PassFilter(name):
                    continue
                igPushID(i)
                igColorEdit4("##color", (float*)&style.Colors[i], ImGuiColorEditFlags_AlphaBar | alpha_flags)
                if memcmp(&style.Colors[i], &ref->Colors[i], sizeof(ImVec4)) != 0:
                    # Tips: in a real user application, you may want to merge and use an icon font into the main font,
                    # so instead of "Save"/"Revert" you'd use icons!
                    # Read the FAQ and docs/FONTS.md about using icon fonts. It's really easy and super convenient!
                    igSameLine(0.0f, style.ItemInnerSpacing.x); if igButton("Save"): { ref->Colors[i] = style.Colors[i] }
                    igSameLine(0.0f, style.ItemInnerSpacing.x); if igButton("Revert"): { style.Colors[i] = ref->Colors[i] }
                igSameLine(0.0f, style.ItemInnerSpacing.x)
                igTextUnformatted(name)
                igPopID()
            igPopItemWidth()
            igEndChild()

            igEndTabItem()
      if igBeginTabItem("Rendering"):
            igCheckbox("Anti-aliased lines", &style.AntiAliasedLines)
            igSameLine()
            igHelpMarker("When disabling anti-aliasing lines, you'll probably want to disable borders in your style as well.")

            igCheckbox("Anti-aliased lines use texture", &style.AntiAliasedLinesUseTex)
            igSameLine()
            igHelpMarker("Faster lines using texture data. Require backend to render with bilinear filtering (not point/nearest filtering).")

            igCheckbox("Anti-aliased fill", &style.AntiAliasedFill)
            igPushItemWidth(igGetFontSize() * 8)
            igDragFloat("Curve Tessellation Tolerance", &style.CurveTessellationTol, 0.02f, 0.10f, 10.0f, "%.2f")
            if style.CurveTessellationTol < 0.10f: style.CurveTessellationTol = 0.10f

            # When editing the "Circle Segment Max Error" value, draw a preview of its effect on auto-tessellated circles.
            igDragFloat("Circle Tessellation Max Error", &style.CircleTessellationMaxError , 0.005f, 0.10f, 5.0f, "%.2f", ImGuiSliderFlags_AlwaysClamp)
            if igIsItemActive():
            {
                igSetNextWindowPos(igGetCursorScreenPos())
                igBeginTooltip()
                igTextUnformatted("(R = radius, N = number of segments)")
                igSpacing()
                ImDrawList* draw_list = igGetWindowDrawList()
                const float min_widget_width = igCalcTextSize("N: MMM\nR: MMM").x
                for (int n = 0; n < 8 n++)
                {
                    const float RAD_MIN = 5.0f
                    const float RAD_MAX = 70.0f
                    const float rad = RAD_MIN + (RAD_MAX - RAD_MIN) * (float)n / (8.0f - 1.0f)

                    igBeginGroup()

                    igText("R: %.f\nN: %d", rad, draw_list->_CalcCircleAutoSegmentCount(rad))

                    const float canvas_width = IM_MAX(min_widget_width, rad * 2.0f)
                    const float offset_x     = floorf(canvas_width * 0.5f)
                    const float offset_y     = floorf(RAD_MAX)

                    const ImVec2 p1 = igGetCursorScreenPos()
                    draw_list->AddCircle(ImVec2(p1.x + offset_x, p1.y + offset_y), rad, igGetColorU32(ImGuiCol_Text))
                    igDummy(ImVec2(canvas_width, RAD_MAX * 2))

                    /*
                    const ImVec2 p2 = igGetCursorScreenPos()
                    draw_list->AddCircleFilled(ImVec2(p2.x + offset_x, p2.y + offset_y), rad, igGetColorU32(ImGuiCol_Text))
                    igDummy(ImVec2(canvas_width, RAD_MAX * 2))
                    */

                    igEndGroup()
                    igSameLine()
                }
                igEndTooltip()
            }
            igSameLine()
            igHelpMarker("When drawing circle primitives with \"num_segments == 0\" tesselation will be calculated automatically.")

            igDragFloat("Global Alpha", &style.Alpha, 0.005f, 0.20f, 1.0f, "%.2f") # Not exposing zero here so user doesn't "lose" the UI (zero alpha clips all widgets). But application code could have a toggle to switch between zero and non-zero.
            igDragFloat("Disabled Alpha", &style.DisabledAlpha, 0.005f, 0.0f, 1.0f, "%.2f"); igSameLine(); igHelpMarker("Additional alpha multiplier for disabled items (multiply over current value of Alpha).")
            igPopItemWidth()

            igEndTabItem()
      ]#

      igEndTabBar()
