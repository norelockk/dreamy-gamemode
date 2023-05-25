addEventHandler('onClientResourceStart', resourceRoot, function()
  registerFonts()
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
  unregisterFonts()
end)