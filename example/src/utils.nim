import stb_image/read as stbi
import nimgl/[imgui, glfw]

proc igVec4*(x, y, z, w: float32): ImVec4 = ImVec4(x: x, y: y, z: z, w: w)

func makeWinFlags*(flags: varargs[ImguiWindowFlags]): ImGuiWindowFlags =
  var res = 0
  for x in flags:
    res = res or int(x)

  result = ImGuiWindowFlags res
  
proc readImage(path: string): tuple[data: seq[uint8], width, height: int] = 
  var width, height, channels: int

  result.data = stbi.load(path, width, height, channels, stbi.Default)
  result.width = width
  result.height = height

proc initGLFWImageFromFile*(path: string): GLFWImage = 
  var image = path.readImage()
  result = GLFWImage(pixels: cast[ptr cuchar](image.data[0].unsafeAddr), width: cast[int32](image.width), height: cast[int32](image.height))
