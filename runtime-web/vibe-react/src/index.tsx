import React from 'react'
import {VibeSchema, MessageTranslation, MessageActionables, MessageActionable, VibeSchemaWrapper, VibeAnimationInvokeType, WebSocketClient, VibeDataModel, VibeCanvasSize, MessageType, MessageWrapper, VibeID, VibeShape, Tree, Node, VibeAnimationSchema} from 'vibe-base'

export type VibeContainerProps = {
    children: React.ReactElement,
    id: string,
    baseURL: string,
    dev: boolean,
}

export type VibeableProps = {
    children: React.ReactElement,
    hierarchyIdPrefix: string,
}

export type VibeActionableProps = {
    children: React.ReactElement,
    id: string,
}

type VibeContextType = {
    vibeDataModel: VibeDataModel;
    setVibeDataModel: React.Dispatch<React.SetStateAction<VibeDataModel>>;
};

const VibeContext = React.createContext<VibeContextType | undefined>(undefined);

const useVibeDataModel = (): VibeContextType => {
    const context = React.useContext(VibeContext);
    if (!context) {
        throw new Error('useVibeDataModel must be used within a VibeContext.Provider');
    }
    return context;
};

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

// Helper to convert JSON received from WebSocket into MessageActionables
export function messageActionablesFromJSON(json: any): MessageActionables {
    return {
        tree: Tree.fromJSON(json.tree),                // convert tree JSON to Tree instance
        actionableIds: new Array<string>(json.actionableIds) // convert array to Set
    };
}

// Helper to convert MessageActionables to JSON for sending over WebSocket
export function messageActionablesToJSON(msg: MessageActionables): any {
    return {
        tree: msg.tree.toJSON(),               // convert Tree instance to JSON
        actionableIds: Array.from(msg.actionableIds) // convert Set to array
    };
}

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
    schemaWrappers: Array<VibeSchemaWrapper>;
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

export function vibeShapeFromJSON(json: {
    id: string, container: AnimationContainer, width: number, height: number, position: {x: number, y: number}, color: number[], shape: string, zIndex: number, animation: VibeAnimationSchema}
): VibeShape {
    return {
        id: json.id,
        container: json.container,
        width: json.width,
        height: json.height,
        position: { x: json.position.x, y: json.position.y },
        color: json.color,
        shape: json.shape,
        zIndex: json.zIndex,
        animation: json.animation,
    };
}

export function vibeShapeToJSON(shape: VibeShape): any {
    return {
        id: shape.id,
        containerId: shape.id,
        width: shape.width,
        height: shape.height,
        position: { x: shape.position.x, y: shape.position.y },
        color: shape.color,
        shape: shape.shape,
        objectType: "",
        zIndex: shape.zIndex,
        animation: shape.animation,
    };
}

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

export function vibeAnimationSchemaFromJSON(json: any): VibeAnimationSchema {
    return {
        id: json.id,
        initialValues: json.initialValues,
        invokeType: json.invokeType as VibeAnimationInvokeType,
        keyframes: (json.keyframes ?? []).map(vibeAnimationKeyframeFromJSON),
    };
}

// export function vibeAnimationSchemaToJSON(schema: VibeAnimationSchema): any {
//     return {
//         id: schema.id,
//         initialValues: schema.initialValues,
//         invokeType: schema.invokeType,
//         keyframes: schema.keyframes.map(vibeAnimationKeyframeToJSON),
//     };
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

function handleMessageSchema(
    schemaWrappers: VibeSchemaWrapper[],
    vibeDataModel: VibeDataModel | null,
    setVibeDataModel: React.Dispatch<React.SetStateAction<VibeDataModel>>
): void {
    if (!vibeDataModel) return;

    for (const schemaWrapper of schemaWrappers) {
        if (schemaWrapper.container.containerId === vibeDataModel.containerId) {
            setVibeDataModel(prev => {
                const updated = { ...prev };

                // Update schema
                updated.vibeSchema = schemaWrapper.schema;

                // Update actionableId -> animationId map
                updated.actionableIdToAnimationIdMap.set(schemaWrapper.actionableId, schemaWrapper.animationId)

                console.log(
                    `[INERTIA_LOG]: animationId: ${schemaWrapper.animationId} actionableId: ${schemaWrapper.actionableId}`
                );

                return updated;
            });
        }
    }
}

