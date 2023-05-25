addEventHandler('onClientResourceStart', resourceRoot, function()
  registerFonts()

  print('ui lib initialized')
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
  unregisterFonts()

  print('ui lib uninitialized')
end)