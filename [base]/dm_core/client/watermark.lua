local screen = Vector2(guiGetScreenSize())
local info = getGamemodeInfo()

addEventHandler("onClientRender", root, function()
  dxDrawText(string.format("%s v%s - %s", info.NAME, string.format('%s-%s', info.VERSION, info.PRODUCTION and 'prod' or 'dev'), formatDate("W, d.m.Y")), 0, 0, screen.x - 5, screen.y - 13, tocolor(255, 255, 255, 120), 1, "default", "right", "bottom", false, false, true)
end)