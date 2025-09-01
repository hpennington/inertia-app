import React from 'react'
import {VibeDataModel, VibeCanvasSize, VibeID, Tree, Node} from 'vibe-base'

export type VibeContainerProps = {
    children: React.ReactElement,
    id: string,
    baseURL: string,
}

export type VibeableProps = {
    children: React.ReactElement,
    hierarchyIdPrefix: string,
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
    const vibeParentId = React.useContext(VibeParentIdContext)

    if (!vibeParentId) {
        throw new Error('useVibeParentId must be used within a VibeContext.Provider')
    }

    return vibeParentId
}

const VibeContainerIdContext = React.createContext<string|undefined>(undefined)


const useVibeContainerId = () => {
    const vibeContainerId = React.useContext(VibeContainerIdContext)

    if (!vibeContainerId) {
        throw new Error('useVibeContainerId must be used within a VibeContainerIdContext.Provider')
    }

    return vibeContainerId
}

const VibeIsContainerContext = React.createContext<boolean>(false)


const useVibeIsContainer = () => {
    const vibeIsContainer = React.useContext(VibeIsContainerContext)

    if (!vibeIsContainer) {
        throw new Error('useVibeIsContainer must be used within a VibeIsContainerContext.Provider')
    }

    return vibeIsContainer
}

// VibeWebSocket.ts
export enum MessageType {
    actionable = "actionable",
    actionables = "actionables",
    selected = "selected",
    schema = "schema",
}

export interface MessageWrapper<T = any> {
    type: MessageType;
    payload: T;
}

export type MessageActionables = {
    tree: Tree;
    actionableIds: Set<string>;
};

// Helper to convert JSON received from WebSocket into MessageActionables
export function messageActionablesFromJSON(json: any): MessageActionables {
    return {
        tree: Tree.fromJSON(json.tree),                // convert tree JSON to Tree instance
        actionableIds: new Set<string>(json.actionableIds) // convert array to Set
    };
}

// Helper to convert MessageActionables to JSON for sending over WebSocket
export function messageActionablesToJSON(msg: MessageActionables): any {
    return {
        tree: msg.tree.toJSON(),               // convert Tree instance to JSON
        actionableIds: Array.from(msg.actionableIds) // convert Set to array
    };
}


// --- MessageActionable ---
export type MessageActionable = {
    isActionable: boolean;
};

export function messageActionableFromJSON(json: any): MessageActionable {
    return {
        isActionable: json.isActionable,
    };
}

export function messageActionableToJSON(msg: MessageActionable): any {
    return {
        isActionable: msg.isActionable,
    };
}

// --- MessageSelected ---
export type MessageSelected = {
    selectedIds: Set<string>;
};

export function messageSelectedFromJSON(json: any): MessageSelected {
    return {
        selectedIds: new Set<string>(json.selectedIds),
    };
}

export function messageSelectedToJSON(msg: MessageSelected): any {
    return {
        selectedIds: Array.from(msg.selectedIds),
    };
}

// --- MessageSchema ---
export type MessageSchema = {
    schemaWrappers: VibeSchemaWrapper[];
};

export function messageSchemaFromJSON(json: any): MessageSchema {
    return {
        schemaWrappers: json.schemaWrappers, // assuming schemaWrappers are already plain objects
    };
}

export function messageSchemaToJSON(msg: MessageSchema): any {
    return {
        schemaWrappers: msg.schemaWrappers,
    };
}

// --- Basic Types ---
export type CGPoint = { x: number; y: number };
export type CGSize = { width: number; height: number };

// --- Enum ---
export enum VibeObjectType {
    Shape = "shape",
    Animation = "animation",
}

// --- AnimationContainer ---
export type AnimationContainer = {
    actionableId: VibeID;
    containerId: VibeID;
};

export function animationContainerFromJSON(json: any): AnimationContainer {
    return {
        actionableId: json.actionableId,
        containerId: json.containerId,
    };
}

