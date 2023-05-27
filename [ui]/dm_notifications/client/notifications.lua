-- IMPORTANT: this code & style was taken from San Andreas City project (2022)
-- TODO: total rework

local screen = Vector2(guiGetScreenSize())
local zoom = screen.x < 1920 and math.min(2, 1920 / screen.x) or 1

local function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
  dxDrawRectangle(x + radius, y + radius, width - (radius * 2), height - (radius * 2), color, postGUI, subPixelPositioning)
  dxDrawCircle(x + radius, y + radius, radius, 180, 270, color, color, 16, 1, postGUI)
  dxDrawCircle(x + radius, (y + height) - radius, radius, 90, 180, color, color, 16, 1, postGUI)
  dxDrawCircle((x + width) - radius, (y + height) - radius, radius, 0, 90, color, color, 16, 1, postGUI)
  dxDrawCircle((x + width) - radius, y + radius, radius, 270, 360, color, color, 16, 1, postGUI)
  dxDrawRectangle(x, y + radius, radius, height - (radius * 2), color, postGUI, subPixelPositioning)
  dxDrawRectangle(x + radius, y + height - radius, width - (radius * 2), radius, color, postGUI, subPixelPositioning)
  dxDrawRectangle(x + width - radius, y + radius, radius, height - (radius * 2), color, postGUI, subPixelPositioning)
  dxDrawRectangle(x + radius, y, width - (radius * 2), radius, color, postGUI, subPixelPositioning)
end

local notifications = {}
local notificationsPosition = Vector2(screen.x, 0)
local notificationsOffset = Vector2(65 / zoom, 45 / zoom)

notificationsPosition.y = screen.y - notificationsOffset.x

local defaultTime = 6 * 1000
local visible = 0

local font = {
  family = exports.dm_gui:getUIFont('regular'),
  scale = 1 / zoom
}

local function renderNotifications()
  visible = 0
  local hidden = 0

  for _, notification in pairs(notifications) do
    if notification.hidden then
      hidden = hidden + 1
    else
      visible = visible + 1

      local offsetY = notification.offsetY

      local messageTextWidth = dxGetTextWidth(notification.message, font.scale or 1, font.family or 'default-bold')
      local w = messageTextWidth + 20

      dxDrawRoundedRectangle((notificationsPosition.x - w) / 2, notificationsPosition.y - offsetY, w, notificationsOffset.y, 0, tocolor(0, 0, 0, 220 * notification.alphaProgress))
      dxDrawRoundedRectangle((notificationsPosition.x - w) / 2, notificationsPosition.y - offsetY + notificationsOffset.y - 1.2, notification.barProgress * w, 1.2, 0, tocolor(255, 255, 255, 255 * notification.alphaProgress))

      local x, y = (notificationsPosition.x - w) / 2, notificationsPosition.y - offsetY

      dxDrawText(notification.message, x, y, w + x, notificationsOffset.y + y, tocolor(255, 255, 255, 240 * notification.alphaProgress), font.scale or 1, font.family, 'center', 'center')
    end
  end

  if hidden == #notifications then
    notifications = {}
  end
end

local function deleteNotification(notificationId)
  local notification = notifications[notificationId]

  if notification then
    if notification.hidden then
      return
    end

    local currentProgress = notification.alphaProgress

    notification.animations.alpha = createAnimation(currentProgress, 0, 'InOutQuad', 400, function(p)
      notification.alphaProgress = p
    end, function()
      if visible > 0 then
        if notification.animations.offsetY then
          if notificationId ~= #notifications then
            finishAnimation(notification.animations.offsetY)
          end
        end

        for index = 1, #notifications do
          local n = notifications[notificationId - index]

          if n and not n.hidden then
            local offsetY = n.offsetY

            if offsetY == 0 then
              return
            end

            n.animations.offsetY = createAnimation(0, notificationsOffset.y * 1.13, 'InOutQuad', 240, function(p)
              n.offsetY = offsetY - p
            end)
          end
        end
      end

      notification.hidden = true
    end)

    return true
  end

  return false
end

local function createNotification(message, time)
  if not time or type(time) ~= 'number' then
    time = defaultTime
  end

  if message and type(message) == 'string' then
    table.insert(notifications, {
      message = message,
      time = time or defaultTime,
      hidden = false,
      animations = {},
      offsetY = 0,
      alphaProgress = 0,
      barProgress = 1
    })

    local id = #notifications

    if visible > 0 then
      for index, notification in ipairs(notifications) do
        if index ~= #notifications then
          finishAnimation(notification.animations.offsetY)
        end
      end

      for index, notification in ipairs(notifications) do
        if index < #notifications then
          local id = index
          local offsetY = notification.offsetY

          notification.animations.offsetY = createAnimation(0, notificationsOffset.y * 1.13, 'InOutQuad', 240, function(p)
            notifications[id].offsetY = offsetY + p
          end)
        end
      end
    end

    if not notifications[id].animations.alpha then
      local currentProgress = notifications[id].alphaProgress

      notifications[id].animations.alpha = createAnimation(currentProgress, 1, 'InOutQuad', 400, function(p)
        notifications[id].alphaProgress = p
      end)
    end

    if not notifications[id].animations.barWidth then
      local currentProgress = notifications[id].barProgress

      notifications[id].animations.barWidth = createAnimation(currentProgress, 0, 'Linear', time, function(p)
        notifications[id].barProgress = p
      end)
    end

    outputConsole(string.format('[Notyfikacja] %s', message))
    setTimer(deleteNotification, notifications[id].time or defaultTime, 1, id)
    playSound('assets/notification.ogg')

    return id
  end
end

local function start()
  addEventHandler('onClientRender', root, renderNotifications)
end

addEventHandler('onClientResourceStart', resourceRoot, start)

-- exports
function showNotification(...)
  return createNotification(...)
end

function destroyNotification(...)
  return deleteNotification(...)
end
