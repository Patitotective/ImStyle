# ImStyle
A nice way to manage your ImGui application's style.

## Installation
```
nimble install https://github.com/Patitotective/ImStyle
```

## Example
Normally you would do this to change your application's style:
```nim
import nimgl/imgui
...
var style = igGetStyle()
style.alpha = 1f
style.windowPadding = ImVec2(x: 4f, y: 4f)
style.windowMenuButtonPosition = ImGuiDir.Left
style.colors[ord(Text)] = ImVec4(x: 0f, y: 0f, z: 0f, w: 1f) # RGBA
...
```
But with _ImStyle_ you can just create a `style.niprefs`:
```nim
# ImStyle
alpha = 1 # -> 4f
windowPadding = [4, 4] # -> ImVec2(x: 4f, y: 4f) 
windowMenuButtonPosition = "left" # Or 0
colors=>
	Text = "#000000"
```
And then read it like this:
```nim
import imstyle
...
setStyle("style.niprefs") # getStyle returns the ImGuiStyle object itself
...
```
With _ImStyle_ it's way more clear and **you don't need to compile your application again each time you change its style**.

## About
- Docs: https://patitotective.github.io/ImStyle.
- GitHub: https://github.com/Patitotective/ImStyle.
- Discord: https://discord.gg/as85Q4GnR6.

Contact me:
- Discord: **Patitotective#0127**.
- Tiwtter: [@patitotective](https://twitter.com/patitotective).
- Email: **cristobalriaga@gmail.com**.

***v.1.0***
