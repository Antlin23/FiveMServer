Config = {}

-- DJ Booth Locations (you can add more nightclub locations)
Config.DJBooths = {
    {
        name = "Bahama Mamas",
        coords = vector3(-1388.5, -586.2, 30.2),
        heading = 35.0,
        radius = 50.0, -- Music will be heard within this radius
        staffOnly = true,
        blip = {
            sprite = 136,
            color = 5,
            scale = 0.8,
            name = "DJ Booth - Bahama Mamas"
        }
    },
    {
        name = "Vanilla Unicorn",
        coords = vector3(127.5, -1284.5, 29.3),
        heading = 120.0,
        radius = 40.0,
        staffOnly = true,
        blip = {
            sprite = 136,
            color = 5,
            scale = 0.8,
            name = "DJ Booth - Vanilla Unicorn"
        }
    },
    {
        name = "Galaxy Nightclub",
        coords = vector3(126.5, -1284.5, 29.3),
        heading = 120.0,
        radius = 45.0,
        staffOnly = true,
        blip = {
            sprite = 136,
            color = 5,
            scale = 0.8,
            name = "DJ Booth - Galaxy"
        }
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