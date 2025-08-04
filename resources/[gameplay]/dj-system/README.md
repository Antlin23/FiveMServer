# DJ System for FiveM

A comprehensive DJ system that allows staff members to play music in nightclubs with 3D positional audio.

## Features

- 🎵 **3D Positional Audio**: Music comes from DJ booths/speakers
- 👥 **Staff-Only Access**: Only authorized staff can control music
- 🎚️ **Easy Interface**: Beautiful web-based DJ menu
- 📍 **Multiple Locations**: Support for multiple nightclub locations
- ⏱️ **Auto-Stop**: Music automatically stops after track duration
- 🎮 **Keyboard Controls**: Quick access with keyboard shortcuts

## Installation

1. **Copy the Resource**: Place the `dj-system` folder in your `resources/[gameplay]/` directory

2. **Add to server.cfg**: Add this line to your `server.cfg`:
   ```
   ensure dj-system
   ```

3. **Database Setup**: Make sure your database has a `users` table with `identifier` and `role` columns. Staff roles should be: `admin`, `moderator`, or `dj`.

4. **Add Music Files**: Place your music files (`.ogg` format) in the `html/sounds/` directory and update the `Config.MusicTracks` in `config.lua`.

## Configuration

### DJ Booth Locations

Edit `config.lua` to add your nightclub locations:

```lua
Config.DJBooths = {
    {
        name = "Your Nightclub Name",
        coords = vector3(x, y, z), -- DJ booth coordinates
        heading = 0.0, -- Direction the booth faces
        radius = 50.0, -- Music range in meters
        staffOnly = true,
        blip = {
            sprite = 136,
            color = 5,
            scale = 0.8,
            name = "DJ Booth - Your Club"
        }
    }
}
```

### Music Tracks

Add your music tracks to the configuration:

```lua
Config.MusicTracks = {
    {
        name = "Your Track Name",
        file = "your_track.ogg", -- File in html/sounds/
        duration = 180 -- Duration in seconds
    }
}
```

### Staff Roles

Configure which roles can use the DJ system:

```lua
Config.StaffRoles = {
    "admin",
    "moderator", 
    "dj"
}
```

## Usage

### For Staff Members

1. **Go to a DJ Booth**: Visit any configured nightclub location
2. **Open Menu**: Press `E` when near the DJ booth
3. **Select Track**: Click on a track in the menu to play it
4. **Stop Music**: Press `BACKSPACE` or use the stop button in the menu

### For Players

- Music will automatically play when you're within range of an active DJ booth
- Volume decreases with distance from the booth
- Music stops when you leave the area

## Commands

- `/reloaddjstaff` - Reload the staff list from database (Admin only)
- `/djstatus` - Show active DJ sessions (Admin only)

## File Structure

```
dj-system/
├── fxmanifest.lua
├── config.lua
├── client/
│   ├── main.lua
│   ├── dj_booth.lua
│   └── audio.lua
├── server/
│   ├── main.lua
│   └── permissions.lua
├── html/
│   ├── index.html
│   ├── style.css
│   ├── script.js
│   └── sounds/
│       ├── electronic_beat.ogg
│       ├── hiphop_mix.ogg
│       └── ...
└── README.md
```

## Adding Music

1. Convert your music files to `.ogg` format
2. Place them in the `html/sounds/` directory
3. Add them to the `Config.MusicTracks` in `config.lua`
4. Restart the resource

## Troubleshooting

### Music Not Playing
- Check if the music files exist in `html/sounds/`
- Verify the file names match the configuration
- Ensure the DJ booth coordinates are correct

### Permission Issues
- Make sure the player has the correct role in the database
- Check if the role is listed in `Config.StaffRoles`
- Use `/reloaddjstaff` to refresh the staff list

### Audio Issues
- Verify the booth radius is appropriate for the location
- Check if other audio resources are conflicting
- Ensure the audio files are properly formatted

## Dependencies

- `mysql-async` - For database integration
- FiveM server with MySQL support

## Support

For issues or questions, check the configuration and ensure all dependencies are properly installed.

## License

This resource is provided as-is for FiveM server use. 