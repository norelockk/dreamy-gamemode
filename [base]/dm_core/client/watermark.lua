-- settings
local WATERMARK_ALPHA = 120
local WATERMARK_TOKEN = nil

-- vars
local screen = Vector2(guiGetScreenSize())
local info = getGamemodeInfo()

-- functions
local function generateToken(accountId, accountUsername)
  return teaEncode('dreamy_rp', base64Encode(string.format('%s:%s', accountUsername, accountId)))
end

-- rendering
addEventHandler("onClientRender", root, function()
  local logged = getElementData(localPlayer, 'player:logged')

  if logged then
    local playerId = getElementData(localPlayer, 'player:id')
    local accountId = getElementData(localPlayer, 'player:aid')
    local accountUsername = getElementData(localPlayer, 'player:username')

    if type(WATERMARK_TOKEN) == 'nil' then
      WATERMARK_TOKEN = generateToken(accountId, accountUsername)
    end

    dxDrawText(string.format('PID: %d | AID: %d\n%s', playerId, accountId, tostring(WATERMARK_TOKEN)), 0, 0, screen.x - 5, screen.y - 48, tocolor(255, 255, 255, WATERMARK_ALPHA), 1, "default-bold", "right", "bottom", false, false, true)
  end

  dxDrawText(string.format("%s v%s\n%s", info.NAME, string.format('%s-%s', info.VERSION, info.PRODUCTION and 'prod' or 'dev'), formatDate("W, d.m.Y")), 0, 0, screen.x - 5, screen.y - 16, tocolor(255, 255, 255, WATERMARK_ALPHA), 1, "default", "right", "bottom", false, false, true)
end)