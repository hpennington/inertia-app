(function() {
    const allElements = document.querySelectorAll('body *')
    
    let maxZIndex = 0
    
    for (const [index, value] of Object.entries(allElements)) {
        const id = `vibe-actionable-id-${index}`
        console.log({id})
        let element = value instanceof HTMLImageElement ? value.parentNode : value
        console.log({element})
        document.vibeDataModel.pointerEvents.set(id, window.getComputedStyle(element).pointerEvents)
        document.vibeDataModel.webKitUserSelect.set(id, window.getComputedStyle(element)['-webkit-user-select'])
        document.vibeDataModel.actionableIds.push(id)
        
        element.dataset.vibeActionableId = id
        element.style.pointerEvents = 'auto'
        element.style['-webkit-user-select'] = 'none'
        
        const zIndexValue = parseInt(window.getComputedStyle(element).zIndex) || 0
        if (zIndexValue > maxZIndex) {
            maxZIndex = zIndexValue
        }
    }
    
    const overlayId = 'pointer-overlay-id'
    const pointerOverlay = document.getElementById(overlayId) || document.createElement('div')
    pointerOverlay.id = overlayId
    pointerOverlay.style.position = 'fixed'
    pointerOverlay.style.top = 0
    pointerOverlay.style.left = 0
    pointerOverlay.style.height = `100%`
    pointerOverlay.style.width = `100%`
    pointerOverlay.style['pointer-events'] = 'auto'
    pointerOverlay.style['-webkit-user-select'] = 'none'
    
    document.vibeDataModel.onWindowResize = window.onresize
    
    window.onresize = function(e) {
        for (const id of document.vibeDataModel.actionableIds) {
            const targetElement = document.querySelector(`[data-vibe-actionable-id=${id}]`)
            const selectedBorderId = `selected-border-${id}`
            const selectedBorder = document.getElementById(selectedBorderId)
            
            if (selectedBorder) {
                const rect = targetElement.getBoundingClientRect()
                const x = rect.left + window.scrollX
                const y = rect.top + window.scrollY
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
            console.log(`on click vibeActionableId: ${id}`)
            const borderWidth = 3
            const zIndexValue = parseInt(window.getComputedStyle(targetElement).zIndex) || 0
            if (zIndexValue > maxZIndex) {
                maxZIndex = zIndexValue
                pointerOverlay.style['z-index']  = maxZIndex + 2
            }
            
            const selectedBorderId = `selected-border-${id}`
            console.log({selectedBorderId})
            const selectedBorder = document.getElementById(selectedBorderId) || document.createElement('div')
            
            selectedBorder.id = selectedBorderId
            selectedBorder.style.position = 'absolute'
            
            const rect = targetElement.getBoundingClientRect()
            const x = rect.left + window.scrollX
            const y = rect.top + window.scrollY
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
            selectedBorder.style.zIndex = maxZIndex + 2
            
            const isSelected = document.vibeDataModel.isSelected.get(id)
            
            if (isSelected) {
                selectedBorder.remove()
            } else {
                document.body.appendChild(selectedBorder)
            }

            document.vibeDataModel.isSelected.set(id, !isSelected)
        }
    }
    
    pointerOverlay.onclick = onClickHandler
    pointerOverlay.style.zIndex = maxZIndex + 2
    document.body.appendChild(pointerOverlay)
    
    return true
})()
