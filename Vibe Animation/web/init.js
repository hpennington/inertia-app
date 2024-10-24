(function() {
    console.log('Initializing Vibe: running web scripts')
    window.vibeDataModel = {
        isSelected: new Map(),
        actionableIds: new Array(),
        pointerEvents: new Map(),
        webKitUserSelect: new Map(),
        onWindowResize: null,
        animations: new Map(),
        isPlaying: false,
        objects: new Map(),
    }
    
    return true
})()
