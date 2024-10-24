(function() {
    for (const vibeActionableId of vibeDataModel.actionableIds) {
        const selectedBorderId = `selected-border-${vibeActionableId}`
        console.log({vibeActionableId})
        const targetElement = document.querySelector(`[data-vibeable-id=${vibeActionableId}]`)
        console.log({targetElement})
        const selectedBorderElement = document.getElementById(selectedBorderId)
        selectedBorderElement?.remove()
        if (targetElement) {
            targetElement.dataset.vibeActionableId = null
            targetElement.style.pointerEvents = 'auto'
            targetElement.style['-webkit-user-select'] = 'none'
        }
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