export function animationContainerToJSON(container: AnimationContainer): any {
    return {
        actionableId: container.actionableId,
        containerId: container.containerId,
    };
}


// --- VibeShape ---
export type VibeShape = {
    id: VibeID;
    containerId: VibeID;
    width: number;
    height: number;
    position: CGPoint;
    color: number[]; // array of CGFloat
    shape: string;
    objectType: VibeObjectType;
    zIndex: number;
    animation: VibeAnimationSchema;
};

export function vibeShapeFromJSON(json: any): VibeShape {
    return {
        id: json.id,
        containerId: json.containerId,
        width: json.width,
        height: json.height,
        position: { x: json.position.x, y: json.position.y },
        color: json.color,
        shape: json.shape,
        objectType: json.objectType as VibeObjectType,
        zIndex: json.zIndex,
        animation: json.animation,
    };
}

export function vibeShapeToJSON(shape: VibeShape): any {
    return {
        id: shape.id,
        containerId: shape.containerId,
        width: shape.width,
        height: shape.height,
        position: { x: shape.position.x, y: shape.position.y },
        color: shape.color,
        shape: shape.shape,
        objectType: shape.objectType,
        zIndex: shape.zIndex,
        animation: shape.animation,
    };
}

// --- VibeSchema ---
export type VibeSchema = {
    id: VibeID;
    objects: VibeShape[];
};

export function vibeSchemaFromJSON(json: any): VibeSchema {
    return {
        id: json.id,
        objects: (json.objects ?? []).map(vibeShapeFromJSON),
    };
}

export function vibeSchemaToJSON(schema: VibeSchema): any {
    return {
        id: schema.id,
        objects: schema.objects.map(vibeShapeToJSON),
    };
}

// --- VibeSchemaWrapper ---
export type VibeSchemaWrapper = {
    schema: VibeSchema;
    actionableId: VibeID;
    container: AnimationContainer;
    animationId: string;
};

export function vibeSchemaWrapperFromJSON(json: any): VibeSchemaWrapper {
    return {
        schema: vibeSchemaFromJSON(json.schema),
        actionableId: json.actionableId,
        container: animationContainerFromJSON(json.container),
        animationId: json.animationId,
    };
}

export function vibeSchemaWrapperToJSON(wrapper: VibeSchemaWrapper): any {
    return {
        schema: vibeSchemaToJSON(wrapper.schema),
        actionableId: wrapper.actionableId,
        container: animationContainerToJSON(wrapper.container),
        animationId: wrapper.animationId,
    };
}


// --- VibeAnimationValues ---
export type VibeAnimationValues = {
    scale: number;
    translate: CGSize;
    rotate: number;
    rotateCenter: number;
    opacity: number;
};

// Zero value constant
export const zeroVibeAnimationValues: VibeAnimationValues = {
    scale: 0,
    translate: { width: 0, height: 0 },
    rotate: 0,
    rotateCenter: 0,
    opacity: 0,
};

// Arithmetic helpers
export function addVibeAnimationValues(
    a: VibeAnimationValues,
    b: VibeAnimationValues
): VibeAnimationValues {
    return {
        scale: a.scale + b.scale,
        translate: { width: a.translate.width + b.translate.width, height: a.translate.height + b.translate.height },
        rotate: a.rotate + b.rotate,
        rotateCenter: a.rotateCenter + b.rotateCenter,
        opacity: a.opacity + b.opacity,
    };
}

export function subtractVibeAnimationValues(
    a: VibeAnimationValues,
    b: VibeAnimationValues
): VibeAnimationValues {
    return {
        scale: a.scale - b.scale,
        translate: { width: a.translate.width - b.translate.width, height: a.translate.height - b.translate.height },
        rotate: a.rotate - b.rotate,
        rotateCenter: a.rotateCenter - b.rotateCenter,
        opacity: a.opacity - b.opacity,
    };
}

