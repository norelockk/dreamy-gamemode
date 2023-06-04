-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

-- min/max requirements
local DETAILS = {
  USERNAME = {
    MIN = 3,
    MAX = 24
  },
  PASSWORD = {
    MIN = 6,
    MAX = 32
  }
}

-- create screen
createUi = {}
createUi.data = {}
createUi.fonts = {}
createUi.buttons = {}
createUi.textures = {}
createUi.editboxes = {}
createUi.character = {}
createUi.animations = {}

local function createCharPreview(characterData)
  if not characterData then return end
  if createUi.character.model or isElement(createUi.character.model) then return end

  createUi.character.pos = Vector3(getCameraMatrix())
  createUi.character.model = createPed(characterData.skin, createUi.character.pos)

  createUi.character.preview = {}
  createUi.character.preview.main = exports['obj_preview']:createObjectPreview(createUi.character.model, 0, 0, 0, 1, 1, 1, 1)
  createUi.character.preview.window = guiCreateWindow(((screen.x - 600 / zoom) / 2) + 250 / zoom, (screen.y - 900 / zoom) / 2, 600 / zoom, 900 / zoom, 'Character preview', false, false)
  
  local sw, sh = guiGetSize(createUi.character.preview.window, true)
  local wx, wy = guiGetPosition(createUi.character.preview.window, true)

  guiSetAlpha(createUi.character.preview.window, 0)
  guiWindowSetSizable(createUi.character.preview.window, false)

  exports['obj_preview']:setAlpha(createUi.character.preview.main, 0)
  exports['obj_preview']:setRotation(createUi.character.preview.main, 0, 0, 180)
  exports['obj_preview']:setProjection(createUi.character.preview.main, wx, wy, sw, sh, true, true)
  
  setPedAnimation(createUi.character.model, 'rapping', 'rap_b_loop', -1, true, false)

  createUi.animations.characterAlpha = createAnimation(0, 255, 'InOutQuad', 600, function(x)
    exports['obj_preview']:setAlpha(createUi.character.preview.main, x)
  end, function()
    deleteAnimation(createUi.animations.characterAlpha)
    createUi.animations.characterAlpha = nil
  end)
end

local function destroyCurrentCharPreview(force)
  if createUi.animations.characterAlpha then return end
  if not createUi.character.model or not isElement(createUi.character.model) then return end

  if force then
    exports['obj_preview']:destroyObjectPreview(createUi.character.preview.main)
    destroyElement(createUi.character.preview.window)
    destroyElement(createUi.character.model)
    createUi.character = {}

    return
  end
  
  createUi.animations.characterAlpha = createAnimation(255, 0, 'InOutQuad', 600, function(x)
    exports['obj_preview']:setAlpha(createUi.character.preview.main, x)
  end, function()
    exports['obj_preview']:destroyObjectPreview(createUi.character.preview.main)

    deleteAnimation(createUi.animations.characterAlpha)
    createUi.animations.characterAlpha = nil

    destroyElement(createUi.character.preview.window)
    destroyElement(createUi.character.model)
    createUi.character = {}
  end)
end

createUi.init = function()
  -- create fonts
  createUi.fonts.regular_small = UI:getUIFont('regular_small')

  -- adjust button sizes & positions
  createUi.data.btnSize = Vector2(140 / zoom, 52 / zoom)
  createUi.data.btnPos = {}
  createUi.data.btnPos.back = Vector2(50 / zoom, 460 / zoom)

  -- create buttons
  createUi.buttons.back = UI:createButton(-createUi.data.btnPos.back.x, -createUi.data.btnPos.back.y, createUi.data.btnSize.x, createUi.data.btnSize.y, 'Wróć do wyboru', true)

  -- setup buttons
  UI:setButtonFont(createUi.buttons.back, createUi.fonts.regular_small, 0.95 / zoom)

  addEventHandler('gui:onClientClickButton', createUi.buttons.back, createUi.backToWelcome)
  addEventHandler('login:onClientResponse', resourceRoot, createUi.response)
  
  createCharPreview({ skin = 0 })
end

createUi.backToWelcome = function()
  triggerEvent('login:onClientSwitchInterface', resourceRoot, 'welcome')
  destroyCurrentCharPreview(false)
end

createUi.render = function(alpha, offset)
  for btn in pairs(createUi.buttons) do
    local button = createUi.buttons[btn]

    if button and isElement(button) then
      local offX = offset / zoom
      local x, y = createUi.data.btnPos[btn].x + offX, createUi.data.btnPos[btn].y

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, x, y)
    end
  end
end

createUi.destroy = function()
  removeEventHandler('login:onClientResponse', resourceRoot, createUi.response)

  for btn in pairs(createUi.buttons) do
    local button = createUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      createUi.buttons[button] = nil
    end
  end

  destroyCurrentCharPreview(false)
end

createUi.forceDestroy = function()
  for btn in pairs(createUi.buttons) do
    local button = createUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      createUi.buttons[button] = nil
    end
  end

  destroyCurrentCharPreview(true)
end

createUi.response = function(response)
  if response and response.type == 'register' then
    iprint('create client response', response)

    if response.success then
      print('success response')
    else
      print('error response', response.message)
    end
  end
end