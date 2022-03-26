import std/unittest

import chroma
import imstyle

proc getImVec4(color: string): ImVec4 = 
  let color = color.parseHtmlColor()
  ImVec4(x: color.r, y: color.g, z: color.b, w: color.a)

test "can get style":
  let style = getIgStyle("style.niprefs")
  assert style == ImGuiStyle(
    alpha: 1.0, 
    windowPadding: ImVec2(x: 6.0, y: 3.0), 
    windowRounding: 0.0, 
    windowBorderSize: 1.0, 
    windowMinSize: ImVec2(x: 32.0, y: 32.0), 
    windowTitleAlign: ImVec2(x: 0.5, y: 0.5), 
    windowMenuButtonPosition: ImGuiDir.Left, 
    childRounding: 0.0, 
    childBorderSize: 1.0, 
    popupRounding: 0.0, 
    popupBorderSize: 1.0, 
    framePadding: ImVec2(x: 5.0, y: 1.0), 
    frameRounding: 3.0, 
    frameBorderSize: 1.0, 
    itemSpacing: ImVec2(x: 7.0, y: 1.0), 
    itemInnerSpacing: ImVec2(x: 1.0, y: 1.0), 
    cellPadding: ImVec2(x: 4.0, y: 2.0), 
    touchExtraPadding: ImVec2(x: 0.0, y: 0.0), 
    indentSpacing: 6.0, 
    columnsMinSpacing: 6.0, 
    scrollbarSize: 13.0, 
    scrollbarRounding: 16.0, 
    grabMinSize: 20.0, 
    grabRounding: 2.0, 
    logSliderDeadzone: 4.0, 
    tabRounding: 4.0, 
    tabBorderSize: 1.0, 
    tabMinWidthForCloseButton: 0.0, 
    colorButtonPosition: ImGuiDir.Right, 
    buttonTextAlign: ImVec2(x: 0.5, y: 0.5), 
    selectableTextAlign: ImVec2(x: 0.0, y: 0.0), 
    displayWindowPadding: ImVec2(x: 19.0, y: 19.0), 
    displaySafeAreaPadding: ImVec2(x: 3.0, y: 0.0), 
    mouseCursorScale: 1.0, 
    antiAliasedLines: true, 
    antiAliasedLinesUseTex: true, 
    antiAliasedFill: true, 
    curveTessellationTol: 1.25, 
    colors: [
      "#000000".getImVec4(), # Text
      "#999999".getImVec4(), # TextDisabled
      "#EFEFEF".getImVec4(), # WindowBg
      "#000000".getImVec4(), # ChildBg
      "#FFFFFF".getImVec4(), # PopupBg
      "#000000".getImVec4(), # Border
      "#FFFFFF".getImVec4(), # BorderShadow
      "#FFFFFF".getImVec4(), # FrameBg
      "#4296F9".getImVec4(), # FrameBgHovered
      "#4296F9".getImVec4(), # FrameBgActive
      "#F4F4F4".getImVec4(), # TitleBg
      "#D1D1D1".getImVec4(), # TitleBgActive
      "#FFFFFF".getImVec4(), # TitleBgCollapsed
      "#DBDBDB".getImVec4(), # MenuBarBg
      "#F9F9F9".getImVec4(), # ScrollbarBg
      "#AFAFAF".getImVec4(), # ScrollbarGrab
      "#969696".getImVec4(), # ScrollbarGrabHovered
      "#7C7C7C".getImVec4(), # ScrollbarGrabActive
      "#4296F9".getImVec4(), # CheckMark
      "#3D84E0".getImVec4(), # SliderGrab
      "#4296F9".getImVec4(), # SliderGrabActive
      "#73D216".getImVec4(), # Button
      "#4296F9".getImVec4(), # ButtonHovered
      "#0F87F9".getImVec4(), # ButtonActive
      "#4296F9".getImVec4(), # Header
      "#4296F9".getImVec4(), # HeaderHovered
      "#4296F9".getImVec4(), # HeaderActive
      "#6D6D7F".getImVec4(), # Separator
      "#1966BF".getImVec4(), # SeparatorHovered
      "#1966BF".getImVec4(), # SeparatorActive
      "#FFFFFF".getImVec4(), # ResizeGrip
      "#4296F9".getImVec4(), # ResizeGripHovered
      "#4296F9".getImVec4(), # ResizeGripActive
      "#2D5993".getImVec4(), # Tab
      "#4296F9".getImVec4(), # TabHovered
      "#3268AD".getImVec4(), # TabActive
      "#111A25".getImVec4(), # TabUnfocused
      "#22426C".getImVec4(), # TabUnfocusedActive
      "#636363".getImVec4(), # PlotLines
      "#FF6D59".getImVec4(), # PlotLinesHovered
      "#E5B200".getImVec4(), # PlotHistogram
      "#FF9900".getImVec4(), # PlotHistogramHovered
      "#303033".getImVec4(), # TableHeaderBg
      "#4F4F59".getImVec4(), # TableBorderStrong
      "#3A3A3F".getImVec4(), # TableBorderLight
      "#000000".getImVec4(), # TableRowBg
      "#FFFFFF".getImVec4(), # TableRowBgAlt
      "#4296F9".getImVec4(), # TextSelectedBg
      "#FFFF00".getImVec4(), # DragDropTarget
      "#4296F9".getImVec4(), # NavHighlight
      "#FFFFFF".getImVec4(), # NavWindowingHighlight
      "#CCCCCC".getImVec4(), # NavWindowingDimBg
      "#CCCCCC".getImVec4(), # ModalWindowDimBg
    ], 
  )