export const VibeContainer = ({ children, id, baseURL, dev }: VibeContainerProps): React.ReactElement => {
    const [vibeDataModel, setVibeDataModel] = React.useState(
        new VibeDataModel(id, { id: id, objects: [] }, new Tree(id), new Set())
    );
    const [bounds, setBounds] = React.useState<VibeCanvasSize | null>(null);
    const ref = React.useRef<HTMLDivElement | null>(null);

    React.useEffect(() => {
        if (!ref.current) return;

        const observer = new ResizeObserver((entries) => {
            for (let entry of entries) {
                const { width, height } = entry.contentRect;
                setBounds({ width, height });
            }
        });

        observer.observe(ref.current);

        return () => {
            observer.disconnect();
        };
    }, []); // only run once

    // ✅ WebSocket logic stays the same
    React.useEffect(() => {
        const ws = WebSocketClient.shared;
        if (!vibeDataModel?.tree) return;

        ws.connect("ws://127.0.0.1:8080", () => {
            ws.messageReceived = (msg) => {
                setVibeDataModel(prev => ({ ...prev, actionableIds: msg }));
            };

            ws.messageReceivedSchema = (msg) => {
                handleMessageSchema(msg, vibeDataModel, setVibeDataModel)
            };

            ws.messageReceivedIsActionable = (msg) => {
                setVibeDataModel(prev => ({ ...prev, isActionable: msg }));
            };

            ws.sendMessageActionables({
                tree: vibeDataModel.tree,
                actionableIds: Array.from(vibeDataModel.actionableIds),
            });
        });
    }, [vibeDataModel?.tree]);

    return (
        <VibeCanvasSizeContext.Provider value={bounds}>
            <div data-vibe-container-id={id} ref={ref}>
                <VibeContext.Provider value={{ vibeDataModel, setVibeDataModel }}>
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


import { useState, useRef, useMemo, useCallback, useContext, useEffect } from "react";

const VibeCanvasSizeContext = React.createContext<VibeCanvasSize | null>(null)
const manager = WebSocketClient.shared

// ------------------ Draggable Props ------------------
export interface DraggableProps {
  hierarchyId?: string;
  isSelected: boolean;
  actionableIds?: Set<string>;
  containerRef: React.RefObject<HTMLDivElement>;
  children: React.ReactNode;
  handleClick: () => void;
  vibeDataModel?: VibeDataModel;
  moved?: React.MutableRefObject<boolean>;
}

// ------------------ HOC ------------------
export function withDrag<T extends DraggableProps>(WrappedComponent: React.ComponentType<T>) {
  return function Draggable(props: T) {
    const { isSelected, actionableIds } = props;
    const [pos, setPos] = useState({ x: 0, y: 0 });
    const dragging = useRef(false);
    const moved = useRef(false);
    const offset = useRef({ x: 0, y: 0 });

    const startDrag = (clientX: number, clientY: number) => {
      if (!isSelected) return;
      dragging.current = true;
      moved.current = false;
      offset.current = { x: clientX - pos.x, y: clientY - pos.y };
    };

    const doDrag = (clientX: number, clientY: number) => {
      if (!dragging.current) return;
      const dx = clientX - offset.current.x - pos.x;
      const dy = clientY - offset.current.y - pos.y;
      if (Math.abs(dx) > 2 || Math.abs(dy) > 2) moved.current = true;
      setPos({ x: clientX - offset.current.x, y: clientY - offset.current.y });
    };

    const vibeCanvasSize = useContext(VibeCanvasSizeContext);

    const stopDrag = () => {
      if (dragging.current && actionableIds && vibeCanvasSize) {
        manager.sendMessageTranslation({
          actionableIds: Array.from(actionableIds),
          translationX: pos.x / vibeCanvasSize.width,
          translationY: pos.y / vibeCanvasSize.height,
        });
      }
      dragging.current = false;
    };

    const handleClickCapture = (e: React.MouseEvent) => {
      if (moved.current) {
        e.stopPropagation();
        e.preventDefault();
      }
    };

    const transformStyle = `translate(${pos.x}px, ${pos.y}px)`;

    return (
      <div
        onMouseMove={(e) => { e.stopPropagation(); doDrag(e.clientX, e.clientY); }}
        onMouseUp={(e) => { e.stopPropagation(); stopDrag(); }}
        onTouchMove={(e) => { e.stopPropagation(); e.preventDefault(); doDrag(e.touches[0].clientX, e.touches[0].clientY); }}
        onTouchEnd={(e) => { e.stopPropagation(); e.preventDefault(); stopDrag(); }}
        onMouseDown={(e) => { e.stopPropagation(); startDrag(e.clientX, e.clientY); }}
        onTouchStart={(e) => { e.stopPropagation(); e.preventDefault(); startDrag(e.touches[0].clientX, e.touches[0].clientY); }}
        onClickCapture={handleClickCapture}
        style={{
          transform: transformStyle,
          cursor: isSelected ? "grab" : "default",
          touchAction: "none",
          willChange: "transform",
        }}
      >
        <WrappedComponent {...props} moved={moved} />
      </div>
    );
  };
}

// ------------------ VibeableGuts ------------------
const VibeableGuts: React.FC<DraggableProps> = React.memo(
  ({ hierarchyId, handleClick, isSelected, containerRef, children, vibeDataModel, moved }) => {
    const onClick = (e: React.MouseEvent) => {
      if (!moved?.current) handleClick();
    };

    const vibeCanvasSize = useContext(VibeCanvasSizeContext);

    // Keyframe animation
    useEffect(() => {
      if (!containerRef.current || !vibeDataModel || !hierarchyId || !vibeCanvasSize) return;
      const animationId = vibeDataModel.actionableIdToAnimationIdMap?.get(hierarchyId);
      const animation = vibeDataModel.vibeSchema?.objects.find(obj => obj.animation?.id === animationId)?.animation;
      if (!animation) return;

      const keyframesWebAPI = [animation.initialValues, ...(animation.keyframes || []).map(k => k.values)].map(values => ({
        transform: `translateX(${values.translate[0] * vibeCanvasSize.width}px) translateY(${values.translate[1] * vibeCanvasSize.height}px) rotate(${values.rotateCenter}deg) scale(${values.scale})`,
        transformOrigin: "center",
        opacity: values.opacity,
      }));

      const totalDuration = (animation.keyframes || []).reduce((acc, k) => acc + k.duration * 1000, 0) || 1000;
      containerRef.current.animate(keyframesWebAPI, {
        duration: totalDuration,
        iterations: Infinity,
        easing: "ease-in-out",
      });
    }, [containerRef, vibeDataModel, hierarchyId]);

    return (
      <div
        data-vibe-id={hierarchyId}
        ref={containerRef}
        onClick={onClick}
        style={{ display: "inline-block", cursor: "pointer", position: "relative" }}
      >
        {children}
        {isSelected && vibeDataModel?.isActionable && (
          <div
            style={{
              position: "absolute",
              top: 0,
              left: 0,
              right: 0,
              bottom: 0,
              border: "3px solid rgb(85, 89, 220)",
              borderRadius: 8,
              pointerEvents: "none",
            }}
          />
        )}
      </div>
    );
  }
);

export const DraggableVibeableGuts = React.memo(withDrag(VibeableGuts));

// ------------------ Vibeable ------------------
export const Vibeable: React.FC<VibeableProps> = ({ children, hierarchyIdPrefix }) => {
  const { vibeDataModel, setVibeDataModel } = useContext(VibeContext)!;
  const vibeParentId = useContext(VibeParentIdContext)!;
  const vibeIsContainer = useContext(VibeIsContainerContext)!;
  const indexManager = SharedIndexManager.shared;
  const containerRef = useRef<HTMLDivElement>(null);

  const [hierarchyId, setHierarchyId] = useState<string>();

  useEffect(() => {
    const indexValue = indexManager.indexMap[hierarchyIdPrefix] ?? 0;
    const newId = `${hierarchyIdPrefix}--${indexValue}`;
    indexManager.indexMap[hierarchyIdPrefix] = indexValue + 1;
    setHierarchyId(newId);
  }, [hierarchyIdPrefix]);

  useEffect(() => {
    if (hierarchyId) {
      vibeDataModel?.tree.addRelationship(hierarchyId, vibeParentId, vibeIsContainer);
    }
  }, [hierarchyId, vibeParentId, vibeIsContainer]);

  const isSelected = hierarchyId ? vibeDataModel?.actionableIds.has(hierarchyId) ?? false : false;

  const handleClick = () => {
      if (!hierarchyId || !vibeDataModel?.isActionable) return;

      const newActionableIds = new Set(vibeDataModel.actionableIds);
      if (newActionableIds.has(hierarchyId)) {
        newActionableIds.delete(hierarchyId);
      } else {
        newActionableIds.add(hierarchyId);
      }

      // Update UI immediately
      setVibeDataModel(prev => ({ ...prev, actionableIds: newActionableIds }));
      
      // Sync to server separately (maybe debounced)
      manager.sendMessageActionables({ 
        tree: vibeDataModel.tree, 
        actionableIds: Array.from(newActionableIds)
      });
    }

  return (
    <DraggableVibeableGuts
      key={hierarchyId}
      hierarchyId={hierarchyId}
      handleClick={handleClick}
      isSelected={isSelected}
      containerRef={containerRef}
      children={children}
      vibeDataModel={vibeDataModel}
      actionableIds={vibeDataModel?.actionableIds}
    />
  );
};