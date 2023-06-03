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

-- welcome screen
welcomeUi = {}
welcomeUi.data = {}
welcomeUi.fonts = {}
welcomeUi.loading = true
welcomeUi.buttons = {}
welcomeUi.textures = {}
welcomeUi.animations = {}
welcomeUi.characters = {}

local loadingRot = 0

local function noCharactersInit()
  welcomeUi.data.btnPos.create = Vector2(140 / zoom, 580 / zoom)

  -- register buttons
  welcomeUi.buttons.create = UI:createButton(-welcomeUi.data.btnPos.create.x, -welcomeUi.data.btnPos.create.y, welcomeUi.data.btnSize.x, welcomeUi.data.btnSize.y, 'Załóż postać', true)

  -- setup buttons
  for btn in pairs(welcomeUi.buttons) do
    local button = welcomeUi.buttons[btn]

    if button and isElement(button) then
      UI:setButtonAlpha(button, 0)
      UI:setButtonFont(button, welcomeUi.fonts.regular, 0.95 / zoom)
    end
  end

  addEventHandler('gui:onClientClickButton', welcomeUi.buttons.create, function()
    triggerEvent('login:onClientSwitchInterface', resourceRoot, 'createCharacter')
  end)
end

welcomeUi.init = function()
  -- register fonts
  welcomeUi.fonts.semibold_big = UI:getUIFont('semibold_big')
  welcomeUi.fonts.regular = UI:getUIFont('regular')

  -- register textures
  welcomeUi.textures.loading = dxCreateTexture('assets/images/ui/loading.png')
  welcomeUi.textures.sadface = dxCreateTexture('assets/images/ui/sadface.png')

  -- adjust button sizes & positions
  welcomeUi.data.btnPos = {}
  welcomeUi.data.btnSize = Vector2(160 / zoom, 52 / zoom)

  addEventHandler('login:onClientResponse', resourceRoot, welcomeUi.response)
  setTimer(triggerServerEvent, 1500, 1, 'login:sendRequest', resourceRoot, 'getPlayerCharacters')
end

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
end

welcomeUi.response = function(response)
  if response and response.type == 'welcome' and welcomeUi.loading then
    iprint('welcome client response', response)

    if response.success then
      if #response.characters == 0 then
        noCharactersInit()
        print('no characters')
      end
    else
      print('error response', response.message)
    end

    welcomeUi.loading = not welcomeUi.loading
  end
end