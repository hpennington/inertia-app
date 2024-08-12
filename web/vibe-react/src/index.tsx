import React from 'react'
import {vibeHello} from 'vibe-base'

type Props = {
    name: string
}

export const VibeHelloReact = (props: Props): React.Component => {
    vibeHello(props.name)
    return (
        <h1>{"VibeHello"}</h1>
    )
}

