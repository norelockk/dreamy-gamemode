-- check if player isn't already logged in or not spawned
local logged = getElementData(localPlayer, 'player:logged')
local spawned = getElementData(localPlayer, 'character:spawned')
if logged and spawned then return end

-- screen size n' zooming
local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

-- ui
local UI = exports.dm_gui

-- event listeners
addEvent('login:onClientResponse', true)
addEvent('login:onClientSwitchUi', true)
addEvent('login:onClientSwitchInterface', true)

-- vars
local fonts = {}
local sound = false
local gAlpha = 0
local showing = false
local changing = false
local offsetX = -300
local textures = {}
local animations = {}
local interfaces = {}
local sidebarWidth = 0
local interfaceAlpha = 0
local activeInterface = nil

-- functions
local function playWooshSound()
  if fileExists('assets/sounds/ui/woosh.ogg') then
    local sound = playSound('assets/sounds/ui/woosh.ogg')

    setSoundVolume(sound, 0.25)
    setSoundSpeed(sound, 1.65)
  end
end

local function animateInterface(mode, callback)
  if not mode or not type(mode) == 'string' then return end

  switch(mode).case('in', function()
    animations.interfaceOffsetX = createAnimation(offsetX, 0, 'InOutQuad', 600, function(x)
      offsetX = x
    end, function()
      if callback and type(callback) == 'function' then
        callback()
      end

      deleteAnimation(animations.interfaceOffsetX)
      animations.interfaceOffsetX = false
    end)

    animations.interfaceAlpha = createAnimation(interfaceAlpha, 1, 'InOutQuad', 600, function(x)
      interfaceAlpha = x
    end, function()
      deleteAnimation(animations.interfaceAlpha)
      animations.interfaceAlpha = false
    end)

    playWooshSound()
  end).case('out', function()
    animations.interfaceOffsetX = createAnimation(offsetX, -300, 'InOutQuad', 600, function(x)
      offsetX = x
    end, function()
      if callback and type(callback) == 'function' then
        callback()
      end

      deleteAnimation(animations.interfaceOffsetX)
      animations.interfaceOffsetX = false
    end)

    animations.interfaceAlpha = createAnimation(interfaceAlpha, 0, 'InOutQuad', 600, function(x)
      interfaceAlpha = x
    end, function()
      deleteAnimation(animations.interfaceAlpha)
      animations.interfaceAlpha = false
    end)
  end).default(function()
    print('unknown mode')
  end).process()
end

local function initializeCurrentInterface()
  local currentUi = interfaces[activeInterface]
  if not currentUi then
    return
  end

  if currentUi.init then
    currentUi.init()
  end
end

local function destroyCurrentInterface()
  local currentUi = interfaces[activeInterface]
  if not currentUi then
    return
  end

  if currentUi.destroy then
    currentUi.destroy()
  end
end

local function drawCurrentInterface()
  local currentUi = interfaces[activeInterface]
  if not currentUi then
    return
  end

  if currentUi then
    dxDrawText(currentUi.title, 50 / zoom + (offsetX / zoom), 150 / zoom, 50 / zoom + (offsetX / zoom), 0, tocolor(12, 12, 12, 255 * gAlpha * interfaceAlpha), 1.05 / zoom, fonts.semibold_big)

    if currentUi.description then
      dxDrawText(currentUi.description, 50 / zoom + (offsetX / zoom), 200 / zoom, 50 / zoom + (offsetX / zoom), 0, tocolor(12, 12, 12, 255 * gAlpha * interfaceAlpha), 0.85 / zoom, fonts.light)
    end

    if currentUi.render then
      currentUi.render(gAlpha * interfaceAlpha, offsetX)
    end
  end
end

local function switchInterface(name)
  if activeInterface == name then return end
  if changing then return end

  changing = true

  if name == 'none' then
    animateInterface('out', function()
      destroyCurrentInterface()
      activeInterface = nil
      changing = false
    end)
    return
  end

  if not interfaces[name] then return end

  if activeInterface == nil then
    activeInterface = name
    initializeCurrentInterface()
    animateInterface('in', function()
      changing = false
    end)

    return
  end

  if activeInterface ~= name then
    animateInterface('out', function()
      destroyCurrentInterface()

      activeInterface = name
      initializeCurrentInterface()
      animateInterface('in', function()
        changing = false
      end)
    end)
  end
end
addEventHandler('login:onClientSwitchInterface', resourceRoot, switchInterface)

-- kick drum detection
local kickThreshold = 0.152
local kickDetected = false
local kickCooldown = 400
local lastKickTime = 0
local lightAlpha = 0