export function scaleVibeAnimationValues(v: VibeAnimationValues, factor: number): VibeAnimationValues {
    return {
        scale: v.scale * factor,
        translate: { width: v.translate.width * factor, height: v.translate.height * factor },
        rotate: v.rotate * factor,
        rotateCenter: v.rotateCenter * factor,
        opacity: v.opacity * factor,
    };
}

// --- VibeAnimationKeyframe ---
export type VibeAnimationKeyframe = {
    id: VibeID;
    values: VibeAnimationValues;
    duration: number;
};

export function vibeAnimationKeyframeFromJSON(json: any): VibeAnimationKeyframe {
    return {
        id: json.id,
        values: json.values,
        duration: json.duration,
    };
}

export function vibeAnimationKeyframeToJSON(keyframe: VibeAnimationKeyframe): any {
    return {
        id: keyframe.id,
        values: keyframe.values,
        duration: keyframe.duration,
    };
}

// --- VibeAnimationInvokeType ---
export enum VibeAnimationInvokeType {
    Trigger = "trigger",
    Auto = "auto",
}

// --- VibeAnimationSchema ---
export type VibeAnimationSchema = {
    id: VibeID;
    initialValues: VibeAnimationValues;
    invokeType: VibeAnimationInvokeType;
    keyframes: VibeAnimationKeyframe[];
};

export function vibeAnimationSchemaFromJSON(json: any): VibeAnimationSchema {
    return {
        id: json.id,
        initialValues: json.initialValues,
        invokeType: json.invokeType as VibeAnimationInvokeType,
        keyframes: (json.keyframes ?? []).map(vibeAnimationKeyframeFromJSON),
    };
}

export function vibeAnimationSchemaToJSON(schema: VibeAnimationSchema): any {
    return {
        id: schema.id,
        initialValues: schema.initialValues,
        invokeType: schema.invokeType,
        keyframes: schema.keyframes.map(vibeAnimationKeyframeToJSON),
    };
}

export class VibeWebSocket {
    private ws: WebSocket | null = null;
    public onMessageActionable: ((msg: { isActionable: boolean }) => void) | null = null;
    public onMessageActionables: ((msg: { tree: Tree; actionableIds: Set<string> }) => void) | null = null;
    public onMessageSelected: ((msg: { selectedIds: Set<string> }) => void) | null = null;
    public onMessageSchema: ((msg: { schemaWrappers: any[] }) => void) | null = null;

    constructor(private url: string) {}

    connect(tree: Tree) {
        this.ws = new WebSocket(this.url);
        this.ws.binaryType = "arraybuffer";

        // this.ws.onopen = () => console.log("WebSocket connected");
        this.ws.onopen = () => this.sendActionables(tree, ["homeCard"])
        this.ws.onclose = () => console.log("WebSocket disconnected");
        this.ws.onerror = (err) => console.error("WebSocket error", err);
        this.ws.onmessage = (event) => this.handleMessage(event);
    }

    private handleMessage(event: MessageEvent) {
        try {
            const data = new Uint8Array(event.data); // binary data from Swift server
            const jsonStr = new TextDecoder().decode(data); // decode UTF-8
            const wrapper: MessageWrapper<Uint8Array> = JSON.parse(jsonStr);

            // payload is raw JSON bytes, decode it
            const payloadJsonStr = new TextDecoder().decode(wrapper.payload);
            const payloadObj = JSON.parse(payloadJsonStr);

            switch (wrapper.type) {
                case MessageType.actionable:
                    this.onMessageActionable?.(payloadObj);
                    break;
                case MessageType.actionables:
                    // Convert tree JSON to Tree instance
                    payloadObj.tree = Tree.fromJSON(payloadObj.tree);
                    payloadObj.actionableIds = new Set(payloadObj.actionableIds);
                    this.onMessageActionables?.(payloadObj);
                    break;
                case MessageType.selected:
                    payloadObj.selectedIds = new Set(payloadObj.selectedIds);
                    this.onMessageSelected?.(payloadObj);
                    break;
                case MessageType.schema:
                    this.onMessageSchema?.(payloadObj);
                    break;
            }
        } catch (err) {
            console.error("Failed to decode WebSocket message:", err);
        }
    }

