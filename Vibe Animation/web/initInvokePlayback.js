function invokePlayback(animationsFromHost) {
    console.log(`invokePlayback called`)
    
    const dataModel = document.vibeDataModel
    
    if (dataModel) {
        for (const animationText of animationsFromHost) {
            const animation = JSON.parse(animationText)
            const actionableId = animation.actionableId
            const schema = JSON.parse(animation.schema)
            
            if (!dataModel.animations.has(actionableId)) {
                dataModel.animations.set(actionableId, [])
            }
            
            dataModel.animations.get(actionableId).push(schema)
        }
    }
    
    return true
}

(function() {
    console.log('initInvokePlayback')
    return true
})()
