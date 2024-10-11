(function() {
    console.log('Executing vibe.js')
    document.vibeActionableDataModel = {
        isSelected: new Map(),
    }
    
    const allElements = document.querySelectorAll('*')
    
    let maxZIndex = 0

    const overlayId = 'overlay-element-id'
    const pointerOverlay = document.getElementById(overlayId) || document.createElement('div')
    pointerOverlay.id = overlayId
    pointerOverlay.style.position = 'fixed'
    pointerOverlay.style.top = 0
    pointerOverlay.style.left = 0
    pointerOverlay.style.height = `100%`
    pointerOverlay.style.width = `100%`
    pointerOverlay.style['pointer-events'] = 'auto'
    pointerOverlay.style['-webkit-user-select'] = 'none'
    
    for (const [index, element] of Object.entries(allElements)) {
        const id = `vibe-actionable-id-${index}`
        if (element instanceof HTMLImageElement) {
            let parent = element.parentNode
            parent.dataset.vibeActionableId = id
            parent.style.pointerEvents = 'auto'
            parent.style['-webkit-user-select'] = 'none'
            const zIndexValue = parseInt(window.getComputedStyle(parent).zIndex) || 0
            if (zIndexValue > maxZIndex) {
                maxZIndex = zIndexValue
            }
        } else {
            element.dataset.vibeActionableId = id
            element.style.pointerEvents = 'auto'
            element.style['-webkit-user-select'] = 'none'
            const zIndexValue = parseInt(window.getComputedStyle(element).zIndex) || 0
            if (zIndexValue > maxZIndex) {
                maxZIndex = zIndexValue
            }
        }
    }
    
    window.onresize = function(e) {
        // - TODO: Rethink this so that the ordering of the iterations is correct and that we don't miss elements
        for (const [index, element] of Object.entries(allElements)) {
            const id = `vibe-actionable-id-${index}`
            if (element.dataset.vibeActionableId == id) {
                const selectedBorderId = `selected-border-${id}`
                const selectedBorder = document.getElementById(selectedBorderId) ?? document.createElement('div')
                
                selectedBorder.id = selectedBorderId
                selectedBorder.style.position = 'absolute'
                
                const rect = element.getBoundingClientRect()
                const x = element.offsetLeft
                const y = element.offsetTop
                selectedBorder.style.left = `${x}px`
                selectedBorder.style.top = `${y}px`
                selectedBorder.style.width = `${rect.width}px`
                selectedBorder.style.height = `${rect.height}px`
            }
        }
    }
    
    function onClickHandler(e) {
        console.log({e})
        e.stopImmediatePropagation()
        
        pointerOverlay.style['pointer-events'] = 'none'
        let targetElement = document.elementFromPoint(e.clientX, e.clientY)
        
        if (targetElement instanceof HTMLImageElement) {
            targetElement = targetElement.parentNode
        }
        pointerOverlay.style['pointer-events'] = 'auto'
        
        const id = targetElement?.dataset.vibeActionableId
        if (id) {
            const borderWidth = 3
            const zIndexValue = parseInt(window.getComputedStyle(targetElement).zIndex) || 0
            if (zIndexValue > maxZIndex) {
                maxZIndex = zIndexValue
                pointerOverlay.style['z-index']  = maxZIndex + 2
            }
            
            const selectedBorderId = `selected-border-${id}`
            const selectedBorder = document.getElementById(selectedBorderId) ?? document.createElement('div')
            
            selectedBorder.id = selectedBorderId
            selectedBorder.style.position = 'absolute'
            
            const rect = targetElement.getBoundingClientRect()
            const x = targetElement.offsetLeft
            const y = targetElement.offsetTop
            selectedBorder.style.left = `${x}px`
            selectedBorder.style.top = `${y}px`
            selectedBorder.style.width = `${rect.width}px`
            selectedBorder.style.height = `${rect.height}px`
            selectedBorder.style.border = `${borderWidth}px solid`
            selectedBorder.style.borderColor = `rgb(85, 89, 220)`
            selectedBorder.style.borderRadius = '4px'
            selectedBorder.style['box-sizing'] = 'border-box'
            selectedBorder.style['pointer-events'] = 'none'
            selectedBorder.style['-webkit-user-select'] = 'none'
            selectedBorder.style.zIndex = targetElement.style.zIndex + 1
            
            const isSelected = document.vibeActionableDataModel.isSelected.get(id)
            
            if (isSelected) {
                selectedBorder.remove()
            } else {
                targetElement.appendChild(selectedBorder)
            }

            document.vibeActionableDataModel.isSelected.set(id, !isSelected)
        }
        
    }
    
    pointerOverlay.addEventListener('click', onClickHandler, true)
    pointerOverlay.style.zIndex = maxZIndex + 2
    document.body.appendChild(pointerOverlay)
    
    return true
})()
