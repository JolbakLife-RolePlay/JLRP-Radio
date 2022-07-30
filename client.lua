local radioMenu = false
local onRadio = false
local RadioChannel = 0
local RadioVolume = 50
local hasRadio = false
local radioProp = nil

--Function
local function LoadAnimDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
end

local function connecttoradio(channel)
    RadioChannel = channel
    if onRadio then
        exports["pma-voice"]:setRadioChannel(0)
    else
        onRadio = true
        exports["pma-voice"]:setVoiceProperty("radioEnabled", true)
    end
    exports["pma-voice"]:setRadioChannel(channel)
    Framework.ShowNotification(Config.messages['joined_to_radio'] ..channel.. ' MHz', 'success', 2000)
end

local function closeEvent()
	TriggerEvent("InteractSound_CL:PlayOnOne","click",0.6)
end

local function leaveradio()
	if not RadioChannel or RadioChannel == 0 then return end
    closeEvent()
    RadioChannel = 0
    onRadio = false
    exports["pma-voice"]:setRadioChannel(0)
    exports["pma-voice"]:setVoiceProperty("radioEnabled", false)
	Framework.ShowNotification(Config.messages['you_leave'], 'error', 2000)
end

local function toggleRadioAnimation(pState)
	LoadAnimDic("cellphone@")
	if pState then
		radioProp = CreateObject(`prop_cs_hand_radio`, 1.0, 1.0, 1.0, 1, 1, 0)
		AttachEntityToEntity(radioProp, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005), 0.14, 0.01, -0.02, 110.0, 120.0, -15.0, 1, 0, 0, 0, 2, 1)
		TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 3.5, 3.0, -1, 49, 0, 0, 0, 0)
	else
		StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0)
		if radioProp ~= 0 then
			Wait(500)
			DeleteObject(radioProp)
			radioProp = 0
		end
		
		local coordinatesOfHandBone = GetWorldPositionOfEntityBone(PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 57005))
		local radio = GetClosestObjectOfType(coordinatesOfHandBone, 0.2, `prop_cs_hand_radio`, false)
		if DoesEntityExist(radio) then
			Framework.Game.DeleteObject(radio)
			radioProp = 0
		end
	end
end

local function toggleRadio(toggle)
    radioMenu = toggle
    SetNuiFocus(radioMenu, radioMenu)
    if radioMenu then
        toggleRadioAnimation(true)
        SendNUIMessage({type = "open"})
    else
        toggleRadioAnimation(false)
        SendNUIMessage({type = "close"})
    end
end

local function IsRadioOn()
    return onRadio
end

local function DoRadioCheck()
    local _hasRadio = false
	
	local count = exports.ox_inventory:Search('count', 'radio')

    if count and count >= 1 then
		hasRadio = true
	else
		hasRadio = false
		if LocalPlayer.state.radioChannel and LocalPlayer.state.radioChannel ~= 0 then
			leaveradio()
		end
	end
end

--Exports
exports("IsRadioOn", IsRadioOn)

--Events

-- Handles state right when the player selects their character and location.
RegisterNetEvent('JLRP-Framework:onPlayerSpawn', function()
    DoRadioCheck()
	while not Framework.IsPlayerLoaded() do Wait(1000) end
	Framework.PlayerData = Framework.GetPlayerData()
end)

RegisterNetEvent('JLRP-Framework:onPlayerDeath', function()
	DoRadioCheck()
end)

-- Resets state on logout, in case of character change.
RegisterNetEvent('JLRP-Framework:onPlayerLogout', function()
	DoRadioCheck()
    leaveradio()
end)

RegisterNetEvent('ox_inventory:updateSlots')
AddEventHandler('ox_inventory:updateSlots', function(items, weights, count, removed)
	if count then
		local item = items[1].item
		if item.name == radio then
			Wait(1000)
			DoRadioCheck()
		end
	end
end)

-- Handles state when PlayerData is changed. We're just looking for inventory updates.
function OnPlayerData(key, val, last)
	if last then
		if key == 'job' then
			if Framework.PlayerData.job.name ~= last.name or (Framework.PlayerData.job.onDuty ~= last.onDuty and Config.RestrictedChannels[RadioChannel] ~= nil) then
				leaveradio()
			end
		elseif key == 'gang' then
			if Framework.PlayerData.gang.name ~= last.name then
				leaveradio()
			end
		end
	elseif key == 'weight' then
		Wait(1000)
		DoRadioCheck()
	end
