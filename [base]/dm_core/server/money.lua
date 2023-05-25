local PREMIUM_MULTIPLIER = 1.1

function getGamePlayerMoney(player)
	if isElement(player) and getElementType(player) == 'player' then
		return getPlayerMoney(player)
	end
end

function giveGamePlayerMoney(player, money, isPremium, clientMoney)
	if isElement(player) and getElementType(player) == 'player' and type(money) == 'number' then
		local current = getPlayerMoney(player) or 0
		if type(clientMoney) == 'number' and clientMoney ~= current then 
			kickPlayer(player, 'Desynchronizacja pieniędzy')
			return
		end 
		
		if current == 0 and money > 0 then 
			-- exports.bnl_achievements:addPlayerAchievement(player, 'Pierwsza fucha')
		end 
		
		if isPremium then 
			isPremium = getElementData(player, 'player:premium')
		end 
		
		local mult = isPremium and PREMIUM_MULTIPLIER or 1
		local add_money = math.floor(current+(money*mult))
		setPlayerMoney(player, add_money)
		
		local bank_money = getElementData(player, 'player:bank_money') or 0
		local total_money = bank_money + add_money

		if total_money >= 10000 then
			-- exports.bnl_achievements:addPlayerAchievement(player, 'Biznesmen I')
		end

		if total_money >= 50000 then
			-- exports.bnl_achievements:addPlayerAchievement(player, 'Biznesmen II')
		end
		
		if total_money >= 100000 then
			-- exports.bnl_achievements:addPlayerAchievement(player, 'Biznesmen III')
		end
		
		if total_money >= 1000000 then
			-- exports.bnl_achievements:addPlayerAchievement(player, 'Milioner')
		end
		
		return true
	end
	
	return false
end

function takeGamePlayerMoney(player, money, clientMoney)
	if isElement(player) and getElementType(player) == 'player' and type(money) == 'number' and money > 0 then
		local current = getPlayerMoney(player) or 0
		if type(clientMoney) == 'number' and clientMoney ~= current then 
			kickPlayer(player, 'Desynchronizacja pieniędzy')
			return
		end 
		
		setPlayerMoney(player, math.floor(math.max(0, current-money)))
		return true
	end
	
	return false
end

addEvent('core:onPlayerTakeMoney', true)
addEvent('core:onPlayerGiveMoney', true)
addEventHandler('core:onPlayerTakeMoney', resourceRoot, takeGamePlayerMoney)
addEventHandler('core:onPlayerGiveMoney', resourceRoot, giveGamePlayerMoney)