function invokePlayback(animationsFromHost) {
    console.log(`invokePlayback called`)
//    const dataModel = null
//    
//    if (dataModel) {
//        const animations = []
//        const containers = []
////        console.log({animationsFromHost})
//        for (const animationText of animationsFromHost) {
//            
//            const animation = JSON.parse(animationText)
////            console.log({animation})
//            if (animation) {
//                animations.push(animation)
//                containers.push(animation.container)
//            }
//        }
////        console.log({containers})
//        //        console.log({animations})
//        
//        var canvasSizes = {}
//        
//        for (const container of containers) {
//            const actionableId = container.actionableId
//            const containerId = container.containerId
////            console.log({actionableId})
////            console.log({containerId})
//            const containerView = document.querySelector('[data-inertia-actionable-id="' + actionableId + '"]')
//            containerView.dataset.inertiaContainerId = containerId
//            const rect = containerView.getBoundingClientRect()
////            console.log({rect})
//            canvasSizes[containerId] = {width: rect.width, height: rect.height}
//        }
//        
//        for (const animationObject of animations) {
//            const animationId = animationObject.animationId
//            const actionableId = animationObject.actionableId
//            const schema = animationObject.schema
//            if (!dataModel.animations.has(animationId)) {
//                dataModel.animations.set(animationId, [])
//            }
//            
//            dataModel.animations.get(animationId).push(schema)
////            console.log({animation})
//            const view = document.querySelector('[data-inertia-actionable-id="' + actionableId + '"]')
////            console.log({view})
//            
//            const animation = animationObject.schema.objects.filter(obj => obj.id == animationId)[0]
//            const inertiaCanvasSize = canvasSizes[animation.containerId]
//            const keyframes = animation.animation.keyframes
//            const keyframeValues = keyframes?.map(keyframe => {
//                return keyframe.values
//            })
//            
////            console.log({keyframes})
//            const keyframeInitialValues = animation.animation.initialValues
////            console.log({keyframeInitialValues})
////            console.log({keyframeValues})
////            console.log({inertiaCanvasSize})
//            if (keyframeValues != null && keyframeInitialValues != null && inertiaCanvasSize != null) {
//                const keyframeValuesWithInitial = [
//                    keyframeInitialValues,
//                    ...keyframeValues
//                ]
//                
//                const keyframesWebAPI = keyframeValuesWithInitial?.map(values => {
//                    const translate = values.translate
//                    const translateX = translate[0] * inertiaCanvasSize.width / 2
//                    const translateY = translate[1] * inertiaCanvasSize.height / 2
//                    return {
//                        transform: 'translateX(' + translateX + 'px) translateY(' + translateY + 'px)' + ' rotate(' + values.rotateCenter + 'deg) scale(' + values.scale + ')',
//                        transformOrigin: 'center',
//                        opacity: values.opacity,
//                    }
//                })
//                
//                const totalDuration = keyframes?.reduce((accumulator, keyframe) => {
//                    return accumulator + (keyframe.duration * 1000)
//                }, 0)
//                
//                const timing = {
//                    duration: totalDuration,
//                    iterations: Infinity,
////                    easing: 'ease-in-out'
//                    easing: 'linear'
//                }
//                
////                console.log(window.getComputedStyle(view).position)
//                view?.animate(keyframesWebAPI ?? [], timing)
//            }
//        }
//    }
    
    return true
}

(function() {
    console.log('initInvokePlayback')
    return true
})()
