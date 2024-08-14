import React from 'react'
import {VibeDataModel} from 'vibe-base'
// import './styles/index.scss'

export type VibeContainerProps = {
    children: React.ReactElement,
    id: string,
}

export type VibeableProps = {
    children: React.ReactElement,
}

const VibeContext = React.createContext<VibeDataModel|undefined>(undefined)

const useVibeDataModel = () => {
    const vibeDataModel = React.useContext(VibeContext)

    if (!vibeDataModel) {
        throw new Error('useVibeDataModel must be used within a VibeContext.Provider')
    }
    return vibeDataModel
}

export const VibeContainer = ({children, id}: VibeContainerProps): React.ReactNode => {
    const [vibeDataModel, setVibeDataModel] = React.useState<VibeDataModel|undefined>(new VibeDataModel(id))
    return (
        <VibeContext.Provider value={vibeDataModel}>
            {children}
        </VibeContext.Provider> 
    )
}

export const Vibeable = ({children}: VibeableProps): React.ReactNode => {
    const vibeDataModel = useVibeDataModel()

    console.log({vibeDataModel})

    return (
        <div>
            {children}
        </div>   
    )
}
