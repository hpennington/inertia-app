export interface VibeSchema {
    id: string;
    objects: Array<VibeShape>;
}

export type VibeCanvasSize = {
    width: number;
    height: number;
}

export enum MessageType {
    actionable = "actionable",
    actionables = "actionables",
    schema = "schema",
}

export interface MessageWrapper<T = any> {
    type: MessageType;
    payload: T;
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

export type VibeShape = {
    id: string;
    container: AnimationContainer;
    width: number;
    height: number;
    position: {x: number, y: number};
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
    public containerId: string;
    public vibeSchema: VibeSchema;
    public tree: Tree;
    public actionableIds: Set<string>;
    public states: Map<string, VibeAnimationState>;
    public actionableIdToAnimationIdMap: Map<string, string>;
    public isActionable: boolean = false

    constructor(containerId: string, vibeSchema: VibeSchema, tree: Tree, actionableIds: Set<string>) {
        this.containerId = containerId;
        this.vibeSchema = vibeSchema;
        this.tree = tree;
        this.actionableIds = actionableIds;
        this.states = new Map<string, VibeAnimationState>();
        this.actionableIdToAnimationIdMap = new Map<string, string>();
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

        this.addRelationship = this.addRelationship.bind(this)
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

export type VibeSchemaWrapper = {
    schema: VibeSchema;
    actionableId: VibeID;
    container: AnimationContainer;
    animationId: string;
};

function base64Encode(str: string): string {
    // Convert UTF-8 string to bytes
    const bytes = new TextEncoder().encode(str);
    // Convert bytes to binary string
    let binary = '';
    bytes.forEach((b) => binary += String.fromCharCode(b));
    // Base64 encode
    return btoa(binary);
}

export interface MessageActionables {
    tree: Tree;
    actionableIds: string[]; // Use array for JSON compatibility
}

export interface MessageActionable {
    isActionable: boolean;
}

export interface MessageSchema {
    schemaWrappers: VibeSchemaWrapper[];
}

export class WebSocketClient {
    private static instance: WebSocketClient;
    private socket: WebSocket | null = null;
    public isConnected = false;

    public messageReceived?: (selectedIds: Set<string>) => void;
    public messageReceivedSchema?: (schemas: VibeSchemaWrapper[]) => void;
    public messageReceivedIsActionable?: (isActionable: boolean) => void;

    private constructor() {}

    public static get shared(): WebSocketClient {
        if (!WebSocketClient.instance) {
            WebSocketClient.instance = new WebSocketClient();
        }
        return WebSocketClient.instance;
    }

    public connect(uri: string, onConnect: () => void): void {
        if (this.isConnected == true) {
            return
        }

        this.socket = new WebSocket(uri);

        this.socket.onopen = () => {
            this.isConnected = true;
            console.log("WebSocket connected");
            onConnect()
        };

        this.socket.onmessage = (event: MessageEvent) => {
            this.handleMessage(event.data);
        };

        this.socket.onerror = (error) => {
            console.error("WebSocket error:", error);
        };

        this.socket.onclose = () => {
            this.isConnected = false;
            console.log("WebSocket disconnected");
        };
    }

    // private send(data: any): void {
    //     if (this.socket && this.isConnected) {
    //         // // 1️⃣ Encode payload as JSON string
    //         const payloadStr = JSON.stringify(data);

    //         // // 2️⃣ Convert to base64
    //         const base64Payload = btoa(payloadStr);

    //         // // 3️⃣ Wrap in type wrapper
    //         const wrapper = { type: data.type, payload: base64Payload };

    //         this.socket.send(JSON.stringify(wrapper));
    //         // this.socket.send(base64Payload);

    //         console.log("Message sent:", data);
    //     } else {
    //         console.error("WebSocket is not connected");
    //     }
    // }

    private send(data: any): void {
        if (this.socket && this.isConnected) {
            // 1️⃣ Wrap payload in type wrapper
            const wrapper = {
                type: data.type,
                payload: data.payload // Keep as object
            };

            // 2️⃣ Encode the full wrapper as JSON string
            this.socket.send(JSON.stringify(wrapper));

            console.log("Message sent:", wrapper);
        } else {
            console.error("WebSocket is not connected");
        }
    }

    public sendMessageActionables(message: MessageActionables): void {
        if (!this.socket || !this.isConnected) {
            console.error("WebSocket is not connected");
            return;
        }

        // Build message wrapper with payload as object (not string)
        const messageWrapper: MessageWrapper<string> = {
            type: MessageType.actionables,
            payload: base64Encode(JSON.stringify(message))
        };

        let json = JSON.stringify(messageWrapper)

        try {
            // Send the full wrapper as JSON string
            this.socket.send(json);

            console.log("✅ Message sent:", messageWrapper);
        } catch (error) {
            console.error("❌ Error sending message:", error);
        }
    }

    public sendMessageSchema(message: MessageSchema): void {
        const wrapper: MessageWrapper = {
            type: MessageType.schema,
            payload: message
        };
        this.send(wrapper);
    }

    private async handleMessage(rawData: any): Promise<void> {
        try {
            let text: string;

            if (typeof rawData === "string") {
                text = rawData;
            } else if (rawData instanceof Blob) {
                text = await rawData.text();
            } else if (rawData instanceof ArrayBuffer) {
                text = new TextDecoder().decode(rawData);
            } else {
                throw new Error("Unsupported message format");
            }

            const messageWrapper: MessageWrapper<string> = JSON.parse(text);

            // Decode Base64 payload
            const payloadJson = atob(messageWrapper.payload);
            const payload = JSON.parse(payloadJson);

            switch (messageWrapper.type) {
                case MessageType.actionable:
                    const actionableMessage: MessageActionable = payload;
                    console.log("[INERTIA_LOG]: Received actionable:", actionableMessage);
                    this.messageReceivedIsActionable?.(actionableMessage.isActionable);
                    break;

                case MessageType.actionables:
                    const msg: MessageActionables = payload;
                    console.log("[INERTIA_LOG]: Received actionables:", msg);
                    this.messageReceived?.(new Set(msg.actionableIds));
                    break;

                case MessageType.schema:
                    const schemaMessage: MessageSchema = payload;
                    console.log("[INERTIA_LOG]: Received schema:", schemaMessage);
                    this.messageReceivedSchema?.(schemaMessage.schemaWrappers);
                    break;

                default:
                    console.warn("Unknown message type:", messageWrapper.type);
            }
        } catch (error) {
            console.error("❌ Error parsing message:", error, rawData);
        }
    }

}