    sendMessage<T extends object>(type: MessageType, payload: T) {
        if (!this.ws || this.ws.readyState !== WebSocket.OPEN) return;

        // // Encode payload as JSON bytes
        // const payloadBytes = new TextEncoder().encode(JSON.stringify(payload));

        // // Wrap in MessageWrapper
        // const wrapper: MessageWrapper<Uint8Array> = { type, payload: payloadBytes };

        // // Encode wrapper itself as JSON
        // const wrapperBytes = new TextEncoder().encode(JSON.stringify(wrapper));

        // this.ws.send(wrapperBytes);

        if (!this.ws || this.ws.readyState !== WebSocket.OPEN) return;

        // 1️⃣ Encode payload as JSON string
        const payloadStr = JSON.stringify(payload);

        // 2️⃣ Convert to base64
        const base64Payload = btoa(payloadStr);

        // 3️⃣ Wrap in type wrapper
        const wrapper = { type, payload: base64Payload };

        // 4️⃣ Send wrapper as JSON string
        this.ws.send(JSON.stringify(wrapper));
    }

    // High-level helpers
    sendActionable(isActionable: boolean) {
        this.sendMessage(MessageType.actionable, { isActionable });
    }

    sendActionables(tree: Tree, actionableIds: string[]) {
        this.sendMessage(MessageType.actionables, { tree: tree.toJSON(), actionableIds });
    }

    sendSelected(selectedIds: string[]) {
        this.sendMessage(MessageType.selected, { selectedIds });
    }

    sendSchema(schemaWrappers: any[]) {
        this.sendMessage(MessageType.schema, { schemaWrappers });
    }
}

// export class VibeWebSocket {
//     private ws: WebSocket | null = null;
//     public onMessage: ((message: MessageWrapper) => void) | null = null; // callback

//     constructor(private url: string) {}

//     connect() {
//         this.ws = new WebSocket(this.url);
//         this.ws.binaryType = "arraybuffer";

//         this.ws.onopen = () => this.sendActionables({"id": "TestValue", "nodeMap": {"id": "123"}}, ["homeCard"]);
//         this.ws.onclose = () => console.log("WebSocket disconnected");
//         this.ws.onerror = (err) => console.error("WebSocket error", err);
//         this.ws.onmessage = (event) => this.handleMessage(event);
//     }

//     private handleMessage(event: MessageEvent) {
//         try {
//             const data = new Uint8Array(event.data);
//             const jsonStr = new TextDecoder().decode(data);
//             const message: MessageWrapper = JSON.parse(jsonStr);

//             if (this.onMessage) this.onMessage(message);
//         } catch (err) {
//             console.error("Failed to parse WS message:", err);
//         }
//     }

//     /**
//      * Sends a message. Automatically handles:
//      * - Base64 encoding if payload is Uint8Array or number[]
//      * - JSON serialization for objects
//      */
//     // private sendMessage<T>(type: MessageType, payload: T) {
//     //     if (!this.ws || this.ws.readyState !== WebSocket.OPEN) return;

//     //     // let encodedPayload: string;

//     //     // if (payload instanceof Uint8Array) {
//     //     //     encodedPayload = Buffer.from(payload).toString("base64");
//     //     // } else if (Array.isArray(payload) && payload.every((n) => typeof n === "number")) {
//     //     //     encodedPayload = Buffer.from(new Uint8Array(payload)).toString("base64");
//     //     // } else {
//     //     //     encodedPayload = JSON.stringify(payload);
//     //     // }

