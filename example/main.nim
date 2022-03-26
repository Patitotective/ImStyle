import chroma
import imstyle
import nimgl/[opengl, glfw]
import nimgl/imgui, nimgl/imgui/[impl_opengl, impl_glfw]

import src/utils

const
  appName = "ImExample"
  appVersion = "0.1.0"
  stylePath = "src/style.niprefs"
  iconPath = "assets/icon.png"
  fontPath = "assets/Roboto-Regular.ttf"
  fontSize = 18f
  bgColor = "#EFEFEF".parseHtmlColor()

template drawMenuBar() = 
  if igBeginMenuBar():
    if igBeginMenu("File"):
      if igMenuItem("Preferences", "Ctrl+P"):
        echo "preferences"

      if igMenuItem("Quit", "Ctrl+Q"):
        win.setWindowShouldClose(true)
      igEndMenu()

    if igBeginMenu("Edit"):
      if igMenuItem("Copy", "Ctrl+C"):
        echo "copy"
      if igMenuItem("Paste", "Ctrl+V"):
        echo "paste"

      igEndMenu()

    if igBeginMenu("About"):
      if igMenuItem("About"):
        echo appName, " [", appVersion, "]"

      igEndMenu() 
    
    igEndMenuBar()

template draw() = # Draw ImGui stuff
  igBegin(appName, flags = makeWinFlags(ImGuiWindowFlags.NoResize, NoTitleBar, NoCollapse, NoMove, MenuBar))
  igSetWindowPos(ImVec2(x: 0, y: 0))
  font.igPushFont()

  drawMenuBar()

  igText("Hello World")
  
  if igButton("Click me"):
    echo "Clicked"

  # Update window size to fit application's window size
  var width, height: int32
  win.getWindowSize(width.addr, height.addr)
  igSetWindowSize(
    appName,
    ImVec2(
      x: float32 width, 
      y: float32 height
    )
  )

  igPopFont()
  igEnd()

template display() = 
  glfwPollEvents()

  igOpenGL3NewFrame()
  igGlfwNewFrame()
  igNewFrame()

  draw()

  igRender()

  glClearColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
  glClear(GL_COLOR_BUFFER_BIT)

  igOpenGL3RenderDrawData(igGetDrawData())  

template initWindow() = 
  glfwWindowHint(GLFWContextVersionMajor, 3)
  glfwWindowHint(GLFWContextVersionMinor, 3)
  glfwWindowHint(GLFWOpenglForwardCompat, GLFW_TRUE)
  glfwWindowHint(GLFWOpenglProfile, GLFW_OPENGL_CORE_PROFILE)
  glfwWindowHint(GLFWResizable, GLFW_TRUE)
  win = glfwCreateWindow(
    500, 
    500, 
    appName, 
    icon = false # Do not use default icon
  )

  if win == nil:
    quit(-1)

  var image = initGLFWImageFromFile(iconPath)
  win.setWindowIcon(1, image.addr)

  win.makeContextCurrent()

  win.setWindowSizeLimits(200, 200, GLFW_DONT_CARE, GLFW_DONT_CARE) # minWidth, minHeight, maxWidth, maxHeight

proc main() =
  doAssert glfwInit()

  var win: GLFWWindow
  initWindow()

  doAssert glInit()

  let context = igCreateContext()
  let io = igGetIO()
  let font = io.fonts.addFontFromFileTTF(fontPath, fontSize)

  io.iniFilename = nil # Disable ini file

  doAssert igGlfwInitForOpenGL(win, true)
  doAssert igOpenGL3Init()

  setIgStyle(stylePath)

  while not win.windowShouldClose:
    display()
    win.swapBuffers()

  igOpenGL3Shutdown()
  igGlfwShutdown()
  context.igDestroyContext()

  win.destroyWindow()
  glfwTerminate()

when isMainModule:
  main()
