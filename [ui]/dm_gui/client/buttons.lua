local screenW, screenH = guiGetScreenSize()

-- hover animation vars
local min_hover = 0.85
local max_hover = 1
local hover_animation_duration = 150

-- sounds
local function playHoverSound()
  if fileExists('assets/sounds/hover.ogg') then
    local sound = playSound("assets/sounds/hover.ogg", false)
    setSoundVolume(sound, 0.7)
  end
end 

local function playClickSound()
  if fileExists('assets/sounds/click.ogg') then
    local sound = playSound("assets/sounds/click.ogg", false)
    setSoundVolume(sound, 1)
  end
end 

-- variables
local active_button = false
local buttons_alpha = {}
local clicked_button = false
local buttons_animations = {}
local prev_active_button = false

-- events
addEvent('gui:onClientClickButton', true)
addEvent('gui:onClientHoverButton', true)

-- local functions
local function isCursorInPosition(x, y, w, h)
  if not isCursorShowing() then
    return false
  end

	local mouseX, mouseY = getCursorPosition()
	local cursorX, cursorY = mouseX * screenW, mouseY * screenH

	return cursorX > x and cursorX < x + w and cursorY > y and cursorY < y + h
end

-- https://wiki.multitheftauto.com/wiki/DxDrawLinedRectangle
local function dxDrawLinedRectangle( x, y, width, height, color, _width, postGUI )
	_width = _width or 1

	dxDrawLine(x, y, x+width, y, color, _width, postGUI) -- Top
	dxDrawLine(x, y, x, y+height, color, _width, postGUI) -- Left
	dxDrawLine(x, y+height, x+width, y+height, color, _width, postGUI) -- Bottom
	dxDrawLine(x+width, y, x+width, y+height, color, _width, postGUI) -- Right
end

-- functions
function createButton(x, y, w, h, text, enableRipples)
  if x and y and w and h and text then
    -- create button element
    local element = createElement('button')

    if element then
      -- set in element memory a button data
      setElementData(element, 'data', {
        x = x,
        y = y,
        w = w,
        h = h,
        text = text,
        font = 'default-bold',
        alpha = min_hover,
        target = type(enableRipples) == 'boolean' and enableRipples and dxCreateRenderTarget(w, h, true) or false,
        enabled = true,
        ripples = {},
        font_size = 1,
        global_alpha = 1,
      }, false)

      -- set up animations n stuff
      buttons_alpha[element] = min_hover
      buttons_animations[element] = {}
    end

    -- return button element
    return element
  end
end

function destroyButton(button)
  if isElement(button) and getElementType(button) == 'button' then
    destroyElement(button)

    if buttons_animations[button] and buttons_alpha[button] then
      buttons_alpha[button] = nil
      buttons_animations[button] = nil
    end
  end
end

function getButtonSize(button)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    return button_data.w, button_data.h
  end  
end

function getButtonPosition(button)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    return button_data.x, button_data.y
  end
end

function isButtonEnabled(button)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    return button_data.enabled
  end 
end

function isButtonHovered(button)
  return active_button == button
end

function isButtonClicked(button)
  return clicked_button == button
end

function setButtonFont(button, font, fontSize)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    if button_data then
      button_data.font = font
      button_data.font_size = fontSize

      setElementData(button, 'data', button_data, false)
    end
  end
end

function setButtonSize(button, w, h)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    if button_data then
      if w and h then
        button_data.w = w
        button_data.h = h
      end

      setElementData(button, 'data', button_data, false)
    end
  end
end

function setButtonAlpha(button, alpha)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    if button_data then
      button_data.global_alpha = alpha

      setElementData(button, 'data', button_data, false)
    end
  end
end

function setButtonEnabled(button, state)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    if button_data then
      button_data.enabled = state

      setElementData(button, 'data', button_data, false)
    end
  end
end

function setButtonPosition(button, x, y)
  if isElement(button) and getElementType(button) == 'button' then
    local button_data = getElementData(button, 'data')

    if button_data then
      if x and y then
        button_data.x = x
        button_data.y = y
      end

      setElementData(button, 'data', button_data, false)
    end
  end
end

