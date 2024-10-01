(function() {
    const getOverlayElement = (id) => {
        const overlayElement = document.getElementById(id) ?? document.createElement('div')
        return overlayElement
    }
    
    document.vibeActionableDataModel = {
        isSelected: new Map(),
    }
    
    const textOutputs = []
    const elements = document.body.querySelectorAll('*')
    
    elements.forEach((element) => {
        const id = crypto.randomUUID()
        const borderWidth = 3
        element.dataset.vibeActionableId = id
        
        element.addEventListener('click', (e) => {
            const targetElement = e.currentTarget
            const id = targetElement.dataset.vibeActionableId
            e.stopPropagation()
            e.preventDefault()
            
            const overlayElement = getOverlayElement(id)
            overlayElement.id = id
            overlayElement.style.position = 'absolute'
            overlayElement.style.left = `${targetElement.getBoundingClientRect().left}px`
            overlayElement.style.top = `${targetElement.getBoundingClientRect().top}px`
            overlayElement.style.width = `${targetElement.getBoundingClientRect().width - borderWidth * 2}px`
            overlayElement.style.height = `${targetElement.getBoundingClientRect().height - borderWidth * 2}px`
            overlayElement.style.border = `${borderWidth}px solid`
            overlayElement.style.borderColor = `rgb(78, 55, 108)`
            overlayElement.style.borderRadius = '4px'
            overlayElement.style['box-sizing'] = 'content-box'
            overlayElement.style['pointer-events'] = 'none'
            
            const isSelected = document.vibeActionableDataModel.isSelected.get(id)
            
            if (isSelected) {
                overlayElement.remove()
            } else {
                targetElement.append(overlayElement)
            }

            document.vibeActionableDataModel.isSelected.set(id, !isSelected)
            
            console.log('(onclick handler) id: ' + id)
        })
        
        textOutputs.push(element.dataset.vibeActionableId)
    })
    
    return textOutputs
})()
