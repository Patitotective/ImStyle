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
## Using ImStyle you will only need to create a KDL file (e.i.: `style.kdl`), that will look like:
## ```kdl
## # ImStyle
## alpha 1 # -> 1.0
## windowPadding 4 4 # -> ImVec2(x: 4.0, y: 4.0) 
## windowMenuButtonPosition "Left" # ImGuiDir.Left
## ...
## colors {
##   Text 0 0 0 1 # -> ImVec4(x: 0f, y: 0f, z: 0f, w: 1f)
##   ...
## }
## ```
## And load it in your code:
## ```nim
## import imstyle
## ...
## parseKdlFile("style.kdl").loadStyle().setCurrent()
## ...
## ```

import std/[strformat, strutils, macros]
import kdl
import nimgl/imgui

export kdl

type
  ImStyleError* = object of CatchableError

  # PropKind* = enum
  #   pkFloat, pkVec, pkDir, pkBool

  # Prop* = object
  #   case kind*: PropKind
  #   of pkFloat:
  #     floatV*: float32
  #   of pkVec:
  #     vecV*: ImVec2
  #   of pkDir:
  #     dirV*: ImGuiDir
  #   of pkBool:
  #     boolV*: bool

  # ImStyle = object
  #   style*: ImGuiStyle
  #   customProps*: Table[string, Prop]
  #   customColors*: Table[string, ImVec4]

template fail(msg: string) = 
  raise newException(ImStyleError, msg)

template check(cond: untyped, msg = "") = 
  if not cond:
    let txt = msg
    fail astToStr(cond) & " failed" & (if txt.len > 0: ": " & txt else: "")

proc igVec2(x, y: float32): ImVec2 = ImVec2(x: x, y: y)

proc igVec4(x, y, z, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

proc initImGuiStyle*(): ImGuiStyle = 
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

proc newHook*(v: var ImGuiStyle) = 
  v = initImGuiStyle()

proc encodeHook*(a: ImVec2, v: var KdlNode, name: string) = 
  v = initKNode(name, args = toKdlArgs(a.x, a.y))

proc encodeHook*(a: array[53, ImVec4], v: var KdlNode, name: string) = 
  v = initKNode(name)
  v.children.setLen(a.len)

  for e, color in a:
    let args = 
      when defined(imstyleIntColors):
        toKdlArgs(byte(color.x * 255), byte(color.y * 255), byte(color.z * 255), byte(color.w * 255))
      else:
        toKdlArgs(color.x, color.y, color.z, color.w)

    let props = 
      when defined(imstyleIntColors):
        initTable[string, KdlVal]()
      else:
        toKdlProps({"float": true})

    v.children[e] = initKNode($ImGuiCol(e), args = args, props = props)

proc decodeHook*(a: KdlNode, v: var ImVec2) =
  check a.args.len == 2
  v = igVec2(a.args[0].get(float32), a.args[1].get(float32))

proc decodeHook*(a: KdlNode, v: var array[53, ImVec4]) = 
  for node in a.children:
    let col = parseEnum[ImGuiCol](node.name)

    if node.props.getOrDefault("float", false.initKVal).getBool(): # If "float" is true (if "float" doesn't exist default to false) decode as RGBA, each value being a float from 0 to 1
      check node.args.len in 3..4
      let alpha = 
        if node.args.len == 4:
          node.args[3].get(float32)
        else: 1f

      v[col.int] = igVec4(node.args[0].get(float32), node.args[1].get(float32), node.args[2].get(float32), alpha)
    else: # Decode as RGBA, each value being an uint8 from 0 to 255
      check node.args.len in 3..4
      let alpha = 
        if node.args.len == 4:
          node.args[3].get(byte)
        else: 255.byte

      v[col.int] = igVec4(node.args[0].get(byte).float32 / 255, node.args[1].get(byte).float32 / 255, node.args[2].get(byte).float32 / 255, alpha.float32 / 255)

proc loadStyle*(style: KdlNode or KdlDoc): ImGuiStyle = 
  # Decodes an ImGuiStyle object from `style`
  style.decode(result)

proc setCurrent*(style: ImGuiStyle) = 
  # Sets the current style to `style`
  igGetStyle()[] = style
