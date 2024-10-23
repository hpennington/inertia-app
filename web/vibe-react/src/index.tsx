import React from 'react'
import {VibeDataModel} from 'vibe-base'

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

export const VibeContainer = ({children, id, baseURL}: VibeContainerProps): React.ReactElement => {
    const [vibeDataModel, setVibeDataModel] = React.useState<VibeDataModel|undefined>(new VibeDataModel(id, baseURL))
    vibeDataModel?.init()
    return (
        <div data-container-id={id}>
            <VibeContext.Provider value={vibeDataModel}>
                {children}
            </VibeContext.Provider> 
        </div>
    )
}

export const Vibeable = ({children, id}: VibeableProps): React.ReactElement => {
    const vibeDataModel = useVibeDataModel()
    console.log({vibeDataModel})

    return (
        <div data-vibe-id={id}>
            {children}
        </div>   
    )
}

export const VibeActionable = ({children, id}: VibeActionableProps): React.ReactElement => {
    return (
        <div data-vibe-actionable-id={id}>
            {children}
        </div>   
    )
}