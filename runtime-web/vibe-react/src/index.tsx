import React from 'react'
import {VibeDataModel, VibeCanvasSize} from 'vibe-base'

// class VibeAppDataModel {
//     private containerId: string

//     constructor(containerId: string) {
//         this.containerId = containerId
//     }

//     public getId(): string {
//         return this.containerId;
//     }
// }

export type VibeContainerProps = {
    children: React.ReactElement,
    id: string,
    baseURL: string,
}

export type VibeableProps = {
    children: React.ReactElement,
    id: string,
}

export type VibeActionableProps = {
    children: React.ReactElement,
    id: string,
}

const VibeContext = React.createContext<VibeDataModel|undefined>(undefined)

const useVibeDataModel = () => {
    const vibeDataModel = React.useContext(VibeContext)

    if (!vibeDataModel) {
        throw new Error('useVibeDataModel must be used within a VibeContext.Provider')
    }
    return vibeDataModel
}

const VibeParentIdContext = React.createContext<string|undefined>(undefined)


const useVibeParentId = () => {
    const vibeParentId = React.useContent(VibeParentIdContext)

    if (!vibeParentId) {
        throw new Error('useVibeParentId must be used within a VibeContext.Provider')
    }

    return vibeParentId
}

const VibeContainerIdContext = React.createContext<string|undefined>(undefined)


const useVibeContainerId = () => {
    const vibeContainerId = React.useContent(VibeContainerIdContext)

    if (!vibeContainerId) {
        throw new Error('useVibeContainerId must be used within a VibeContainerIdContext.Provider')
    }

    return vibeContainerId
}

const VibeIsContainerContext = React.createContext<boolean>(false)


const useVibeIsContainer = () => {
    const vibeIsContainer = React.useContent(VibeIsContainerContext)

    if (!vibeIsContainer) {
        throw new Error('useVibeIsContainer must be used within a VibeIsContainerContext.Provider')
    }

    return vibeIsContainer
}

export const VibeContainer = ({children, id, baseURL}: VibeContainerProps): React.ReactElement => {
    const [vibeDataModel, setVibeDataModel] = React.useState<VibeDataModel|undefined>(new VibeDataModel(id, baseURL))
    const [bounds, setBounds] = React.useState<VibeCanvasSize | null>(null)

    const ref = React.useRef(null)

    React.useEffect(() => {
        if (ref != null) {
            const rect = (ref?.current as Element | null)?.getBoundingClientRect()

            if (rect != null) {
                setBounds(rect)
            }
        }        
    }, [])

    return (
        <VibeCanvasSizeContext.Provider value={bounds}>
            <div data-vibe-container-id={id} ref={ref}>
                <VibeContext.Provider value={vibeDataModel}>
                    <VibeParentIdContext.Provider value={id}>
                        <VibeContainerIdContext.Provider value={id}>
                            <VibeIsContainerContext.Provider value={true}>
                                {children}
                            </VibeIsContainerContext.Provider> 
                        </VibeContainerIdContext.Provider> 
                    </VibeParentIdContext.Provider> 
                </VibeContext.Provider> 
            </div>
        </VibeCanvasSizeContext.Provider>
    )
}

const VibeCanvasSizeContext = React.createContext<VibeCanvasSize | null>(null)

export const Vibeable = ({children, id}: VibeableProps): React.ReactElement => {
    const vibeDataModel = useVibeDataModel()
    const vibeParentId = useVibeParentId()
    const vibeContainerId = useVibeContainerId()
    const vibeIsContainer = useVibeIsContainer()
    const vibeCanvasSize = React.useContext<VibeCanvasSize | null>(VibeCanvasSizeContext)

    async function init() {
        await vibeDataModel?.init()
    }

    async function attachAnimations() {
        await init()
        
        const view = document.querySelector('[data-vibe-id="' + id + '"]')
        if (vibeDataModel != null && vibeDataModel != undefined) {
            
            const objects = vibeDataModel?.objects
            if (objects) {
                const object = objects.get(id)
                
                if (object) {
                    console.log({object})
                    const animation = object.animation
                    const keyframes = animation.keyframes

                    const keyframeValues = keyframes?.map(keyframe => {
                        return keyframe.values
                    })

                    const keyframeInitialValues = animation.initialValues
                    if (keyframeValues != null && keyframeInitialValues != null && vibeCanvasSize != null) {
                        const keyframeValuesWithInitial = [
                            keyframeInitialValues,
                            ...keyframeValues
                        ]
                        
                        const keyframesWebAPI = keyframeValuesWithInitial?.map(values => {
                            const translate = values.translate
                            const translateX = translate[0] * vibeCanvasSize.width / 2
                            const translateY = translate[1] * vibeCanvasSize.height / 2
                            return {    
                                transform: 'translateX(' + translateX + 'px) translateY(' + translateY + 'px)' + ' rotate(' + values.rotateCenter + 'deg) scale(' + values.scale + ')', 
                                transformOrigin: 'center',
                                opacity: values.opacity,
                            }
                        })

                        const totalDuration = keyframes?.reduce((accumulator, keyframe) => {
                            return accumulator + (keyframe.duration * 1000)
                        }, 0)

                        const timing = {
                            duration: totalDuration,
                            iterations: Infinity,
                            easing: 'ease-in-out'
                        } as KeyframeAnimationOptions

                        view?.animate(keyframesWebAPI ?? [], timing)
                    }
                }
            }
        }
    }

    React.useEffect(() => {
        if (vibeCanvasSize != null && vibeDataModel != null) {
            attachAnimations()
        }
    }, [vibeDataModel, vibeCanvasSize])

    return (
        <div data-vibe-id={id}>
            <VibeParentIdContext.Provider value={id}>
                <VibeIsContainerContext.Provider value={false}>
                    {children}
                </VibeIsContainerContext.Provider> 
            </VibeParentIdContext.Provider> 
        </div>   
    )
}