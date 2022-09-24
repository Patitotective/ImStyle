import std/unittest

import imstyle
import nimgl/imgui

test "can get style":
  check styleFromToml("style.toml") == ImGuiStyle(alpha: 1.0, disabledAlpha: 0.6000000238418579, windowPadding: ImVec2(x: 8.0, y: 8.0), windowRounding: 0.0, windowBorderSize: 1.0, windowMinSize: ImVec2(x: 32.0, y: 32.0), windowTitleAlign: ImVec2(x: 0.0, y: 0.5), windowMenuButtonPosition: ImGuiDir.Left, childRounding: 0.0, childBorderSize: 1.0, popupRounding: 0.0, popupBorderSize: 1.0, framePadding: ImVec2(x: 4.0, y: 3.0), frameRounding: 0.0, frameBorderSize: 0.0, itemSpacing: ImVec2(x: 8.0, y: 4.0), itemInnerSpacing: ImVec2(x: 4.0, y: 4.0), cellPadding: ImVec2(x: 4.0, y: 2.0), touchExtraPadding: ImVec2(x: 0.0, y: 0.0), indentSpacing: 21.0, columnsMinSpacing: 6.0, scrollbarSize: 14.0, scrollbarRounding: 9.0, grabMinSize: 10.0, grabRounding: 0.0, logSliderDeadzone: 4.0, tabRounding: 4.0, tabBorderSize: 0.0, tabMinWidthForCloseButton: 0.0, colorButtonPosition: ImGuiDir.Right, buttonTextAlign: ImVec2(x: 0.5, y: 0.5), selectableTextAlign: ImVec2(x: 0.0, y: 0.0), displayWindowPadding: ImVec2(x: 19.0, y: 19.0), displaySafeAreaPadding: ImVec2(x: 3.0, y: 3.0), mouseCursorScale: 1.0, antiAliasedLines: true, antiAliasedLinesUseTex: true, antiAliasedFill: true, curveTessellationTol: 1.25, circleTessellationMaxError: 0.300000011920929, colors: [ImVec4(x: 0.0, y: 0.0, z: 0.0, w: 1.0), ImVec4(x: 0.6000000238418579, y: 0.6000000238418579, z: 0.6000000238418579, w: 1.0), ImVec4(x: 0.9372549057006836, y: 0.9372549057006836, z: 0.9372549057006836, w: 1.0), ImVec4(x: 0.0, y: 0.0, z: 0.0, w: 0.0), ImVec4(x: 1.0, y: 1.0, z: 1.0, w: 0.9800000190734863), ImVec4(x: 0.0, y: 0.0, z: 0.0, w: 0.300000011920929), ImVec4(x: 0.0, y: 0.0, z: 0.0, w: 0.0), ImVec4(x: 1.0, y: 1.0, z: 1.0, w: 1.0), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.4000000059604645), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.6700000166893005), ImVec4(x: 0.95686274766922, y: 0.95686274766922, z: 0.95686274766922, w: 1.0), ImVec4(x: 0.8196078538894653, y: 0.8196078538894653, z: 0.8196078538894653, w: 1.0), ImVec4(x: 1.0, y: 1.0, z: 1.0, w: 0.5099999904632568), ImVec4(x: 0.8588235378265381, y: 0.8588235378265381, z: 0.8588235378265381, w: 1.0), ImVec4(x: 0.9764705896377563, y: 0.9764705896377563, z: 0.9764705896377563, w: 0.5299999713897705), ImVec4(x: 0.686274528503418, y: 0.686274528503418, z: 0.686274528503418, w: 0.800000011920929), ImVec4(x: 0.4862745106220245, y: 0.4862745106220245, z: 0.4862745106220245, w: 0.800000011920929), ImVec4(x: 0.4862745106220245, y: 0.4862745106220245, z: 0.4862745106220245, w: 1.0), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 1.0), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.7799999713897705), ImVec4(x: 0.4588235318660736, y: 0.5372549295425415, z: 0.800000011920929, w: 0.6000000238418579), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.4000000059604645), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 1.0), ImVec4(x: 0.05882352963089943, y: 0.529411792755127, z: 0.9764705896377563, w: 1.0), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.3100000023841858), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.800000011920929), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 1.0), ImVec4(x: 0.3882353007793427, y: 0.3882353007793427, z: 0.3882353007793427, w: 0.6200000047683716), ImVec4(x: 0.1372549086809158, y: 0.4392156898975372, z: 0.800000011920929, w: 0.7799999713897705), ImVec4(x: 0.1372549086809158, y: 0.4392156898975372, z: 0.800000011920929, w: 1.0), ImVec4(x: 0.3490196168422699, y: 0.3490196168422699, z: 0.3490196168422699, w: 0.1700000017881393), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.6700000166893005), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.949999988079071), ImVec4(x: 0.7607843279838562, y: 0.7960784435272217, z: 0.8352941274642944, w: 0.9309999942779541), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.800000011920929), ImVec4(x: 0.5921568870544434, y: 0.7254902124404907, z: 0.8823529481887817, w: 1.0), ImVec4(x: 0.9176470637321472, y: 0.9254902005195618, z: 0.9333333373069763, w: 0.9861999750137329), ImVec4(x: 0.7411764860153198, y: 0.8196078538894653, z: 0.9137254953384399, w: 1.0), ImVec4(x: 0.3882353007793427, y: 0.3882353007793427, z: 0.3882353007793427, w: 1.0), ImVec4(x: 1.0, y: 0.4274509847164154, z: 0.3490196168422699, w: 1.0), ImVec4(x: 0.8980392217636108, y: 0.6980392336845398, z: 0.0, w: 1.0), ImVec4(x: 1.0, y: 0.4470588266849518, z: 0.0, w: 1.0), ImVec4(x: 0.7764706015586853, y: 0.8666666746139526, z: 0.9764705896377563, w: 1.0), ImVec4(x: 0.5686274766921997, y: 0.5686274766921997, z: 0.6392157077789307, w: 1.0), ImVec4(x: 0.6784313917160034, y: 0.6784313917160034, z: 0.7372549176216125, w: 1.0), ImVec4(x: 0.0, y: 0.0, z: 0.0, w: 0.0), ImVec4(x: 0.2980392277240753, y: 0.2980392277240753, z: 0.2980392277240753, w: 0.09000000357627869), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.3499999940395355), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.949999988079071), ImVec4(x: 0.2588235437870026, y: 0.5882353186607361, z: 0.9764705896377563, w: 0.800000011920929), ImVec4(x: 0.6980392336845398, y: 0.6980392336845398, z: 0.6980392336845398, w: 0.699999988079071), ImVec4(x: 0.2000000029802322, y: 0.2000000029802322, z: 0.2000000029802322, w: 0.2000000029802322), ImVec4(x: 0.2000000029802322, y: 0.2000000029802322, z: 0.2000000029802322, w: 0.3499999940395355)])