//     //     // Encode any payload as Uint8Array first
//     //     const jsonBytes = new TextEncoder().encode(JSON.stringify(payload));
//     //     const payloadBase64 = uint8ToBase64(jsonBytes)

//     //     const wrapper: MessageWrapper<string> = { type, payload: payloadBase64 };
//     //     const buffer = new TextEncoder().encode(JSON.stringify(wrapper));
//     //     this.ws.send(buffer);
//     // }

//     private sendMessage<T>(type: MessageType, payload: T) {
//         if (!this.ws || this.ws.readyState !== WebSocket.OPEN) return;
//         // 1. Convert payload object to JSON string
//         const jsonString = JSON.stringify(payload);

//         // 2. Convert JSON string to Uint8Array (bytes)
//         const encoder = new TextEncoder();
//         const jsonBytes = encoder.encode(jsonString);

//         const payloadBase64 = uint8ToBase64(jsonBytes);

//         // 4. Wrap in your MessageWrapper
//         const wrapper: MessageWrapper<string> = {
//             type: type,
//             payload: payloadBase64
//         };

//         // 5. Send as stringified JSON
//         this.ws.send(JSON.stringify(wrapper));
//     }


//     // --- High-level message helpers ---
//     sendActionable(isActionable: boolean) {
//         this.sendMessage(MessageType.actionable, { isActionable });
//     }

//     sendSelected(ids: string[]) {
//         this.sendMessage(MessageType.selected, { selectedIds: ids });
//     }

//     sendActionables(tree: any, actionableIds: string[]) {
//         this.sendMessage(MessageType.actionables, { tree, actionableIds });
//     }

//     sendSchema(schemaWrappers: any[]) {
//         this.sendMessage(MessageType.schema, { schemaWrappers });
//     }
// }

// export const VibeContainer = ({children, id, baseURL}: VibeContainerProps): React.ReactElement => {
//     const [vibeDataModel, setVibeDataModel] = React.useState<VibeDataModel|undefined>(new VibeDataModel(id, baseURL))
//     const [bounds, setBounds] = React.useState<VibeCanvasSize | null>(null)

//     const ref = React.useRef(null)

//     React.useEffect(() => {
//         if (ref != null) {
//             const rect = (ref?.current as Element | null)?.getBoundingClientRect()

//             if (rect != null) {
//                 setBounds(rect)
//             }
//         }        
//     }, [])

//     return (
//         <VibeCanvasSizeContext.Provider value={bounds}>
//             <div data-vibe-container-id={id} ref={ref}>
//                 <VibeContext.Provider value={vibeDataModel}>
//                     <VibeParentIdContext.Provider value={id}>
//                         <VibeContainerIdContext.Provider value={id}>
//                             <VibeIsContainerContext.Provider value={true}>
//                                 {children}
//                             </VibeIsContainerContext.Provider> 
//                         </VibeContainerIdContext.Provider> 
//                     </VibeParentIdContext.Provider> 
//                 </VibeContext.Provider> 
//             </div>
//         </VibeCanvasSizeContext.Provider>
//     )
// }

class SharedIndexManager {
    // The singleton instance
    private static _instance: SharedIndexManager;

    // Private constructor to prevent external instantiation
    private constructor() {}

    // Static getter to access the singleton
    public static get shared(): SharedIndexManager {
        if (!SharedIndexManager._instance) {
            SharedIndexManager._instance = new SharedIndexManager();
        }
        return SharedIndexManager._instance;
    }

    // Properties
    public indexMap: Record<string, number> = {};
    public objectIndexMap: Record<string, number> = {};
    public objectIdSet: Set<string> = new Set();
}

