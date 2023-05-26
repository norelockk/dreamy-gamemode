addEventHandler('onClientResourceStart', resourceRoot, function()
  registerFonts()
  
  addEventHandler('onClientKey', root, changeEditbox)
  addEventHandler('onClientClick', root, onClientClickButton)
  addEventHandler('onClientClick', root, onClientClickEditbox)
  addEventHandler('onClientClick', root, onClientClickCheckbox)
  addEventHandler('onClientCharacter', root, onEditboxType)

  print('ui lib initialized')
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
  unregisterFonts()

  removeEventHandler('onClientKey', root, changeEditbox)
  removeEventHandler('onClientClick', root, onClientClickButton)
  removeEventHandler('onClientClick', root, onClientClickEditbox)
  removeEventHandler('onClientClick', root, onClientClickCheckbox)
  removeEventHandler('onClientCharacter', root, onEditboxType)

  print('ui lib uninitialized')
end)