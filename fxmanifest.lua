fx_version 'cerulean'
use_fxv2_oal 'yes'
game 'gta5'
lua54 'yes'

name 'JLRP-Radio'
author 'Mahan Moulaei'
discord 'Mahan#8183'
description 'JolbakLifeRP Radio'

version '0.0'

shared_scripts {
	'@JLRP-Framework/imports.lua',
	'config.lua'
}

client_scripts {
	'client.lua'
}

server_scripts {
	'server.lua'
}

ui_page('html/ui.html')

files {'html/ui.html', 'html/js/script.js', 'html/css/style.css', 'html/img/cursor.png', 'html/img/radio.png'}