export const VibeContainer = ({children, id, baseURL}: VibeContainerProps): React.ReactElement => {
    const [vibeDataModel] = React.useState(() => new VibeDataModel(id, baseURL, new Tree(id)));
    const [bounds, setBounds] = React.useState<VibeCanvasSize | null>(null);
    const ref = React.useRef(null);

    const wsRef = React.useRef<VibeWebSocket | null>(null);

    React.useEffect(() => {
        if (!wsRef.current) {
            const ws = new VibeWebSocket("ws://127.0.0.1:8060");

            // Connect to the server
            ws.connect(vibeDataModel?.tree);

            // Handle actionable messages
            ws.onMessageActionable = (msg) => {
                console.log("Received actionable:", msg);
                // vibeDataModel.updateIsActionable?.(msg.isActionable);
            };

            // Handle actionables (tree updates)
            ws.onMessageActionables = (msg) => {
                console.log("Received actionables:", msg);
                // msg.tree is already a Tree instance
                // vibeDataModel.updateTree?.(msg.tree, msg.actionableIds);
            };

            // Handle selected nodes
            ws.onMessageSelected = (msg) => {
                console.log("Received selected:", msg);
                // vibeDataModel.selectNodes?.(msg.selectedIds);
            };

            // Handle schema updates
            ws.onMessageSchema = (msg) => {
                console.log("Received schema:", msg);
                // vibeDataModel.updateSchema?.(msg.schemaWrappers);
            };

            wsRef.current = ws;
        }
    }, [baseURL, vibeDataModel]);



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
    );
};

const VibeCanvasSizeContext = React.createContext<VibeCanvasSize | null>(null)

export const Vibeable = ({children, hierarchyIdPrefix}: VibeableProps): React.ReactElement => {
    const vibeDataModel = useVibeDataModel()
    const vibeParentId = useVibeParentId()
    const vibeContainerId = useVibeContainerId()
    const vibeIsContainer = useVibeIsContainer()
    const vibeCanvasSize = React.useContext<VibeCanvasSize | null>(VibeCanvasSizeContext)
    const indexManager = SharedIndexManager.shared;

    var hierarchyId: string|undefined = undefined

    async function init() {
        await vibeDataModel?.init()
        updateHierarchyId()
    }

    function updateHierarchyId(): void {
        const indexValue = indexManager.indexMap[hierarchyIdPrefix];

        if (indexValue !== undefined) {
            hierarchyId = `${hierarchyIdPrefix}--${indexValue}`;
            indexManager.indexMap[hierarchyIdPrefix] = indexValue + 1;
        } else {
            hierarchyId = `${hierarchyIdPrefix}--0`;
            indexManager.indexMap[hierarchyIdPrefix] = 1;
        }
    }


    async function attachAnimations() {
        await init()

        if (hierarchyId) {
            const view = document.querySelector('[data-vibe-id="' + hierarchyId + '"]')
            if (vibeDataModel != null && vibeDataModel != undefined) {
                
                const objects = vibeDataModel?.objects
                if (objects) {
                    const object = objects.get(hierarchyId)
                    
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
    }

    React.useEffect(() => {
        if (vibeCanvasSize != null && vibeDataModel != null) {
            attachAnimations()
        }
    }, [vibeDataModel, vibeCanvasSize])

    React.useEffect(() => {
        if (hierarchyId) {
            vibeDataModel?.tree.addRelationship(hierarchyId, vibeParentId, vibeIsContainer)    
        }
    }, [hierarchyId])

    React.useEffect(() => {
        updateHierarchyId()
    }, [])

    React.useEffect(() => {
        const tree = vibeDataModel?.tree

        if (tree) {
            for (const node of Object.values(tree.nodeMap)) {
                node.tree = tree
                node.link()
            }

            console.log({tree})
        }
    }, [vibeDataModel?.tree])

    return (
        <div data-vibe-id={hierarchyId}>
            <VibeParentIdContext.Provider value={hierarchyId}>
                <VibeIsContainerContext.Provider value={false}>
                    {children}
                </VibeIsContainerContext.Provider> 
            </VibeParentIdContext.Provider> 
        </div>   
    )
}