import std/strutils
import niprefs
import nimgl/imgui
# import ../imstyle

const
  alignCount = 28
  widgetsGroup = { # Style properties grouped by widgets
    "": @[Alpha, DisabledAlpha, IndentSpacing, CellPadding, TabRounding, ButtonTextAlign, SelectableTextAlign], 
    "Window": @[WindowPadding, WindowBorderSize, WindowMinSize, WindowTitleAlign], 
    "Child": @[ChildRounding, ChildBorderSize], 
    "Popup": @[PopupRounding, PopupBorderSize], 
    "Frame": @[ImGuiStyleVar.FramePadding, FrameRounding, FrameBorderSize], 
    "Item": @[ItemSpacing, ItemInnerSpacing], 
    "Scrollbar": @[ScrollbarSize, ScrollbarRounding], 
    "Grab": @[GrabMinSize, GrabRounding], 
  }.toTable()
  propsGroup = { # Style properties grouped by property kinds
    "": @[Alpha, DisabledAlpha], 
    "Padding & Spacing": @[WindowPadding, ImGuiStyleVar.FramePadding, ItemSpacing, ItemInnerSpacing, IndentSpacing], 
    "Rounding": @[WindowRounding, ChildRounding, PopupRounding, FrameRounding, ScrollbarRounding, GrabRounding, TabRounding], 
    "Border": @[WindowBorderSize, ChildBorderSize, PopupBorderSize, FrameBorderSize], 
    "Size": @[WindowMinSize, ScrollbarSize, GrabMinSize], 
    "Alignment": @[WindowTitleAlign, ButtonTextAlign, SelectableTextAlign], 
  }.toTable()

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

proc drawImStyleEditor*(refStyle: ptr ImGuiStyle = nil, filter: string = "kind") = 
    let style = if refStyle.isNil: igGetStyle() else: refStyle

    if igBeginTabBar("##tabs"):
      if igBeginTabItem("Sizes"):
        drawFloatStyleVar(alpha, 0.1, 1, format = "%.2f"); igHelpMarker("Global alpha applies to everything in Dear ImGui.")
        drawFloatStyleVar(disabledAlpha, 0.1, 1, format = "%.2f"); igHelpMarker("Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha.")
        drawVec2StyleVar(windowPadding); igHelpMarker("Padding within a window.")
        drawFloatStyleVar(windowRounding); igHelpMarker("Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.")
        drawFloatStyleVar(windowBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
        drawVec2StyleVar(windowMinSize, 1, 20); igHelpMarker("Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().")
        drawVec2StyleVar(windowTitleAlign); igHelpMarker("Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.")
        drawFloatStyleVar(childRounding); igHelpMarker("Radius of child window corners rounding. Set to 0.0f to have rectangular windows.")
        drawFloatStyleVar(childBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
        drawFloatStyleVar(popupRounding); igHelpMarker("Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)")
        drawFloatStyleVar(popupBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
        drawVec2StyleVar(framePadding); igHelpMarker("Padding within a framed rectangle (used by most widgets).")
        drawFloatStyleVar(frameRounding); igHelpMarker("Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).")
        drawFloatStyleVar(frameBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).")
        drawVec2StyleVar(itemSpacing); igHelpMarker("Horizontal and vertical spacing between widgets/lines.")
        drawVec2StyleVar(itemInnerSpacing); igHelpMarker("Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).")
        drawFloatStyleVar(indentSpacing); igHelpMarker("Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).")
        drawVec2StyleVar(cellPadding); igHelpMarker("Padding within a table cell")
        drawFloatStyleVar(scrollbarSize); igHelpMarker("Width of the vertical scrollbar, Height of the horizontal scrollbar.")
        drawFloatStyleVar(scrollbarRounding); igHelpMarker("Radius of grab corners for scrollbar.")
        drawFloatStyleVar(grabMinSize); igHelpMarker("Minimum width/height of a grab box for slider/scrollbar.")
        drawFloatStyleVar(grabRounding); igHelpMarker("Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.")
        drawFloatStyleVar(tabRounding); igHelpMarker("Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.")
        # drawFloatStyleVar(tabBorderSize, 0, 1, "%.0f"); igHelpMarker("Thickness of border around tabs.")
        # drawComboStyleVar(windowMenuButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.")
        # drawComboStyleVar(colorButtonPosition, [ImGuiDir.None, ImGuiDir.Left, ImGuiDir.Right]); igHelpMarker("Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.")
        drawVec2StyleVar(buttonTextAlign); igHelpMarker("Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).")
        drawVec2StyleVar(selectableTextAlign); igHelpMarker("Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.")

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
