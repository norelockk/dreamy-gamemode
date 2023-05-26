function getGamePlayerMoney()
  return getPlayerMoney()
end

function giveGamePlayerMoney(money, isPremium)
  triggerServerEvent('core:onPlayerGiveMoney', resourceRoot, localPlayer, money, isPremium, getGamePlayerMoney())
end

function takeGamePlayerMoney(money)
  triggerServerEvent('core:onPlayerTakeMoney', resourceRoot, localPlayer, money, getGamePlayerMoney())
end
