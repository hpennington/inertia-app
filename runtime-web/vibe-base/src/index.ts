export interface VibeSchema {
    id: string;
    objects: Array<VibeObjectSchema> | null;
}

export type VibeCanvasSize = {
    width: number;
    height: number;
}

export class VibeEditorSchema implements VibeSchema {
    id: string;
    objects: Array<VibeObjectSchema> | null;
    isSelected: Map<string, boolean>;
    actionableIds: Array<string>;
    pointerEvents: Map<string, any>;
    webKitUserSelect: Map<string, string | null>;
    onWindowResize: Function | null;
    animations: Map<string, any>;
    isPlaying: boolean;

    constructor(
        id: string,
        objects: Array<VibeObjectSchema> | null,
        isSelected: Map<string, boolean> = new Map(),
        actionableIds: Array<string> = [],
        pointerEvents: Map<string, any> = new Map(),
        webKitUserSelect: Map<string, string | null> = new Map(),
        onWindowResize: Function | null = null,
        animations: Map<string, any> = new Map(),
        isPlaying: boolean = false
    ) {
        this.id = id;
        this.objects = objects;
        this.isSelected = isSelected;
        this.actionableIds = actionableIds;
        this.pointerEvents = pointerEvents;
        this.webKitUserSelect = webKitUserSelect;
        this.onWindowResize = onWindowResize;
        this.animations = animations;
        this.isPlaying = isPlaying;
    }
}

export class VibeRuntimeSchema implements VibeSchema {
    id: string;
    objects: Array<VibeObjectSchema> | null;

    constructor(id: string, objects: Array<VibeObjectSchema> | null = null) {
        this.id = id;
        this.objects = objects;
    }
}

export type VibeAnimationValues = {
    scale: number;
    translate: [number, number];
    rotate: number;
    rotateCenter: number;
    opacity: number;
}

export enum VibeAnimationInvokeType {
    trigger,
    auto
}

export type VibeAnimationKeyframe = {
    values: VibeAnimationValues;
    duration: number;
}

export type VibeAnimationSchema = {
    id: string;
    initialValues: VibeAnimationValues;
    invokeType: VibeAnimationInvokeType;
    keyframes: Array<VibeAnimationKeyframe>;
}

export type AnimationContainer = {
    actionableId: string;
    containerId: string;
}

export type VibeObjectSchema = {
    id: string;
    container: AnimationContainer;
    width: number;
    height: number;
    position: number;
    color: Array<number>;
    shape: string;
    zIndex: number;
    animation: VibeAnimationSchema;
}

export type VibeAnimationState = {
    id: string;
    trigger: boolean | null;
    isCancelled: boolean;
}

export class VibeDataModel {
    private baseURL: string;
    private containerId: string;
    public objects: Map<string, VibeObjectSchema> | null = null;
    public tree: Tree
    public selectedIds: Array<string> = new Array()
    private states: Map<string, VibeAnimationState> | null = null;
    private canvasSizes: Map<string, VibeCanvasSize> | null = null;

    constructor(containerId: string, baseURL: string, tree: Tree) {
        this.containerId = containerId;
        this.baseURL = baseURL;
        this.tree = tree;
    }

    public getId(): string {
        return this.containerId;
    }

    public getCanvasSizes(): Map<string, VibeCanvasSize> | null {
        return this.canvasSizes;
    }

    public async load(path: string): Promise<VibeSchema | null> {
        const res = await fetch(path);
        if (res.body) return await res.json();
        return null;
    }

    public async init() {
        if (this.objects) return;

        const schema = await this.load(`${this.baseURL}/${this.containerId}.json`);
        if (!schema?.objects) return;

        const tmpObjects = new Map<string, VibeObjectSchema>();
        const states = new Map<string, VibeAnimationState>();

        for (const obj of schema.objects) {
            tmpObjects.set(obj.id, obj);
            states.set(obj.id, {
                id: obj.id,
                trigger: obj.animation.invokeType === VibeAnimationInvokeType.trigger ? false : null,
                isCancelled: false
            });
        }

        this.objects = tmpObjects;
        this.states = states;
    }
}

export type VibeID = string;

export class Node {
    public id: string;
    public parent?: Node;
    public children: Node[] = [];
    public parentId?: string;
    public tree?: Tree;

    constructor(id: string, parentId?: string) {
        this.id = id;
        this.parentId = parentId;
    }

    addChild(child: Node) {
        child.parent = this;
        child.parentId = this.id;
        this.children.push(child);
    }

    link() {
        if (this.parentId && this.tree) {
            this.parent = this.tree.nodeMap.get(this.parentId);
        }
        this.children.forEach(child => child.link());
    }

    // Encode to plain object for JSON serialization
    toJSON(): any {
        return {
            id: this.id,
            parentId: this.parentId,
            children: this.children.map(child => child.toJSON())
        };
    }

    // Decode from plain object
    static fromJSON(json: any, tree?: Tree): Node {
        const node = new Node(json.id, json.parentId);
        node.tree = tree;
        node.children = (json.children ?? []).map((c: any) => Node.fromJSON(c, tree));
        return node;
    }

    equals(other: Node): boolean {
        return this.id === other.id;
    }

    toString(): string {
        return `{id: ${this.id}, parentId: ${this.parentId}, children: [${this.children.map(c => c.id).join(", ")}]}`;
    }
}

export class Tree {
    public id: string;
    public rootNode?: Node;
    public nodeMap: Map<string, Node> = new Map();

    constructor(id: string) {
        this.id = id;
    }

    addRelationship(id: string, parentId?: string, parentIsContainer: boolean = false) {
        // Get or create current node
        let currentNode = this.nodeMap.get(id);
        if (!currentNode) {
            currentNode = new Node(id, parentId);
            currentNode.tree = this;
            this.nodeMap.set(id, currentNode);
        }

        if (parentId) {
            let parentNode = this.nodeMap.get(parentId);
            if (!parentNode) {
                parentNode = new Node(parentId);
                parentNode.tree = this;
                this.nodeMap.set(parentId, parentNode);
            }

            parentNode.addChild(currentNode);

            if (parentIsContainer || (!this.rootNode && !parentNode.parent)) {
                this.rootNode = parentNode;
            }
        }
    }

    // Encode to plain object for JSON serialization
    toJSON(): any {
        return {
            id: this.id,
            nodeMap: Object.fromEntries(
                Array.from(this.nodeMap.entries()).map(([k, v]) => [k, v.toJSON()])
            ),
            rootNode: this.rootNode?.toJSON()
        };
    }

    // Decode from plain object
    static fromJSON(json: any): Tree {
        const tree = new Tree(json.id);

        // Reconstruct nodes
        for (const [key, nodeJson] of Object.entries(json.nodeMap ?? {})) {
            const node = Node.fromJSON(nodeJson, tree);
            tree.nodeMap.set(key, node);
        }

        if (json.rootNode) {
            tree.rootNode = Node.fromJSON(json.rootNode, tree);
        }

        // Link parent references
        tree.nodeMap.forEach(node => node.link());

        return tree;
    }

    equals(other: Tree): boolean {
        return this.rootNode?.equals(other.rootNode ?? new Node("")) ?? false;
    }

    toString(): string {
        return `treeId: ${this.id}, root: ${this.rootNode}`;
    }
}