end

-- Handles state if resource is restarted live.
AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        DoRadioCheck()
    end
end)

exports('radio', function(data, slot)
	exports['ox_inventory']:useItem(data, function(cb)
		-- The item has been used, so trigger the effects
		if cb then
			toggleRadio(not radioMenu)
		end
	end)
end)

RegisterNetEvent('JLRP-Radio:onRadioDrop', function()
    if RadioChannel ~= 0 then
        leaveradio()
    end
end)

-- NUI
RegisterNUICallback('joinRadio', function(data, cb)
	Framework.PlayerData = Framework.GetPlayerData()
    local rchannel = tonumber(data.channel) + 0.0
    if rchannel ~= nil then
        if rchannel <= Config.MaxFrequency and rchannel > 0 then
			
			local temp = tostring(rchannel):match("%.(%d+)")
			if temp ~= nil then
				local tempLength = string.len(temp)
				if tempLength > 2 then	
					Framework.ShowNotification(Config.messages['invalid_radio'], 'error', 2000)
					return
				end	
			end
			
            if rchannel ~= RadioChannel then
				local baseFrequency = math.floor(rchannel)
                if Config.RestrictedChannels[baseFrequency] ~= nil then
                    if Config.RestrictedChannels[baseFrequency][Framework.PlayerData.job.name] then
						if Framework.PlayerData.job.onDuty then
							connecttoradio(rchannel)
						else
							Framework.ShowNotification(Config.messages['onduty_channel_error'], 'error', 2000)
						end
                    else
						Framework.ShowNotification(Config.messages['restricted_channel_error'], 'error', 2000)
                    end
                else
                    connecttoradio(rchannel)
                end
            else
				Framework.ShowNotification(Config.messages['you_on_radio'], 'error', 2000)
            end
        else
			Framework.ShowNotification(Config.messages['invalid_radio'], 'error', 2000)
        end
    else
		Framework.ShowNotification(Config.messages['invalid_radio'], 'error', 2000)
    end
    cb("ok")
end)

RegisterNUICallback('leaveRadio', function(_, cb)
    if RadioChannel == 0 then
		Framework.ShowNotification(Config.messages['not_on_radio'], 'error', 2000)
    else
        leaveradio()
    end
    cb("ok")
end)

RegisterNUICallback("volumeUp", function(_, cb)
	if RadioVolume <= 95 then
		RadioVolume = RadioVolume + 5
		Framework.ShowNotification(Config.messages['volume_radio'] .. RadioVolume, 'success', 1000)
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		Framework.ShowNotification(Config.messages['decrease_radio_volume'], 'error', 2000)
	end
    cb('ok')
end)

RegisterNUICallback("volumeDown", function(_, cb)
	if RadioVolume >= 10 then
		RadioVolume = RadioVolume - 5
		Framework.ShowNotification(Config.messages['volume_radio'] .. RadioVolume, 'success', 1000)
		exports["pma-voice"]:setRadioVolume(RadioVolume)
	else
		Framework.ShowNotification(Config.messages['increase_radio_volume'], 'error', 2000)
	end
    cb('ok')
end)

RegisterNUICallback("increaseradiochannel", function(_, cb)
    RadioChannel = RadioChannel + 1
    exports["pma-voice"]:setRadioChannel(RadioChannel)
	Framework.ShowNotification(Config.messages['increase_decrease_radio_channel'] .. RadioChannel, 'success', 2000)
    cb("ok")
end)

RegisterNUICallback("decreaseradiochannel", function(_, cb)
    if not onRadio then return end
    RadioChannel = RadioChannel - 1
    if RadioChannel >= 1 then
        exports["pma-voice"]:setRadioChannel(RadioChannel)
        Framework.ShowNotification(Config.messages['increase_decrease_radio_channel'] .. RadioChannel, 'success', 2000)
        cb("ok")
    end
end)

RegisterNUICallback('poweredOff', function(_, cb)
    leaveradio()
    cb("ok")
end)

RegisterNUICallback('escape', function(_, cb)
    toggleRadio(false)
    cb("ok")
end)

