function invokePlayback(animationsFromHost) {
    console.log(`invokePlayback called`)
    
    const dataModel = vibeDataModel
    
    if (dataModel) {
        for (const animationText of animationsFromHost) {
            const animation = JSON.parse(animationText)
            console.log({animation})
            
////            if (!dataModel.animations.has(animationId)) {
////                dataModel.animations.set(animationId, [])
////            }
////            dataModel.animations.get(animationId).push(schema)
//            
//            const view = document.querySelector('[data-vibe-actionable-id="' + actionableId + '"]')
//            console.log({view})
//            console.log({animation})
////            const objects = dataModel.objects
////            if (objects) {
////                console.log("getting object")
////                console.log({objects})
////                const object = objects.get(animationId)
////                console.log({object})
////                if (object) {
////                    console.log({object})
////                    const animation = object.animation
//                    const keyframes = animation.keyframes
//                    console.log({keyframes})
//                    const keyframeValues = keyframes?.map(keyframe => {
//                        return keyframe.values
//                    })
//
//                    const keyframeInitialValues = animation.initialValues
//                    if (keyframeValues != null && keyframeInitialValues != null && vibeCanvasSize != null) {
//                        const keyframeValuesWithInitial = [
//                            keyframeInitialValues,
//                            ...keyframeValues
//                        ]
//                        
//                        const keyframesWebAPI = keyframeValuesWithInitial?.map(values => {
//                            const translate = values.translate
//                            const translateX = translate[0] * vibeCanvasSize.width / 2
//                            const translateY = translate[1] * vibeCanvasSize.height / 2
//                            return {
//                                transform: 'translateX(' + translateX + 'px) translateY(' + translateY + 'px)' + ' rotate(' + values.rotateCenter + 'deg) scale(' + values.scale + ')',
//                                transformOrigin: 'center',
//                                opacity: values.opacity,
//                            }
//                        })
//
//                        const totalDuration = keyframes?.reduce((accumulator, keyframe) => {
//                            return accumulator + (keyframe.duration * 1000)
//                        }, 0)
//
//                        const timing = {
//                            duration: totalDuration,
//                            iterations: Infinity,
//                            easing: 'ease-in-out'
//                        }
//
//                        view?.animate(keyframesWebAPI ?? [], timing)
//                    }
////                }
//            }
        }
    }
    
    return true
}

(function() {
    console.log('initInvokePlayback')
    return true
})()
