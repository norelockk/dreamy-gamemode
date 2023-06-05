-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

-- welcome screen
welcomeUi = {}
welcomeUi.data = {}
welcomeUi.fonts = {}
welcomeUi.loading = true
welcomeUi.buttons = {}
welcomeUi.textures = {}
welcomeUi.character = {}
welcomeUi.animations = {}

local changes = false
local dataAlpha = 0
local loadingRot = 0

local function createCharPreview(characterData)
  if not characterData then return end
  if welcomeUi.character.model or isElement(welcomeUi.character.model) then return end
  if changes then return end

  changes = true

  welcomeUi.character.pos = Vector3(getCameraMatrix())
  welcomeUi.character.data = characterData
  welcomeUi.character.model = createPed(characterData.skin, welcomeUi.character.pos)

  welcomeUi.character.preview = {}
  welcomeUi.character.preview.main = exports['obj_preview']:createObjectPreview(welcomeUi.character.model, 0, 0, 0, 1, 1, 1, 1)
  welcomeUi.character.preview.window = guiCreateWindow(((screen.x - 600 / zoom) / 2) + 650 / zoom, (screen.y - 900 / zoom) / 2, 600 / zoom, 900 / zoom, 'Character preview', false, false)
  
  local sw, sh = guiGetSize(welcomeUi.character.preview.window, true)
  local wx, wy = guiGetPosition(welcomeUi.character.preview.window, true)

  guiSetAlpha(welcomeUi.character.preview.window, 0)
  guiWindowSetSizable(welcomeUi.character.preview.window, false)

  exports['obj_preview']:setAlpha(welcomeUi.character.preview.main, 0)
  exports['obj_preview']:setRotation(welcomeUi.character.preview.main, 0, 0, 180)
  exports['obj_preview']:setProjection(welcomeUi.character.preview.main, wx, wy, sw, sh, true, true)
  
  setPedAnimation(welcomeUi.character.model, 'rapping', 'rap_b_loop', -1, true, false)

  welcomeUi.animations.dataAlpha = createAnimation(dataAlpha, 1, 'InOutQuad', 600, function(x)
    dataAlpha = x
  end, function()
    deleteAnimation(welcomeUi.animations.dataAlpha)
    welcomeUi.animations.dataAlpha = nil

    changes = false
  end)

  welcomeUi.animations.characterAlpha = createAnimation(0, 255, 'InOutQuad', 600, function(x)
    exports['obj_preview']:setAlpha(welcomeUi.character.preview.main, x)
  end, function()
    deleteAnimation(welcomeUi.animations.characterAlpha)
    welcomeUi.animations.characterAlpha = nil
  end)
end

local function destroyCurrentCharPreview(force, callback)
  if welcomeUi.animations.characterAlpha then return end
  if not welcomeUi.character.model or not isElement(welcomeUi.character.model) then return end
  if changes then return end

  changes = true

  welcomeUi.animations.dataAlpha = createAnimation(dataAlpha, 0, 'InOutQuad', 600, function(x)
    dataAlpha = x
  end, function()
    deleteAnimation(welcomeUi.animations.dataAlpha)
    welcomeUi.animations.dataAlpha = nil

    changes = false
  end)

  if force then
    exports['obj_preview']:destroyObjectPreview(welcomeUi.character.preview.main)
    destroyElement(welcomeUi.character.preview.window)
    destroyElement(welcomeUi.character.model)
    welcomeUi.character = {}

    if callback and type(callback) == 'function' then
      callback()
    end

    return
  end
  
  welcomeUi.animations.characterAlpha = createAnimation(255, 0, 'InOutQuad', 600, function(x)
    exports['obj_preview']:setAlpha(welcomeUi.character.preview.main, x)
  end, function()
    exports['obj_preview']:destroyObjectPreview(welcomeUi.character.preview.main)

    deleteAnimation(welcomeUi.animations.characterAlpha)
    welcomeUi.animations.characterAlpha = nil

    destroyElement(welcomeUi.character.preview.window)
    destroyElement(welcomeUi.character.model)
    welcomeUi.character = {}

    if callback and type(callback) == 'function' then
      callback()
    end 
  end)
end

