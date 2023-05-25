-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

-- vars
local fonts = {}
local sound = false
local gAlpha = 0
local showing = false
local textures = {}
local animations = {}
local interfaces = {}

-- functions
function renderUi()

end

function switchUi()
  if animations.gAlpha then return end

  local bindEvent = showing and removeEventHandler or addEventHandler

  if not showing then
    bindEvent('onClientRender', root, renderUi)

    if not animations.gAlpha then
      animations.gAlpha = createAnimation(gAlpha, 1, 'InOutQuad', 550,
        function(x)
          gAlpha = x
        end,
        function()
          deleteAnimation(animations.gAlpha)
          animations.gAlpha = false
        end
      )
    end
  else
    if not animations.gAlpha then
      animations.gAlpha = createAnimation(gAlpha, 0, 'InOutQuad', 550,
        function(x)
          gAlpha = x
        end,
        function()
          endCameraMovement()
          bindEvent('onClientRender', root, renderUi)

          deleteAnimation(animations.gAlpha)
          animations.gAlpha = false
        end
      )
    end
  end

  showing = not showing
end

function playLoginMusic()
  if not sound and not isElement(sound) then
    if fileExists('assets/sounds/isometric.mp3') then
      sound = playSound('assets/sounds/isometric.mp3', true)
    end
  end
end

function stopLoginMusic()
  if animations.sVolume then return end

  if sound and isElement(sound) then
    local currentVolume = getSoundVolume(sound)

    animations.sVolume = createAnimation(currentVolume, 0, 'Linear', 2000,
      function(volume)
        setSoundVolume(sound, volume)
      end,
      function()
        deleteAnimation(animations.sVolume)
        animations.sVolume = false

        stopSound(sound)
        sound = false
      end
    )
  end
end

local function stop()
  -- destroying textures
  for textureName, texture in pairs(textures) do
    if isElement(texture) then
      destroyElement(texture)
    end

    textures[textureName] = nil
  end

  -- disabling music
  stopLoginMusic()

  -- disabling camera
  endCameraMovement()
end

local function start()
  local logged = getElementData(localPlayer, 'player:logged')
  local spawned = getElementData(localPlayer, 'player:spawned')

  -- music
  playLoginMusic()

  -- check if player isn't already logged in or not spawned
  if logged then
    if not spawned then
      -- TODO: switch to start screen or spawn screen
    end

    return
  end

  -- switching ui
  switchUi()

  -- enabling camera
  fadeCamera(true)
  startCameraMovement()

  -- textures
  textures.logo = dxCreateTexture('assets/images/logo.png')

  -- handle disable event
  addEventHandler('onClientResourceStop', resourceRoot, stop)
end
addEventHandler('onClientResourceStart', resourceRoot, start)