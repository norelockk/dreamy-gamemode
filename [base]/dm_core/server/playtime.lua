addEvent('core:onPlayerUpdatePlaytime', true)
addEventHandler('core:onPlayerUpdatePlaytime', resourceRoot, function(playtime, session)
	setElementData(client, 'player:play_time', playtime, false)
	setElementData(client, 'player:session_time', session, false)
end)