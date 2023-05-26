addEventHandler('onClientResourceStart', resourceRoot, function()
  registerFonts()
  
  addEventHandler('onClientKey', root, changeEditbox)
  addEventHandler('onClientClick', root, onClientClickButton)
  addEventHandler('onClientCharacter', root, onEditboxType)

  print('ui lib initialized')
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
  unregisterFonts()

  removeEventHandler('onClientKey', root, changeEditbox)
  removeEventHandler('onClientClick', root, onClientClickButton)
  removeEventHandler('onClientCharacter', root, onEditboxType)

  print('ui lib uninitialized')
end)