local function charactersInit(characters)
  welcomeUi.characters = characters

  welcomeUi.list = UI:createList({
    active = welcomeUi.textures.list_active,
    default = welcomeUi.textures.list_default
  }, -500 / zoom, 300 / zoom, 360 / zoom, 850 / zoom)
  UI:setListFont(welcomeUi.list, welcomeUi.fonts.regular, 1 / zoom)

  if welcomeUi.list and isElement(welcomeUi.list) then
    for index, character in ipairs(welcomeUi.characters) do
      if character.dead == 1 then return end

      UI:addListItem(welcomeUi.list, string.format('%s %s', character.firstName, character.lastName))
    end

    -- check character limit
    local limit = #welcomeUi.characters >= 3
    if not limit then
      UI:addListItem(welcomeUi.list, '+ Stwórz kolejną postać')
    end

    addEventHandler('gui:onClientClickList', welcomeUi.list, welcomeUi.onListClick)
  end
end

local function noCharactersInit()
  welcomeUi.characters = {}

  welcomeUi.data.btnPos.create = Vector2(140 / zoom, 580 / zoom)

  -- register buttons
  welcomeUi.buttons.create = UI:createButton(-welcomeUi.data.btnPos.create.x, -welcomeUi.data.btnPos.create.y, welcomeUi.data.btnSize.x, welcomeUi.data.btnSize.y, 'Stwórz postać', true)

  -- setup buttons
  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonAlpha(button, 0)
      UI:setButtonFont(button, welcomeUi.fonts.regular, 0.95 / zoom)
    end
  end

  addEventHandler('gui:onClientClickButton', welcomeUi.buttons.create, function()
    destroyCurrentCharPreview(false)
    triggerEvent('login:onClientSwitchInterface', resourceRoot, 'createCharacter')
  end)
end

welcomeUi.init = function()
  -- register fonts
  welcomeUi.fonts.semibold_big = UI:getUIFont('semibold_big')
  welcomeUi.fonts.regular = UI:getUIFont('regular')
  welcomeUi.fonts.light = UI:getUIFont('light')

  -- register textures
  welcomeUi.textures.loading = dxCreateTexture('assets/images/ui/loading.png')
  welcomeUi.textures.sadface = dxCreateTexture('assets/images/ui/sadface.png')
  welcomeUi.textures.list_active = dxCreateTexture('assets/images/ui/list_active.png')
  welcomeUi.textures.list_default = dxCreateTexture('assets/images/ui/list_default.png')

  -- adjust button sizes & positions
  welcomeUi.data.btnPos = {}
  welcomeUi.data.btnSize = Vector2(160 / zoom, 52 / zoom)

  addEventHandler('login:onClientResponse', resourceRoot, welcomeUi.response)
  setTimer(triggerServerEvent, 1500, 1, 'login:sendRequest', resourceRoot, 'getPlayerCharacters')
end

welcomeUi.onListClick = function()
  if changes then return end

  local selected = UI:getListSelectedItem(welcomeUi.list)
  local allItems = UI:getListAllItemsCount(welcomeUi.list)

  if selected == allItems then
    destroyCurrentCharPreview(false)
    triggerEvent('login:onClientSwitchInterface', resourceRoot, 'createCharacter')

    return
  end

  local characterSelected = welcomeUi.characters[selected]
  if not characterSelected then return end

  if not welcomeUi.character.data then
    createCharPreview(characterSelected)
    return
  end

  if welcomeUi.character.data ~= characterSelected then
    destroyCurrentCharPreview(false, function()
      createCharPreview(characterSelected)
    end)
  end
end

local ignoreProperties = {
  ['updatedAt'] = true,
  ['skin'] = true,
  ['bw'] = true,
  ['ownerId'] = true,
  ['jail'] = true,
  ['dead'] = true,
}

local translationProperties = {
  ['id'] = 'Identyfikator postaci',
  ['gender'] = 'Płeć postaci',
  ['firstName'] = 'Imię postaci',
  ['lastName'] = 'Nazwisko postaci',
  ['class'] = 'Klasa postaci',
  ['growth'] = 'Wysokość postaci',
  ['weight'] = 'Waga postaci',
  ['age'] = 'Wiek postaci',
  ['createdAt'] = 'Data utworzenia postaci',
  ['health'] = 'Stan życia postaci'
}

local translationValues = {
  ['id'] = '%d',
  ['age'] = '%d lat',
  ['class'] = {
    ['ENGINEER'] = 'Inżynier',
    ['GANGSTER'] = 'Gangster',
    ['LAW_OFFICER'] = 'Stróż prawa',
    ['ENTREPRENEUR'] = 'Biznesman'
  },
  ['health'] = '%d%%',
  ['growth'] = '%d cm',
  ['weight'] = '%d kg',
  ['gender'] = {
    ['MALE'] = 'Mężczyzna',
    ['FEMALE'] = 'Kobieta'
  },
  ['lastName'] = '%s',
  ['firstName'] = '%s',
  ['createdAt'] = '%s',
}

