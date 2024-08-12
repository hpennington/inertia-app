import React from 'react'
import {vibeHello} from 'vibe-base'
import './index.scss'

type Props = {
    name: string
}

export const VibeHelloReact = (props: Props): React.Component => {
    vibeHello(props.name)
    return (
        <h1 className="VibeHelloReact">{"VibeHello"}</h1>
    )
}

