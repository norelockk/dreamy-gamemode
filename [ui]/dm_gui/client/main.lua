addEventHandler('onClientResourceStart', resourceRoot, function()
  registerFonts()
  
  addEventHandler('onClientKey', root, changeEditbox)
  addEventHandler('onClientKey', root, onClientClickList)
  addEventHandler('onClientCharacter', root, onEditboxType)

  addEventHandler('onClientClick', root, onClientClickButton)
  addEventHandler('onClientClick', root, onClientClickEditbox)
  addEventHandler('onClientClick', root, onClientClickCheckbox)

  print('ui lib initialized')
end)

addEventHandler('onClientResourceStop', resourceRoot, function()
  unregisterFonts()

  removeEventHandler('onClientKey', root, changeEditbox)
  removeEventHandler('onClientKey', root, onClientClickList)
  removeEventHandler('onClientCharacter', root, onEditboxType)

  removeEventHandler('onClientClick', root, onClientClickButton)
  removeEventHandler('onClientClick', root, onClientClickEditbox)
  removeEventHandler('onClientClick', root, onClientClickCheckbox)

  print('ui lib uninitialized')
end)