import std/unittest

import chroma
import imstyle

proc getImVec4(color: string): ImVec4 = 
  let color = color.parseHtmlColor()
  ImVec4(x: color.r, y: color.g, z: color.b, w: color.a)

test "can get style":
  let style = getStyle("style.niprefs")
  assert style == ImGuiStyle(
    alpha: 1f, 
    windowPadding: ImVec2(x: 4f, y: 4f), 
    windowRounding: 3f, 
    windowBorderSize: 1f, 
    windowMinSize: ImVec2(x: 200f, y: 150f), 
    windowTitleAlign: ImVec2(x: 0f, y: 0.5f), 
    windowMenuButtonPosition: ImGuiDir.Left, 

    childRounding: 3f, 
    childBorderSize: 1f, 

    popupRounding: 3f, 
    popupBorderSize: 1f, 

    framePadding: ImVec2(x: 6f, y: 4f), 
    frameRounding: 3f, 
    frameBorderSize: 0f, 

    itemSpacing: ImVec2(x: 6f, y: 2f), 
    itemInnerSpacing: ImVec2(x: 2f, y: 2f), 

    cellPadding: ImVec2(x: 4f, y: 4f), 

    touchExtraPadding: ImVec2(x: 2f, y: 2f), 

    indentSpacing: 5f, 

    columnsMinSpacing: 2f, 

    scrollbarSize: 18f, 
    scrollbarRounding: 2f, 

    grabMinSize: 2f, 
    grabRounding: 2f, 

    logSliderDeadzone: 2f, 

    tabRounding: 2f, 
    tabBorderSize: 2f, 
    tabMinWidthForCloseButton: 2f, 

    colorButtonPosition: ImGuiDir.Left, 

    buttonTextAlign: ImVec2(x: 0.5f, y: 0.5f), 

    selectableTextAlign: ImVec2(x: 0.5f, y: 0.5f), 

    displayWindowPadding: ImVec2(x: 4f, y: 4f), 
    displaySafeAreaPadding: ImVec2(x: 4f, y: 4f), 

    mouseCursorScale: 1f, 

    antiAliasedLines: true, 
    antiAliasedLinesUseTex: true, 
    antiAliasedFill: true, 

    curveTessellationTol: 2f, 

    # circleSegmentMaxError: 2f, 

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
