(function() {
    const vibeDataModel = document.vibeDataModel
    for (const vibeActionableId of vibeDataModel.actionableIds) {
        const selectedBorderId = `selected-border-${vibeActionableId}`
        console.log({vibeActionableId})
        const targetElement = document.querySelector(`[data-vibe-actionable-id=${vibeActionableId}]`)
        console.log({targetElement})
        const selectedBorderElement = document.getElementById(selectedBorderId)
        selectedBorderElement?.remove()
//        targetElement?.dataset.vibeActionableId = null
//        targetElement?.style.pointerEvents = vibeDataModel.pointerEvents.get(vibeActionableId)
//        targetElement?.style['-webkit-user-select'] = vibeDataModel.webKitUserSelect.get(vibeActionableId)
    }
    
    vibeDataModel.webKitUserSelect = new Set()
    vibeDataModel.pointerEvents = new Set()
    vibeDataModel.actionableIds = new Array()
    
    const overlayId = 'pointer-overlay-id'
    const pointerOverlayElement = document.getElementById(overlayId)
    pointerOverlayElement.remove()
    pointerOverlayElement.onclick = null
    
    window.onresize = vibeDataModel.onWindowResize
    
    return true
})()
