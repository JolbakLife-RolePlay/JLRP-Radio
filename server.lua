do
	for channel, config in pairs(Config.RestrictedChannels) do
		local minFrequency, maxFrequency = channel, channel + 1
		for index = minFrequency, maxFrequency + 0.0, 0.01 do
			exports['pma-voice']:addChannelCheck(index, function(source)
				local xPlayer = Framework.GetPlayerFromId(source)
				local job = xPlayer.getJob()
				local cb = config[job.name] and job.onDuty
				print('mahan check => '..tostring(cb))
				return cb
			end)
		end
	end
end