function onClientClickButton(button, state)
  if not isCursorShowing() then return end

  if button == 'left' then
    if state == 'up' then
      if isElement(clicked_button) then
        local data = getElementData(clicked_button, 'data')

        if data then
          if isCursorInPosition(data.x, data.y, data.w, data.h) then
            if data.target then
              if #data.ripples > 0 then
                for _, ripple in ipairs(data.ripples) do
                  if ripple.btn == clicked_button and ripple.hold then
                    ripple.hold = false

                    setElementData(clicked_button, 'data', data, false)
                  end
                end
              end
            end

            playClickSound()

            triggerEvent('gui:onClientClickButton', clicked_button)

            clicked_button = false
          else
            active_button = false
            clicked_button = false
          end
        end
      end
    elseif state == 'down' then
      if isElement(active_button) then
        local data = getElementData(active_button, 'data')

        if data then
          if isCursorInPosition(data.x, data.y, data.w, data.h) then
            clicked_button = active_button

            if data.target then
              local cursorX, cursorY = getCursorPosition()
              cursorX, cursorY = cursorX * screenW, cursorY * screenH

              table.insert(data.ripples, {
                cspeed = 0.0032,
                speed = 0.0032,
                alpha = 200,
                size = 5,
                hold = true,
                btn = clicked_button,
                x = cursorX - data.x,
                y = cursorY - data.y,
              })

              setElementData(clicked_button, 'data', data, false)
            end
          else
            active_button = false
            clicked_button = false
          end
        end
      end
    end
  end
end

local function renderAllButtons()
  local cursorX, cursorY = isCursorShowing() and getCursorPosition() or 0, 0
  cursorX, cursorY = cursorX * screenW, cursorY * screenH

  for _, button in ipairs(getElementsByType('button')) do
    local data = getElementData(button, 'data')

    if isCursorInPosition(data.x, data.y, data.w, data.h) and data.enabled then
      active_button = button

      if active_button ~= prev_active_button then
        playHoverSound()

        triggerEvent('gui:onClientHoverButton', button)
      end

      prev_active_button = button
    else
      if active_button == button then
        if buttons_animations[button]['hover'] then
          buttons_animations[button]['hover'] = createAnimation(buttons_alpha[button], min_hover, 'InOutQuad', hover_animation_duration,
            function(progress)
              if buttons_alpha[button] then
                buttons_alpha[button] = progress
              end
            end,
            function()
              deleteAnimation(buttons_animations[button]['hover'])
              buttons_animations[button]['hover'] = nil
            end
          )
        end

        active_button = false
        prev_active_button = false
      end
    end

    if active_button == button then
      if buttons_animations[button] then
        if not data.enabled then return end

        if not buttons_animations[button]['hover'] then
          buttons_animations[button]['hover'] = createAnimation(buttons_alpha[button], max_hover, 'InOutQuad', hover_animation_duration,
            function(progress)
              if buttons_alpha[button] then
                buttons_alpha[button] = progress
              end
            end
          )
        end
      end
    end 

    local alpha = 255 * buttons_alpha[button] * data.global_alpha

    dxDrawRectangle(data.x, data.y, data.w, data.h, tocolor(0, 0, 0, alpha * 0.90), true)

    -- ripple effect (thanks to borsuk for help)
    if data.target then
      dxSetRenderTarget(data.target, true)
        for rindex, ripple in ipairs(data.ripples) do
          if ripple then
            dxDrawCircle(ripple.x, ripple.y, ripple.size, 0, 360, tocolor(255, 255, 255, ripple.alpha), tocolor(255, 255, 255, ripple.alpha))

            ripple.cspeed = ripple.cspeed + (ripple.speed - ripple.cspeed) * 0.30
            ripple.size = ripple.size + (data.w * 2 - ripple.size) * ripple.cspeed

            if not ripple.hold then
              ripple.alpha = ripple.alpha + (0 - ripple.alpha) * ripple.cspeed / 0.145

              if ripple.alpha <= 2 then
                table.remove(data.ripples, rindex)
              end
            end

            setElementData(button, 'data', data, false)
          end
        end
      dxSetRenderTarget()

      dxDrawImage(data.x, data.y, data.w, data.h, data.target, 0, 0, 0, tocolor(190, 190, 190, alpha), true)
    end

    -- dxDrawLinedRectangle(data.x, data.y, data.w, data.h, tocolor(92, 92, 92, alpha), 1, true)
    dxDrawText(data.text, data.x, data.y, data.x + data.w, data.y + data.h, tocolor(255, 255, 255, alpha), data.font_size, data.font, 'center', 'center', false, false, true)
  end
end
addEventHandler('onClientRender', root, renderAllButtons)

-- setTimer(function()
--   showCursor(true)
--   local button = createButton((screenW - 160) / 2, (screenH - 40) / 2, 160, 40, 'button alpha test', true)
--   -- setButtonEnabled(button, false)
--   setButtonFont(button, getUIFont('medium'), 0.76)
-- end, 3000, 1)