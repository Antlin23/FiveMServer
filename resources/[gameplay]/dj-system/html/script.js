let currentTracks = [];
let currentBooth = '';
let audioElements = {};

// Listen for messages from the game
window.addEventListener('message', function(event) {
    const data = event.data;
    
    switch(data.type) {
        case 'openMenu':
            openMenu(data.tracks, data.boothName);
            break;
        case 'closeMenu':
            closeMenu();
            break;
        case 'playAudio':
            playAudio(data.boothName, data.trackName, data.boothCoords, data.radius);
            break;
        case 'stopAudio':
            stopAudio(data.boothName);
            break;
        case 'updateVolume':
            updateVolume(data.boothName, data.volume);
            break;
    }
});

function openMenu(tracks, boothName) {
    currentTracks = tracks;
    currentBooth = boothName;
    
    // Update booth name
    document.getElementById('booth-name').textContent = boothName;
    
    // Populate tracks
    const tracksContainer = document.getElementById('tracks-container');
    tracksContainer.innerHTML = '';
    
    tracks.forEach((track, index) => {
        const trackElement = document.createElement('div');
        trackElement.className = 'track-item';
        trackElement.innerHTML = `
            <div class="track-name">${track.name}</div>
            <div class="track-duration">Duration: ${formatDuration(track.duration)}</div>
        `;
        
        trackElement.addEventListener('click', () => {
            // Remove previous selection
            document.querySelectorAll('.track-item').forEach(item => {
                item.classList.remove('selected');
            });
            
            // Select this track
            trackElement.classList.add('selected');
            
            // Play the track
            playTrack(track.name);
        });
        
        tracksContainer.appendChild(trackElement);
    });
    
    // Show menu
    const menu = document.getElementById('dj-menu');
    menu.classList.add('show');
}

function closeMenu() {
    const menu = document.getElementById('dj-menu');
    menu.classList.remove('show');
    
    // Send close message to game
    fetch(`https://${GetParentResourceName()}/closeMenu`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    });
}

function playTrack(trackName) {
    // Send play message to game
    fetch(`https://${GetParentResourceName()}/playMusic`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            track: trackName
        })
    });
}

// HTML5 Audio Functions
function playAudio(boothName, trackName, boothCoords, radius) {
    // Stop existing audio for this booth
    if (audioElements[boothName]) {
        stopAudio(boothName);
    }
    
    // Create new audio element
    const audio = new Audio(`sounds/${trackName}`);
    audio.loop = true;
    audio.volume = 0.8;
    
    // Store audio element
    audioElements[boothName] = {
        element: audio,
        boothCoords: boothCoords,
        radius: radius
    };
    
    // Play audio
    audio.play().catch(error => {
        console.error('Error playing audio:', error);
        console.log('Audio file path:', `sounds/${trackName}`);
    });
    
    console.log(`Playing audio: ${trackName} at ${boothName}`);
}

function stopAudio(boothName) {
    if (audioElements[boothName]) {
        audioElements[boothName].element.pause();
        audioElements[boothName].element.currentTime = 0;
        delete audioElements[boothName];
        console.log(`Stopped audio at ${boothName}`);
    }
}

function updateVolume(boothName, volume) {
    if (audioElements[boothName]) {
        audioElements[boothName].element.volume = volume;
    }
}

function formatDuration(seconds) {
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
}

// Button event listeners
document.getElementById('stop-btn').addEventListener('click', function() {
    // Send stop message to game
    fetch(`https://${GetParentResourceName()}/stopMusic`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            booth: currentBooth
        })
    });
});

document.getElementById('close-btn').addEventListener('click', function() {
    closeMenu();
});

// Keyboard shortcuts
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        closeMenu();
    }
});

// Prevent context menu
document.addEventListener('contextmenu', function(event) {
    event.preventDefault();
});

// Debug function to test audio
function testAudio() {
    console.log('Testing audio playback...');
    const testAudio = new Audio('sounds/electronic_beat.ogg');
    testAudio.volume = 0.5;
    testAudio.play().then(() => {
        console.log('Audio test successful');
    }).catch(error => {
        console.error('Audio test failed:', error);
    });
}

// Auto-test audio on page load (for debugging)
window.addEventListener('load', function() {
    console.log('DJ System UI loaded');
    console.log('Available audio files:', ['electronic_beat.ogg', 'hiphop_mix.ogg', 'rock_anthem.ogg', 'chill_vibes.ogg']);
}); 