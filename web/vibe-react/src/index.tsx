import React from 'react'
import {VibeDataModel} from 'vibe-base'
import './index.scss'

type VibeContainerProps = {
    children: React.ReactNode,
}

export const VibeContainer: React.FC<VibeContainerProps> = ({children}) => {
    return <>{children}</>
}