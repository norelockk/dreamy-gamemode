local fonts = {
  ['bold'] = { size = 20, path = 'assets/fonts/bold.ttf' },
  ['bold_big'] = { size = 30, path = 'assets/fonts/bold.ttf' },
  ['bold_small'] = { size = 15, path = 'assets/fonts/bold.ttf' },
  ['light'] = { size = 20, path = 'assets/fonts/light.ttf' },
  ['light_big'] = { size = 30, path = 'assets/fonts/light.ttf' },
  ['light_small'] = { size = 15, path = 'assets/fonts/light.ttf' },
  ['medium'] = { size = 20, path = 'assets/fonts/medium.ttf' },
  ['medium_big'] = { size = 30, path = 'assets/fonts/medium.ttf' },
  ['medium_small'] = { size = 15, path = 'assets/fonts/medium.ttf' },
  ['regular'] = { size = 20, path = 'assets/fonts/regular.ttf' },
  ['regular_big'] = { size = 30, path = 'assets/fonts/regular.ttf' },
  ['regular_small'] = { size = 15, path = 'assets/fonts/regular.ttf' },
  ['semibold'] = { size = 20, path = 'assets/fonts/semibold.ttf' },
  ['semibold_big'] = { size = 30, path = 'assets/fonts/semibold.ttf' },
  ['semibold_small'] = { size = 15, path = 'assets/fonts/semibold.ttf' }
}

function getUIFont(font)
  return fonts[font] or 'default'
end

function registerFonts()
  for fontName, fontData in pairs(fonts) do
    if not isElement(fonts[fontName]) then
      if fileExists(fontData.path) then
        print('custom font registered', fontName)

        fonts[fontName] = dxCreateFont(fontData.path, fontData.size, false, 'antialiased')
      end
    end
  end
end

function unregisterFonts()
  for fontName, _ in pairs(fonts) do
    if isElement(fonts[fontName]) then
      destroyElement(fonts[fontName])
    end

    fonts[fontName] = nil
  end
end