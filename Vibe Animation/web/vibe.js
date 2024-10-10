(function() {
//    const getOverlayElement = (id) => {
//        const overlayElement = document.getElementById(id) ?? document.createElement('div')
//        return overlayElement
//    }
    
    document.vibeActionableDataModel = {
        isSelected: new Map(),
    }
    
    const allElements = document.querySelectorAll('*')
    
    let maxZIndex = 0

    const overlayElement = document.createElement('div')
    overlayElement.style.position = 'absolute'
    overlayElement.style.top = 0
    overlayElement.style.left = 0
    overlayElement.style.height = `100%`
    overlayElement.style.width = `100%`
    overlayElement.style['pointer-events'] = 'none'
    
    allElements.forEach((element) => {
        const id = crypto.randomUUID()
        element.dataset.vibeActionableId = id
        
        if (window.getComputedStyle(element).pointerEvents != 'auto') {
            element.style.pointerEvents = 'auto'
        }
        
        if (window.getComputedStyle(element).zIndex > maxZIndex) {
            maxZIndex = window.getComputedStyle(element).zIndex
            overlayElement.style.zIndex = maxZIndex + 1
        }
        
        element.addEventListener('click', (e) => {
            e.preventDefault()
            e.stopPropagation()
            
            const targetElement = e.currentTarget
            const id = targetElement.dataset.vibeActionableId
            
            const selectedOverlay = document.getElementById(id) ?? document.createElement('div')
            const borderWidth = 3
            if (window.getComputedStyle(element).zIndex > maxZIndex) {
                maxZIndex = window.getComputedStyle(element).zIndex
            }
            overlayElement.style['z-index'] = maxZIndex + 1
            selectedOverlay.id = id
            selectedOverlay.style.position = 'absolute'
            selectedOverlay.style.left = `${targetElement.getBoundingClientRect().left + window.scrollX}px`
            selectedOverlay.style.top = `${targetElement.getBoundingClientRect().top + window.scrollY}px`
            selectedOverlay.style.width = `${targetElement.getBoundingClientRect().width - borderWidth * 2}px`
            selectedOverlay.style.height = `${targetElement.getBoundingClientRect().height - borderWidth * 2}px`
            selectedOverlay.style.border = `${borderWidth}px solid`
            selectedOverlay.style.borderColor = `rgb(85, 89, 220)`
            selectedOverlay.style.borderRadius = '4px'
            selectedOverlay.style['box-sizing'] = 'content-box'
            selectedOverlay.style['pointer-events'] = 'none'
            
            const isSelected = document.vibeActionableDataModel.isSelected.get(id)
            
            if (isSelected) {
                selectedOverlay.remove()
            } else {
                overlayElement.append(selectedOverlay)
            }

            document.vibeActionableDataModel.isSelected.set(id, !isSelected)
        })
    })
    
    overlayElement.style['z-index'] = maxZIndex + 1
    document.body.append(overlayElement)

//
//    
//    const elements = document.body.querySelectorAll('*')
//    
//    elements.forEach((element) => {
//        const id = crypto.randomUUID()
//        const borderWidth = 3
//        element.dataset.vibeActionableId = id
//        console.log(element.className, id)
//
//        element.addEventListener('click', (e) => {
//            const targetElement = e.currentTarget
//            const id = targetElement.dataset.vibeActionableId
//            
//            e.stopPropagation()
//            e.preventDefault()
//            
//            const overlayElement = getOverlayElement(id)
//            overlayElement.id = id
//            overlayElement.style.position = 'absolute'
//            overlayElement.style.left = `${targetElement.getBoundingClientRect().left}px`
//            overlayElement.style.top = `${targetElement.getBoundingClientRect().top}px`
//            overlayElement.style.width = `${targetElement.getBoundingClientRect().width - borderWidth * 2}px`
//            overlayElement.style.height = `${targetElement.getBoundingClientRect().height - borderWidth * 2}px`
//            overlayElement.style.border = `${borderWidth}px solid`
//            overlayElement.style.borderColor = `rgb(85, 89, 220)`
//            overlayElement.style.borderRadius = '4px'
//            overlayElement.style['box-sizing'] = 'content-box'
//            overlayElement.style['pointer-events'] = 'none'
//            
//            const isSelected = document.vibeActionableDataModel.isSelected.get(id)
//            
//            if (isSelected) {
//                overlayElement.remove()
//            } else {
//                document.body.append(overlayElement)
//            }
//
//            document.vibeActionableDataModel.isSelected.set(id, !isSelected)
//            
//        })
//    })
    
    return true
})()
