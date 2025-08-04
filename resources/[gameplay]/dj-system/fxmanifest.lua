fx_version 'cerulean'
game 'gta5'

author 'Antlin23'
description 'DJ System for FiveM Nightclubs'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/main.lua',
    'client/dj_booth.lua',
    'client/audio.lua'
}

server_scripts {
    'server/main.lua',
    'server/permissions.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/sounds/*.ogg'
}

dependencies {
    'mysql-async'
} 