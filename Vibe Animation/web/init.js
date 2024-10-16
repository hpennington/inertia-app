(function() {
    console.log('Initializing Vibe: running web scripts')
    document.vibeDataModel = {
        isSelected: new Map(),
        actionableIds: new Array(),
        pointerEvents: new Map(),
        webKitUserSelect: new Map(),
        onWindowResize: null,
        animations: new Map(),
        isPlaying: false,
    }
    
    return true
})()
