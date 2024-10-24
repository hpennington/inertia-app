interface VibeSchema {
    id: string,
    objects: Array<VibeObjectSchema>|null
}

export type VibeCanvasSize = {
    width: number,
    height: number
}

class VibeEditorSchema implements VibeSchema {
    id: string;
    objects: Array<VibeObjectSchema>|null;
    isSelected: Map<string, boolean>;
    actionableIds: Array<string>;
    pointerEvents: Map<string, any>;
    webKitUserSelect: Map<string, string|null>;
    onWindowResize: Function|null;
    animations: Map<string, any>;
    isPlaying: boolean;

    constructor(
        id: string,
        objects: Array<VibeObjectSchema>|null,
        isSelected: Map<string, boolean> = new Map(),
        actionableIds: Array<string> = [],
        pointerEvents: Map<string, any> = new Map(),
        webKitUserSelect: Map<string, string | null> = new Map(),
        onWindowResize: Function|null = null,
        animations: Map<string, any> = new Map(),
        isPlaying: boolean = false
    ) {
        this.id = id
        this.objects = objects
        this.isSelected = isSelected
        this.actionableIds = actionableIds
        this.pointerEvents = pointerEvents
        this.webKitUserSelect = webKitUserSelect
        this.onWindowResize = onWindowResize
        this.animations = animations
        this.isPlaying = isPlaying
    }

}

class VibeRuntimeSchema implements VibeSchema {
    id: string;
    objects: Array<VibeObjectSchema>|null;

    constructor(
        id: string,
        objects: Array<VibeObjectSchema> | null = null
    ) {
        this.id = id
        this.objects = objects
    }
}

type VibeAnimation = {
    keyframes: Array<VibeAnimationKeyframe>
}

type VibeAnimationKeyframe = {
    values: VibeAnimationValues,
    duration: number
}

type VibeObjectSchema = {
    id: string,
    width: number,
    height: number,
    position: number,
    color: Array<number>,
    shape: string,
    // objectType: VibeObjectType,
    zIndex: number,
    animation: VibeAnimationSchema
}

type VibeAnimationState = {
    id: string,
    trigger: boolean | null,
    isCancelled: boolean
}

type VibeAnimationSchema = {
    id: string,
    initialValues: VibeAnimationValues,
    invokeType: VibeAnimationInvokeType,
    keyframes: Array<VibeAnimationKeyframe>
}

type VibeAnimationValues = {
    scale: number,
    translate: Array<number>,
    rotate: number,
    rotateCenter: number,
    opacity: number
}

enum VibeAnimationInvokeType {
    trigger,
    auto
}

var vibeDataModel: VibeEditorSchema

export class VibeDataModel {
    public async load(path: string): Promise<VibeSchema|null> {
        const res = await fetch(path)
        if (res.body) {
            return await res.json()
        }

        return null
    }

    public async init() {
        if (vibeDataModel != undefined && vibeDataModel != null) {
            let states: Map<string, VibeAnimationState> = new Map<string, VibeAnimationState>();

            let tmpObjects: Map<string, VibeObjectSchema> = new Map<string, VibeObjectSchema>();
            if (vibeDataModel?.objects) {
                for (const object of Object.values(vibeDataModel?.objects)) {
                tmpObjects.set(object.id, { 
                    id: object.id,
                    width: object.width,
                    height: object.height,
                    position: object.position,
                    color: object.color,
                    zIndex: object.zIndex,
                    shape: object.shape,
                    animation: object.animation
                });
                
                states.set(object.id, {
                    id: object.id,
                    trigger: object.animation.invokeType === VibeAnimationInvokeType.trigger ? false : null,
                    isCancelled: false
                })
                }   

                this.objects = tmpObjects
                this.states = states
            }

        } else {
            const schema = await this.load(this.baseURL + "/" + this.containerId + ".json")
            if (schema) {
                let states: Map<string, VibeAnimationState> = new Map<string, VibeAnimationState>();

                let tmpObjects: Map<string, VibeObjectSchema> = new Map<string, VibeObjectSchema>();
                if (schema?.objects) {
                    for (const object of schema?.objects) {
                        tmpObjects.set(object.id, { 
                            id: object.id,
                            width: object.width,
                            height: object.height,
                            position: object.position,
                            color: object.color,
                            zIndex: object.zIndex,
                            shape: object.shape,
                            animation: object.animation
                        });
                        
                        states.set(object.id, {
                            id: object.id,
                            trigger: object.animation.invokeType === VibeAnimationInvokeType.trigger ? false : null,
                            isCancelled: false
                        })
                    }   

                    this.objects = tmpObjects
                    this.states = states
                }
            }
        }

    }

    private baseURL: string
    private containerId: string
    public objects: Map<string, VibeObjectSchema>|null
    private states: Map<string, VibeAnimationState>|null
    private canvasSizes: Map<string, VibeCanvasSize>|null

    constructor(containerId: string, baseURL: string) {
        this.containerId = containerId
        this.baseURL = baseURL
        this.objects = null
        this.states = null
        this.canvasSizes = null
    }
    
    public getId(): string {
        return this.containerId
    }

    public getCanvasSizes(): Map<string, VibeCanvasSize>|null {
        return this.canvasSizes
    }
}
