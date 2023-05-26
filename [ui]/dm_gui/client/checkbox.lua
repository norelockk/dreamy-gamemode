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
local active_Checkbox = false
local Checkboxes_alpha = {}
local clicked_Checkbox = false
local Checkboxes_animations = {}
local prev_active_Checkbox = false

-- events
addEvent('gui:onClientClickCheckbox', true)
addEvent('gui:onClientHoverCheckbox', true)

-- local functions
local function isCursorInPosition(x, y, w, h)
  if not isCursorShowing() then
    return false
  end

	local mouseX, mouseY = getCursorPosition()
	local cursorX, cursorY = mouseX * screenW, mouseY * screenH

	return cursorX > x and cursorX < x + w and cursorY > y and cursorY < y + h
end

-- functions
function createCheckbox(x, y, w, h, text, checked)
  if x and y and w and h and text then
    if not checked then
      checked = false
    end

    -- create Checkbox element
    local element = createElement('Checkbox')

    if element then
      -- set in element memory a Checkbox data
      setElementData(element, 'data', {
        x = x,
        y = y,
        w = w,
        h = h,
        text = text,
        font = 'default-bold',
        alpha = min_hover,
        enabled = true,
        ripples = {},
        font_size = 1,
        global_alpha = 1,
        checked = checked
      }, false)

      -- set up animations n stuff
      Checkboxes_alpha[element] = min_hover
      Checkboxes_animations[element] = {}
    end

    -- return Checkbox element
    return element
  end
end

function destroyCheckbox(Checkbox)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    destroyElement(Checkbox)

    if Checkboxes_animations[Checkbox] and Checkboxes_alpha[Checkbox] then
      Checkboxes_alpha[Checkbox] = nil
      Checkboxes_animations[Checkbox] = nil
    end
  end
end

function getCheckboxSize(Checkbox)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    return Checkbox_data.w, Checkbox_data.h
  end  
end

function getCheckboxPosition(Checkbox)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    return Checkbox_data.x, Checkbox_data.y
  end
end

function isCheckboxEnabled(Checkbox)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    return Checkbox_data.enabled
  end 
end

function isCheckboxChecked(Checkbox)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    return Checkbox_data.checked
  end 
end

function isCheckboxHovered(Checkbox)
  return active_Checkbox == Checkbox
end

function isCheckboxClicked(Checkbox)
  return clicked_Checkbox == Checkbox
end

function setCheckboxFont(Checkbox, font, fontSize)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      Checkbox_data.font = font
      Checkbox_data.font_size = fontSize

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function setCheckboxChecked(Checkbox, state)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      Checkbox_data.checked = state

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function setCheckboxSize(Checkbox, w, h)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      if w and h then
        Checkbox_data.w = w
        Checkbox_data.h = h
      end

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function setCheckboxAlpha(Checkbox, alpha)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      Checkbox_data.global_alpha = alpha

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function setCheckboxEnabled(Checkbox, state)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      Checkbox_data.enabled = state

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function setCheckboxPosition(Checkbox, x, y)
  if isElement(Checkbox) and getElementType(Checkbox) == 'Checkbox' then
    local Checkbox_data = getElementData(Checkbox, 'data')

    if Checkbox_data then
      if x and y then
        Checkbox_data.x = x
        Checkbox_data.y = y
      end

      setElementData(Checkbox, 'data', Checkbox_data, false)
    end
  end
end

function onClientClickCheckbox(button, state)
  if not isCursorShowing() then return end

  if button == 'left' then
    if state == 'up' then
      if isElement(clicked_Checkbox) then
        local data = getElementData(clicked_Checkbox, 'data')

        if data then
          if isCursorInPosition(data.x, data.y, data.w, data.h) then
            data.checked = not data.checked
            setElementData(clicked_Checkbox, 'data', data, false)

            playClickSound()

            triggerEvent('gui:onClientClickCheckbox', clicked_Checkbox)

            clicked_Checkbox = false
          else
            active_Checkbox = false
            clicked_Checkbox = false
          end
        end
      end
    elseif state == 'down' then
      if isElement(active_Checkbox) then
        local data = getElementData(active_Checkbox, 'data')

        if data then
          if isCursorInPosition(data.x, data.y, data.w, data.h) then
            clicked_Checkbox = active_Checkbox
          else
            active_Checkbox = false
            clicked_Checkbox = false
          end
        end
      end
    end
  end
end

local function renderAllCheckboxes()
  local cursorX, cursorY = isCursorShowing() and getCursorPosition() or 0, 0
  cursorX, cursorY = cursorX * screenW, cursorY * screenH

  for _, Checkbox in ipairs(getElementsByType('Checkbox')) do
    local data = getElementData(Checkbox, 'data')

    if isCursorInPosition(data.x, data.y, data.w, data.h) and data.enabled then
      active_Checkbox = Checkbox

      if active_Checkbox ~= prev_active_Checkbox then
        playHoverSound()

        triggerEvent('gui:onClientHoverCheckbox', Checkbox)
      end

      prev_active_Checkbox = Checkbox
    else
      if active_Checkbox == Checkbox then
        if Checkboxes_animations[Checkbox]['hover'] then
          Checkboxes_animations[Checkbox]['hover'] = createAnimation(Checkboxes_alpha[Checkbox], min_hover, 'InOutQuad', hover_animation_duration,
            function(progress)
              if Checkboxes_alpha[Checkbox] then
                Checkboxes_alpha[Checkbox] = progress
              end
            end,
            function()
              deleteAnimation(Checkboxes_animations[Checkbox]['hover'])
              Checkboxes_animations[Checkbox]['hover'] = nil
            end
          )
        end

        active_Checkbox = false
        prev_active_Checkbox = false
      end
    end

    if active_Checkbox == Checkbox then
      if Checkboxes_animations[Checkbox] then
        if not data.enabled then return end

        if not Checkboxes_animations[Checkbox]['hover'] then
          Checkboxes_animations[Checkbox]['hover'] = createAnimation(Checkboxes_alpha[Checkbox], max_hover, 'InOutQuad', hover_animation_duration,
            function(progress)
              if Checkboxes_alpha[Checkbox] then
                Checkboxes_alpha[Checkbox] = progress
              end
            end
          )
        end
      end
    end 

    local alpha = 255 * Checkboxes_alpha[Checkbox] * data.global_alpha

    dxDrawRectangle(data.x, data.y, data.w, data.h, tocolor(0, 0, 0, alpha * 0.90), true)

    if data.checked then
      local w, h = data.w - 10, data.h - 10

      dxDrawRectangle((data.x + data.w) - data.w + 5, (data.y + data.h) - data.h + 5, w, h, tocolor(100, 100, 100, alpha * 0.75), true)
    end

    -- dxDrawText(data.text, data.x, data.y, data.x + data.w, data.y + data.h, tocolor(255, 255, 255, alpha), data.font_size, data.font, 'center', 'center', false, false, true)
    dxDrawText(data.text, data.x + data.w + 5, data.y + 3.4, 0, 0, tocolor(0, 0, 0, alpha), data.font_size, data.font, 'left', 'top', false, false, true)
  end
end
addEventHandler('onClientRender', root, renderAllCheckboxes)