local function renderLightData()
  -- debug
  -- local offsetX = 30
  -- dxDrawRectangle(350 + (id * offsetX), 50, 10, -fftData[id] * 40, tocolor(255, 255, 255, 255))
  -- dxDrawText(tostring(id), 350 + (id * offsetX), 50)
  -- dxDrawText(string.format('%.1f', fftData[id], 5), 360 + (id * offsetX), 30)

  if isElement(sound) and sound then
    local fftData = getSoundFFTData(sound, 4096, 32)

    local amplitudeSum = 0
    for id = 1, #fftData do
      amplitudeSum = amplitudeSum + fftData[id]
    end

    local averageAm = amplitudeSum / #fftData
    local averageAmplitude = fftData[4]

    if averageAmplitude > kickThreshold then
      local currentTime = getTickCount()

      if currentTime - lastKickTime >= kickCooldown then
        kickDetected = true
        lastKickTime = currentTime
      end
    else
      kickDetected = false
    end
  end

  if kickDetected then
    animations.kickAlpha = createAnimation(1, 0, 'Linear', 1500, function(a)
      lightAlpha = a
    end, function()
      deleteAnimation(animations.kickAlpha)
      animations.kickAlpha = nil
    end)
  end
end

local function drawMusicLight()
  renderLightData()

  dxDrawImage(0, 0, screen.x, screen.y, textures.light, 0, 0, 0, tocolor(255, 255, 255, 255 * lightAlpha))
end

local function renderUi()
  if isChatVisible() then showChat(false) end

  -- draw 'sidebar'
  dxDrawRectangle(0, 0, (sidebarWidth / zoom), screen.y, tocolor(255, 255, 255, 255 * gAlpha))

  -- draw logo
  dxDrawImage(35 / zoom + ((sidebarWidth - 450) / zoom), 50 / zoom, 296 / zoom, 72 / zoom, textures.logo, 0, 0, 0, tocolor(255, 255, 255, 255 * gAlpha))

  -- draw interface
  drawMusicLight()
  drawCurrentInterface()
end

local function switchUi()
  local logged = getElementData(localPlayer, 'player:logged')
  local spawned = getElementData(localPlayer, 'character:spawned')
  local bindEvent = showing and removeEventHandler or addEventHandler
  local ui_SwitchLogic = not logged and 'login' or not spawned and 'welcome' or ''

  if not showing then
    bindEvent('onClientRender', root, renderUi)

    if not animations.gAlpha and not animations.sidebarWidth then
      animations.gAlpha = createAnimation(gAlpha, 1, 'InOutQuad', 800, function(x)
        gAlpha = x
      end, function()
        deleteAnimation(animations.gAlpha)
        animations.gAlpha = false
      end)

      animations.sidebarWidth = createAnimation(sidebarWidth, 450, 'InOutQuad', 900, function(w)
        sidebarWidth = w
      end, function()
        switchInterface(ui_SwitchLogic)

        deleteAnimation(animations.sidebarWidth)
        animations.sidebarWidth = false
      end)
    end
  else
    switchInterface('none')
    endCameraMovement()

    if not animations.gAlpha and not animations.sidebarWidth then
      animations.gAlpha = createAnimation(gAlpha, 0, 'InOutQuad', 800, function(x)
        gAlpha = x
      end, function()
        stopLoginMusic()
        bindEvent('onClientRender', root, renderUi)

        deleteAnimation(animations.gAlpha)
        animations.gAlpha = false
      end)

      animations.sidebarWidth = createAnimation(sidebarWidth, 0, 'InOutQuad', 900, function(w)
        sidebarWidth = w
      end, function()
        deleteAnimation(animations.sidebarWidth)
        animations.sidebarWidth = false
      end)
    end
  end

  showing = not showing
end
addEventHandler('login:onClientSwitchUi', resourceRoot, switchUi)

local function stop()
  -- destroying textures
  for texture in ipairs(textures) do
    local t = textures[texture]

    if t and isElement(t) then
      destroyElement(t)
    end

    textures[texture] = nil
  end

  -- destroying current interface
  destroyCurrentInterface()

  -- disabling music
  stopLoginMusic()

  -- disabling camera
  endCameraMovement()
end

local function start()
  -- initialize textures
  textures.logo = dxCreateTexture('assets/images/logo.png')
  textures.light = dxCreateTexture('assets/images/light.png')

  -- music
  playLoginMusic()
  sound = getLoginMusicElement()

  -- initialize uis
  interfaces.login = {}
  interfaces.welcome = {}
  interfaces.register = {}

  interfaces.login.init = loginUi.init
  interfaces.login.title = "Logowanie"
  interfaces.login.render = loginUi.render
  interfaces.login.destroy = loginUi.destroy

  interfaces.welcome.init = welcomeUi.init
  interfaces.welcome.title = string.format('Witaj, %s!', getPlayerName(localPlayer))
  interfaces.welcome.description = [[Wybierz z poniższej listy lokalizację,
w której byś chciał zostać zespawnowany]]
  interfaces.welcome.render = welcomeUi.render
  interfaces.welcome.destroy = welcomeUi.destroy

  interfaces.register.init = registerUi.init
  interfaces.register.title = "Rejestracja"
  interfaces.register.render = registerUi.render
  interfaces.register.destroy = registerUi.destroy

  -- setup fonts
  fonts.semibold_big = UI:getUIFont('semibold_big')
  fonts.light = UI:getUIFont('light')

  -- switching ui
  switchUi()
  showCursor(true)

  -- enabling camera
  fadeCamera(false)
  startCameraMovement()

  -- handle disable event
  addEventHandler('onClientResourceStop', resourceRoot, stop)
end
addEventHandler('onClientResourceStart', resourceRoot, start)