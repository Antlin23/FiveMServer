let currentTracks = [];
let currentBooth = '';
let audioElements = {};
let playerPosition = { x: 0, y: 0, z: 0 };

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
        case 'updatePlayerPosition':
            updatePlayerPosition(data.x, data.y, data.z);
            break;
        case 'updateAudioPosition':
            updateAudioPosition(data.boothName, data.boothCoords, data.radius);
            break;
        case 'testPanning':
            testPanning();
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

// 3D Audio Functions using Howler.js
function playAudio(boothName, trackName, boothCoords, radius) {
    // Stop existing audio for this booth
    if (audioElements[boothName]) {
        stopAudio(boothName);
    }
    
    // Create new Howl with 3D positional audio
    const sound = new Howl({
        src: [`sounds/${trackName}`],
        loop: true,
        volume: 0.8,
        html5: true, // Better for streaming
        onload: function() {
            console.log(`Loaded audio: ${trackName}`);
        },
        onloaderror: function(id, error) {
            console.error(`Error loading audio: ${trackName}`, error);
        },
        onplayerror: function(id, error) {
            console.error(`Error playing audio: ${trackName}`, error);
        }
    });
    
    // Store audio element with booth info
    audioElements[boothName] = {
        sound: sound,
        boothCoords: boothCoords,
        radius: radius,
        trackName: trackName
    };
    
    // Start playing
    sound.play();
    
    // Update 3D positioning immediately
    updateAudioPosition(boothName, boothCoords, radius);
    
    console.log(`Playing 3D audio: ${trackName} at ${boothName}`);
}

function stopAudio(boothName) {
    if (audioElements[boothName]) {
        audioElements[boothName].sound.stop();
        delete audioElements[boothName];
        console.log(`Stopped 3D audio at ${boothName}`);
    }
}

function updateVolume(boothName, volume) {
    if (audioElements[boothName]) {
        audioElements[boothName].sound.volume(volume);
    }
}

function updatePlayerPosition(x, y, z) {
    playerPosition = { x, y, z };
    
    // Update all active audio positions
    for (let boothName in audioElements) {
        const audio = audioElements[boothName];
        updateAudioPosition(boothName, audio.boothCoords, audio.radius);
    }
}

function updateAudioPosition(boothName, boothCoords, radius) {
    if (!audioElements[boothName]) return;
    
    const audio = audioElements[boothName];
    const sound = audio.sound;
    
    // Calculate distance from player to booth
    const distance = Math.sqrt(
        Math.pow(playerPosition.x - boothCoords.x, 2) +
        Math.pow(playerPosition.y - boothCoords.y, 2) +
        Math.pow(playerPosition.z - boothCoords.z, 2)
    );
    
    // Calculate volume with more aggressive dropoff for indoor spaces
    let volume = 0;
    if (distance <= radius) {
        // Use exponential decay for more realistic indoor audio
        const normalizedDistance = distance / radius;
        volume = Math.exp(-3 * normalizedDistance); // More aggressive dropoff
        volume = Math.max(0.05, volume); // Minimum volume of 5%
    }
    
    // Calculate stereo panning based on horizontal position
    const horizontalDistance = Math.sqrt(
        Math.pow(playerPosition.x - boothCoords.x, 2) +
        Math.pow(playerPosition.z - boothCoords.z, 2)
    );
    
    // Calculate angle from booth to player
    const angle = Math.atan2(
        playerPosition.z - boothCoords.z,
        playerPosition.x - boothCoords.x
    );
    
    // Convert angle to stereo panning (-1 = left, 0 = center, 1 = right)
    const pan = Math.sin(angle);
    
    // Apply volume and panning
    sound.volume(volume);
    sound.stereo(pan);
    
    // Debug info
    if (distance <= radius) {
        console.log(`${boothName}: Distance=${distance.toFixed(1)}m, Volume=${volume.toFixed(2)}, Pan=${pan.toFixed(2)}`);
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

// Debug function to test 3D audio
function test3DAudio() {
    console.log('Testing 3D audio...');
    const testSound = new Howl({
        src: ['sounds/electronic_beat.ogg'],
        loop: true,
        volume: 0.5,
        html5: true
    });
    
    testSound.play();
    
    // Simulate movement
    setTimeout(() => {
        testSound.stereo(-0.5); // Left side
        console.log('Audio panned left');
    }, 2000);
    
    setTimeout(() => {
        testSound.stereo(0.5); // Right side
        console.log('Audio panned right');
    }, 4000);
    
    setTimeout(() => {
        testSound.stereo(0); // Center
        console.log('Audio centered');
    }, 6000);
}

// Test panning function
function testPanning() {
    console.log('Testing stereo panning...');
    
    // Create a test sound if none exists
    if (!audioElements['test']) {
        const testSound = new Howl({
            src: ['sounds/electronic_beat.ogg'],
            loop: true,
            volume: 0.3,
            html5: true
        });
        
        audioElements['test'] = {
            sound: testSound,
            boothCoords: { x: 0, y: 0, z: 0 },
            radius: 50
        };
        
        testSound.play();
    }
    
    const sound = audioElements['test'].sound;
    
    // Test different panning positions
    const panTests = [
        { pan: -1.0, name: 'Far Left' },
        { pan: -0.5, name: 'Left' },
        { pan: 0.0, name: 'Center' },
        { pan: 0.5, name: 'Right' },
        { pan: 1.0, name: 'Far Right' }
    ];
    
    let testIndex = 0;
    
    const runPanTest = () => {
        if (testIndex < panTests.length) {
            const test = panTests[testIndex];
            sound.stereo(test.pan);
            console.log(`Panning: ${test.name} (${test.pan})`);
            testIndex++;
            setTimeout(runPanTest, 1000);
        } else {
            console.log('Panning test complete');
            sound.stereo(0); // Return to center
        }
    };
    
    runPanTest();
}

// Auto-test on page load (for debugging)
window.addEventListener('load', function() {
    console.log('DJ System 3D Audio loaded');
    console.log('Available audio files:', ['electronic_beat.ogg', 'hiphop_mix.ogg', 'rock_anthem.ogg', 'chill_vibes.ogg']);
    console.log('Howler.js version:', Howler.version);
}); 