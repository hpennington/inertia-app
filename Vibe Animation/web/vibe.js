(function() {
    const textOutputs = []
    const elements = document.body.querySelectorAll('*')
    elements.forEach((element) => {
        element.dataset.vibeClass = 'vibeable'
        element.dataset.vibeId = crypto.randomUUID()
        element.addEventListener('click', (e) => {
            e.stopPropagation()
            e.preventDefault()
            
            console.log('(onclick handler) id: ' + e.currentTarget.dataset.vibeId)
        })
        textOutputs.push(element.dataset.vibeId)
    })
    return textOutputs
})()
