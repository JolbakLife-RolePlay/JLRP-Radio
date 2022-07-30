Config = {}

Config.RestrictedChannels = {
    [0] = {
        jolbak = true
    },
	[1] = {
        police = true
    },
    [2] = {
        ambulance = true
    },
    [3] = {
        fbi = true
    },
    [4] = {
        sheriff = true
    },
    [5] = {
        police = false,
        ambulance = false
    },
    [6] = {
        police = false,
        ambulance = false
    },
    [7] = {
        police = false,
        ambulance = false
    },
    [8] = {
        police = false,
        ambulance = false
    },
    [9] = {
        police = false,
        ambulance = false
    },
    [10] = {
        police = false,
        ambulance = true
    }
}

Config.MaxFrequency = 100

Config.messages = {
    ["not_on_radio"] = "You're not connected to a signal",
    ["on_radio"] = "You're already connected to this signal",
    ["joined_to_radio"] = "You're connected to: ",
    ["restricted_channel_error"] = "You can not connect to this encrypted signal!",
	["onduty_channel_error"] = "You can not connect to this signal while you are not on duty!",
    ["invalid_radio"] = "This frequency is not available.",
    ["you_on_radio"] = "You're already connected to this channel",
    ["you_leave"] = "You left the channel.",
    ['volume_radio'] = 'New volume ',
    ['decrease_radio_volume'] = 'The radio is already set to maximum volume',
    ['increase_radio_volume'] = 'The radio is already set to the lowest volume',
    ['increase_decrease_radio_channel'] = 'New channel ',
}
