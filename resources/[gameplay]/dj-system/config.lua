Config = {}

-- DJ Booth Locations (you can add more nightclub locations)
Config.DJBooths = {
    {
        name = "Bahama Mamas",
        coords = vector3(-1382.4, -615.6, 31),
        heading = 35.0,
        radius = 20.0,
        staffOnly = true
    },
    {
        name = "Vanilla Unicorn",
        coords = vector3(127.5, -1284.5, 29.3),
        heading = 120.0,
        radius = 20.0,
        staffOnly = true
    },
    {
        name = "Galaxy Nightclub",
        coords = vector3(126.5, -1284.5, 29.3),
        heading = 120.0,
        radius = 22.0,
        staffOnly = true
    }
}

-- Staff roles that can use DJ system
Config.StaffRoles = {
    "admin",
    "moderator",
    "dj"
}

-- Music tracks (add your own music files to html/sounds/)
Config.MusicTracks = {
    {
        name = "Electronic Beat",
        file = "electronic_beat.ogg",
        duration = 180 -- seconds
    },
    {
        name = "Hip Hop Mix",
        file = "hiphop_mix.ogg", 
        duration = 240
    },
    {
        name = "Rock Anthem",
        file = "rock_anthem.ogg",
        duration = 200
    },
    {
        name = "Chill Vibes",
        file = "chill_vibes.ogg",
        duration = 300
    }
}

-- Controls
Config.Controls = {
    openMenu = 38, -- E key
    stopMusic = 177 -- BACKSPACE
}

-- Messages
Config.Messages = {
    noPermission = "You don't have permission to use the DJ system.",
    musicStarted = "Music started at %s",
    musicStopped = "Music stopped at %s",
    tooFar = "You need to be at a DJ booth to control music.",
    alreadyPlaying = "Music is already playing at this location."
} 