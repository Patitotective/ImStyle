# ImStyle
A nice way to manage your ImGui application's style.

## Installation
```
nimble install imstyle
```

## Usage
Normally you would do this to change your application's style:
```nim
import nimgl/imgui
...
let style = igGetStyle()
style.alpha = 1f
style.windowPadding = ImVec2(x: 4f, y: 4f)
style.windowMenuButtonPosition = ImGuiDir.Left
style.colors[ord ImGuiCol.Text] = ImVec4(x: 0f, y: 0f, z: 0f, w: 1f) # RGBA
...
```
But with _ImStyle_ you wil just create a `style.toml`:
```nim
# ImStyle
alpha = 1 # -> 1.0
windowPadding = [4, 4] # -> ImVec2(x: 4.0, y: 4.0) 
windowMenuButtonPosition = "Left"
...
[colors]
Text = "#000000" # or "rgb(0, 0, 0)" or or "rgba(0, 0, 0, 1)" or [0, 0, 0, 1]
...
```

Then read and set the style like this:
```nim
import imstyle
...
igGetCurrentContext().style = styleFromToml("style.toml")
...
```
With _ImStyle_ it's way more clear and **you don't need to compile your application again each time you change its style**.  

Read more at the [docs](https://patitotective.github.io/ImStyle).

## Styles
For style examples look at [styles/](https://github.com/Patitotective/ImStyle/tree/main/styles).  
Or at [ImThemes](https://github.com/Patitotective/ImThemes), a theme manager and editor that supports ImStyle!
(Make a PR if you want to add your own).

## Fields Description
Fields of [`ImGuiStyle`](https://nimgl.dev/docs/imgui.html#ImGuiStyle):
- `Alpha`: Global alpha applies to everything in Dear ImGui.
- `DisabledAlpha`: Additional alpha multiplier applied by BeginDisabled(). Multiply over current value of Alpha.
- `WindowPadding`: Padding within a window.
- `WindowRounding`: Radius of window corners rounding. Set to 0.0f to have rectangular windows. Large values tend to lead to variety of artifacts and are not recommended.
- `WindowBorderSize`: Thickness of border around windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
- `WindowMinSize`: Minimum window size. This is a global setting. If you want to constraint individual windows, use SetNextWindowSizeConstraints().
- `WindowTitleAlign`: Alignment for title bar text. Defaults to (0.0f,0.5f) for left-aligned,vertically centered.
- `WindowMenuButtonPosition`: Side of the collapsing/docking button in the title bar (None/Left/Right). Defaults to ImGuiDir_Left.
- `ChildRounding`: Radius of child window corners rounding. Set to 0.0f to have rectangular windows.
- `ChildBorderSize`: Thickness of border around child windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
- `PopupRounding`: Radius of popup window corners rounding. (Note that tooltip windows use WindowRounding)
- `PopupBorderSize`: Thickness of border around popup/tooltip windows. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
- `FramePadding`: Padding within a framed rectangle (used by most widgets).
- `FrameRounding`: Radius of frame corners rounding. Set to 0.0f to have rectangular frame (used by most widgets).
- `FrameBorderSize`: Thickness of border around frames. Generally set to 0.0f or 1.0f. (Other values are not well tested and more CPU/GPU costly).
- `ItemSpacing`: Horizontal and vertical spacing between widgets/lines.
- `ItemInnerSpacing`: Horizontal and vertical spacing between within elements of a composed widget (e.g. a slider and its label).
- `CellPadding`: Padding within a table cell
- `TouchExtraPadding`: Expand reactive bounding box for touch-based system where touch position is not accurate enough. Unfortunately we don't sort widgets so priority on overlap will always be given to the first widget. So don't grow this too much!
- `IndentSpacing`: Horizontal indentation when e.g. entering a tree node. Generally == (FontSize + FramePadding.x*2).
- `ColumnsMinSpacing`: Minimum horizontal spacing between two columns. Preferably > (FramePadding.x + 1).
- `ScrollbarSize`: Width of the vertical scrollbar, Height of the horizontal scrollbar.
- `ScrollbarRounding`: Radius of grab corners for scrollbar.
- `GrabMinSize`: Minimum width/height of a grab box for slider/scrollbar.
- `GrabRounding`: Radius of grabs corners rounding. Set to 0.0f to have rectangular slider grabs.
- `LogSliderDeadzone`: The size in pixels of the dead-zone around zero on logarithmic sliders that cross zero.
- `TabRounding`: Radius of upper corners of a tab. Set to 0.0f to have rectangular tabs.
- `TabBorderSize`: Thickness of border around tabs.
- `TabMinWidthForCloseButton`: Minimum width for close button to appears on an unselected tab when hovered. Set to 0.0f to always show when hovering, set to FLT_MAX to never show close button unless selected.
- `ColorButtonPosition`: Side of the color button in the ColorEdit4 widget (left/right). Defaults to ImGuiDir_Right.
- `ButtonTextAlign`: Alignment of button text when button is larger than text. Defaults to (0.5f, 0.5f) (centered).
- `SelectableTextAlign`: Alignment of selectable text. Defaults to (0.0f, 0.0f) (top-left aligned). It's generally important to keep this left-aligned if you want to lay multiple items on a same line.
- `DisplayWindowPadding`: Window position are clamped to be visible within the display area or monitors by at least this amount. Only applies to regular windows.
- `DisplaySafeAreaPadding`: If you cannot see the edges of your screen (e.g. on a TV) increase the safe area padding. Apply to popups/tooltips as well regular windows. NB: Prefer configuring your TV sets correctly!
- `MouseCursorScale`: Scale software rendered mouse cursor (when io.MouseDrawCursor is enabled). May be removed later.
- `AntiAliasedLines`: Enable anti-aliased lines/borders. Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
- `AntiAliasedLinesUseTex`: Enable anti-aliased lines/borders using textures where possible. Require backend to render with bilinear filtering. Latched at the beginning of the frame (copied to ImDrawList).
- `AntiAliasedFill`: Enable anti-aliased edges around filled shapes (rounded rectangles, circles, etc.). Disable if you are really tight on CPU/GPU. Latched at the beginning of the frame (copied to ImDrawList).
- `CurveTessellationTol`: Tessellation tolerance when using PathBezierCurveTo() without a specific number of segments. Decrease for highly tessellated curves (higher quality, more polygons), increase to reduce quality.
- `CircleTessellationMaxError`: error (in pixels) allowed when using AddCircle()/AddCircleFilled() or drawing rounded corner rectangles with no explicit segment count specified. Decrease for higher quality but more geometry.
- `Colors`: See [ImGuiCol](https://nimgl.dev/docs/imgui.html#ImGuiCol).

(Taken from [ocornut/imgui](https://github.com/ocornut/imgui/blob/master/imgui.h#L1837)).

## About
- Docs: https://patitotective.github.io/ImStyle.
- GitHub: https://github.com/Patitotective/ImStyle.
- Discord: https://discord.gg/as85Q4GnR6.

Contact me:
- Discord: **Patitotective#0127**.
- Tiwtter: [@patitotective](https://twitter.com/patitotective).
- Email: **cristobalriaga@gmail.com**.