welcomeUi.render = function(alpha, offset)
  local offX = offset / zoom

  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      local x, y = welcomeUi.data.btnPos[btn].x + offX, welcomeUi.data.btnPos[btn].y

      UI:setButtonAlpha(button, alpha)
      UI:setButtonPosition(button, x, y)
    end
  end

  if welcomeUi.loading then
    loadingRot = loadingRot - 10

    dxDrawImage(190 / zoom + offX, 440 / zoom, 65 / zoom, 65 / zoom, welcomeUi.textures.loading, loadingRot, 0, 0, tocolor(0, 0, 0, 255 * alpha))
  else
    if #welcomeUi.characters == 0 and not welcomeUi.list then
      dxDrawText('Brak postaci', 125 / zoom + offX, 505 / zoom, 125 / zoom + offX, 0, tocolor(12, 12, 12, 255 * alpha), 1 / zoom, welcomeUi.fonts.semibold_big)
      dxDrawImage(190 / zoom + offX, 440 / zoom, 65 / zoom, 65 / zoom, welcomeUi.textures.sadface, 0, 0, 0, tocolor(0, 0, 0, 255 * alpha))

      return
    end

    if not welcomeUi.character.data then
      dxDrawText('Wybierz postać, którą będziesz odgrywał rolę', 745 / zoom, ((screen.y - 900 / zoom) / 2) + 400 / zoom, 525 / zoom, 0, tocolor(250, 250, 250, 255 * alpha), 1.3 / zoom, welcomeUi.fonts.semibold_big)
    else
      local offsetY = 0

      dxDrawText(string.format('%s %s', welcomeUi.character.data.firstName, welcomeUi.character.data.lastName), 705 / zoom, ((screen.y - 900 / zoom) / 2) + 170 / zoom, 525 / zoom, 0, tocolor(250, 250, 250, 255 * alpha * dataAlpha), 1.25 / zoom, welcomeUi.fonts.semibold_big)

      for key, value in pairs(welcomeUi.character.data) do
        if not ignoreProperties[key] then
          local y = ((screen.y - 900 / zoom) / 2) + 270 / zoom + offsetY
          local translatedValue = (key == 'class' or key == 'gender') and translationValues[key][value] or string.format(translationValues[key] or 'TODO', value)

          dxDrawText(string.format('%s:', translationProperties[key] or key), 705 / zoom, y, 525 / zoom, 0, tocolor(250, 250, 250, 255 * alpha * dataAlpha), 1 / zoom, welcomeUi.fonts.light)
          dxDrawText(translatedValue, 1020 / zoom, y, 525 / zoom, 0, tocolor(250, 250, 250, 255 * alpha * dataAlpha), 1 / zoom, welcomeUi.fonts.regular)

          offsetY = offsetY + 35 / zoom
        end
      end
    end

    UI:renderList(welcomeUi.list)
    UI:setListAlpha(welcomeUi.list, alpha)
    UI:setListPosition(welcomeUi.list, 50 / zoom + offX, 300 / zoom)
  end
end

welcomeUi.destroy = function()
  removeEventHandler('login:onClientResponse', resourceRoot, welcomeUi.response)

  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      welcomeUi.buttons[button] = nil
    end
  end

  for texture in pairs(welcomeUi.textures) do
    local txt = welcomeUi.textures[texture]

    if txt and isElement(txt) then
      destroyElement(txt)
    end

    welcomeUi.textures[texture] = nil
  end
  
  if welcomeUi.list then
    removeEventHandler('gui:onClientClickList', welcomeUi.list, welcomeUi.onListClick)
    UI:destroyList(welcomeUi.list)

    welcomeUi.list = nil
  end

  destroyCurrentCharPreview(false)
  welcomeUi.loading = not welcomeUi.loading
end

welcomeUi.forceDestroy = function()
  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      UI:destroyButton(button)

      welcomeUi.buttons[button] = nil
    end
  end

  if welcomeUi.list then
    removeEventHandler('gui:onClientClickList', welcomeUi.list, welcomeUi.onListClick)
    UI:destroyList(welcomeUi.list)

    welcomeUi.list = nil
  end

  destroyCurrentCharPreview(true)
end

welcomeUi.response = function(response)
  if response and response.type == 'welcome' then
    if welcomeUi.loading then
      welcomeUi.loading = not welcomeUi.loading
    end

    if response.success then
      if #response.characters == 0 then
        noCharactersInit()
        return
      end

      charactersInit(response.characters)
    else
      print('error response', response.message)
    end
  end
end