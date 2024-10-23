(function() {
    console.log('Injecting animations into the DOM')
    const dataModel = vibeDataModel
    
    if (dataModel) {
        dataModel.animations = new Map()
    }
    
    return true
})()
