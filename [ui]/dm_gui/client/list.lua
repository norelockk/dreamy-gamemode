addEvent('gui:onClientClickList', true)
addEvent('gui:onClientHoverList', true)

local screen = Vector2(guiGetScreenSize())
local zoom = 1920 / screen.x

local listID = 0
local activeList = false

local previousRow, previousRowData = nil, nil
local arrowSize = math.floor(50 / zoom)

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

function createList(textures, x, y, w, h)
  if textures and x and y and w and h then
    listID = listID + 1

    local _, rh = dxGetMaterialSize(textures.default)
    rh = math.floor(rh / zoom)
    local maxRows = math.floor(h / rh)

    local listData = {
      text = text,
      x = x,
      y = y,
      w = w,
      h = h,
      font = 'default-bold',
      fontSize = 1.0,
      alpha = 1,
      textures = textures,
      items = {},

      maxRows = maxRows,
      selectedRow = 1,
      visibleRows = maxRows
    }

    local el = createElement('list', 'list' .. tostring(listID))
    setElementData(el, 'data', listData, false)

    activeList = el

    return el
  end
end

function destroyList(list)
  if isElement(list) and getElementType(list) == 'list' then
    if list == activeList then
      activeList = false
    end

    destroyElement(list)
  end
end

function addListItem(list, item)
  if isElement(list) and getElementType(list) == 'list' and item then
    local data = getElementData(list, 'data')
    table.insert(data.items, item)
    setElementData(list, 'data', data, false)
  end
end

function setListFont(list, font, fontSize)
  if isElement(list) and getElementType(list) == 'list' and font and fontSize then
    local data = getElementData(list, 'data')
    data.font = font
    data.fontSize = fontSize
    setElementData(list, 'data', data, false)
  end
end

function setListAlpha(list, alpha)
  if isElement(list) and getElementType(list) == 'list' and alpha then
    local data = getElementData(list, 'data')
    data.alpha = alpha
    setElementData(list, 'data', data, false)
  end
end

function setListPosition(list, x, y)
  if isElement(list) and getElementType(list) == 'list' and x and y then
    local data = getElementData(list, 'data')
    data.x = x
    data.y = y
    setElementData(list, 'data', data, false)
  end
end

function getListSelectedItem(list)
  if isElement(list) and getElementType(list) == 'list' then
    local data = getElementData(list, 'data')

    local _, h = dxGetMaterialSize(data.textures.default)
    h = math.floor(h / zoom)

    local offsetY = 0
    for k, v in ipairs(data.items) do
      if k >= data.selectedRow and k <= data.visibleRows then
        if isCursorOnElement(data.x, data.y + offsetY, data.w, h) then
          return k, v
        end
        offsetY = offsetY + h
      end
    end

    return false
  end
end

function getListAllItemsCount(list)
  if isElement(list) and getElementType(list) == 'list' then
    local data = getElementData(list, 'data')

    return #data.items
  end
end

local function getListScrollValue(itemCount)
  return math.max(1, math.floor(itemCount * 0.075))
end

function renderList(list)
  if isElement(list) and getElementType(list) == 'list' then
    local data = getElementData(list, 'data')

    local offsetY = 0
    local _, h = dxGetMaterialSize(data.textures.default)
    h = math.floor(h / zoom)

    for k, v in ipairs(data.items) do
      if k >= data.selectedRow and k <= data.visibleRows then
        if isCursorOnElement(data.x, data.y + offsetY, data.w, h) then
          if previousRow ~= k then
            playHoverSound()
            triggerEvent('gui:onClientHoverList', list)
          end

          dxDrawImage(data.x, data.y + offsetY, data.w, h, data.textures.active, 0, 0, 0, tocolor(255, 255, 255, 255 * data.alpha))

          previousRow, previousRowData = k, {
            x = data.x,
            y = data.y + offsetY,
            w = data.w,
            h = h
          }
        else
          dxDrawImage(data.x, data.y + offsetY, data.w, h, data.textures.default, 0, 0, 0, tocolor(255, 255, 255, 255 * data.alpha))
        end

        dxDrawText(tostring(v), data.x + math.floor(20 / zoom), data.y + offsetY, data.w, data.y + offsetY + h, tocolor(255, 255, 255, 255 * data.alpha), data.fontSize, data.font, 'left', 'center')
        offsetY = offsetY + h
      end
    end
    if #data.items > data.maxRows then
      local upColor = data.selectedRow == 1 and {150, 150, 150} or {255, 255, 255}
      dxDrawImage(data.x + data.w + math.floor(5 / zoom) + 1, data.y + (data.h / 2) - arrowSize * 2.8 + 1, arrowSize, arrowSize, 'assets/images/up.png', 0, 0, 0, tocolor(0, 0, 0, 255 * data.alpha))
      dxDrawImage(data.x + data.w + math.floor(5 / zoom), data.y + data.h / 2 - arrowSize * 2.8, arrowSize, arrowSize, 'assets/images/up.png', 0, 0, 0, tocolor(upColor[1], upColor[2], upColor[3], 255 * data.alpha))

      local downColor = data.visibleRows == #data.items and {150, 150, 150} or {255, 255, 255}
      dxDrawImage(data.x + data.w + math.floor(5 / zoom) + 1, data.y + (data.h / 2) - arrowSize * 1.8 + 1, arrowSize, arrowSize, 'assets/images/down.png', 0, 0, 0, tocolor(0, 0, 0, 255 * data.alpha))
      dxDrawImage(data.x + data.w + math.floor(5 / zoom), data.y + data.h / 2 - arrowSize * 1.8, arrowSize, arrowSize, 'assets/images/down.png', 0, 0, 0, tocolor(downColor[1], downColor[2], downColor[3], 255 * data.alpha))
    end
  end
end

function onClientClickList(button, state)
  if button == 'mouse1' and state then
    if activeList then
      if isCursorOnElement(previousRowData.x, previousRowData.y, previousRowData.w, previousRowData.h) then
        triggerEvent('gui:onClientClickList', activeList)
        playClickSound()
      end
    end
  elseif button == 'mouse_wheel_down' then
    if activeList then
      local data = getElementData(activeList, 'data')
      local scrollValue = getListScrollValue(#data.items)
      local selectedRow, visibleRows = data.selectedRow, data.visibleRows

      if visibleRows >= #data.items then
        return
      end
      selectedRow = selectedRow + scrollValue
      visibleRows = visibleRows + scrollValue

      if visibleRows > #data.items then
        local diff = visibleRows - #data.items
        selectedRow = selectedRow - diff
        visibleRows = visibleRows - diff
      end

      data.selectedRow = selectedRow
      data.visibleRows = visibleRows
      setElementData(activeList, 'data', data, false)
    end
  elseif button == 'mouse_wheel_up' then
    if activeList then
      local data = getElementData(activeList, 'data')
      local scrollValue = getListScrollValue(#data.items)
      local selectedRow, visibleRows = data.selectedRow, data.visibleRows

      selectedRow = math.max(1, selectedRow - scrollValue)
      visibleRows = math.max(data.maxRows, visibleRows - scrollValue)

      data.selectedRow = selectedRow
      data.visibleRows = visibleRows
      setElementData(activeList, 'data', data, false)
    end
  end
end
