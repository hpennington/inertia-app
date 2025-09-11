import React from 'react'
import {InertiaSchema, MessageTranslation, MessageActionables, MessageActionable, InertiaSchemaWrapper, InertiaAnimationInvokeType, WebSocketClient, InertiaDataModel, InertiaCanvasSize, MessageType, MessageWrapper, InertiaID, InertiaShape, Tree, Node, InertiaAnimationSchema} from 'inertia-base'

export type InertiaContainerProps = {
    children: React.ReactElement,
    id: string,
    baseURL: string,
    dev: boolean,
}

export type InertiaableProps = {
    children: React.ReactElement,
    hierarchyIdPrefix: string,
}

export type InertiaActionableProps = {
    children: React.ReactElement,
    id: string,
}

type InertiaContextType = {
    inertiaDataModel: InertiaDataModel;
    setInertiaDataModel: React.Dispatch<React.SetStateAction<InertiaDataModel>>;
};

const InertiaContext = React.createContext<InertiaContextType | undefined>(undefined);

const useInertiaDataModel = (): InertiaContextType => {
    const context = React.useContext(InertiaContext);
    if (!context) {
        throw new Error('useInertiaDataModel must be used within a InertiaContext.Provider');
    }
    return context;
};

const InertiaParentIdContext = React.createContext<string|undefined>(undefined)


const useInertiaParentId = () => {
    const inertiaParentId = React.useContext(InertiaParentIdContext)

    if (!inertiaParentId) {
        throw new Error('useInertiaParentId must be used within a InertiaContext.Provider')
    }

    return inertiaParentId
}

const InertiaContainerIdContext = React.createContext<string|undefined>(undefined)


const useInertiaContainerId = () => {
    const inertiaContainerId = React.useContext(InertiaContainerIdContext)

    if (!inertiaContainerId) {
        throw new Error('useInertiaContainerId must be used within a InertiaContainerIdContext.Provider')
    }

    return inertiaContainerId
}

const InertiaIsContainerContext = React.createContext<boolean>(false)


const useInertiaIsContainer = () => {
    const inertiaIsContainer = React.useContext(InertiaIsContainerContext)

    if (!inertiaIsContainer) {
        throw new Error('useInertiaIsContainer must be used within a InertiaIsContainerContext.Provider')
    }

    return inertiaIsContainer
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
    schemaWrappers: Array<InertiaSchemaWrapper>;
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
export enum InertiaObjectType {
    Shape = "shape",
    Animation = "animation",
}

// --- AnimationContainer ---
export type AnimationContainer = {
    actionableId: InertiaID;
    containerId: InertiaID;
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

export function inertiaShapeFromJSON(json: {
    id: string, container: AnimationContainer, width: number, height: number, position: {x: number, y: number}, color: number[], shape: string, zIndex: number, animation: InertiaAnimationSchema}
): InertiaShape {
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

export function inertiaShapeToJSON(shape: InertiaShape): any {
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

export function inertiaSchemaFromJSON(json: any): InertiaSchema {
    return {
        id: json.id,
        objects: (json.objects ?? []).map(inertiaShapeFromJSON),
    };
}

export function inertiaSchemaToJSON(schema: InertiaSchema): any {
    return {
        id: schema.id,
        objects: schema.objects.map(inertiaShapeToJSON),
    };
}

export function inertiaSchemaWrapperFromJSON(json: any): InertiaSchemaWrapper {
    return {
        schema: inertiaSchemaFromJSON(json.schema),
        actionableId: json.actionableId,
        container: animationContainerFromJSON(json.container),
        animationId: json.animationId,
    };
}

export function inertiaSchemaWrapperToJSON(wrapper: InertiaSchemaWrapper): any {
    return {
        schema: inertiaSchemaToJSON(wrapper.schema),
        actionableId: wrapper.actionableId,
        container: animationContainerToJSON(wrapper.container),
        animationId: wrapper.animationId,
    };
}


// --- InertiaAnimationValues ---
export type InertiaAnimationValues = {
    scale: number;
    translate: CGSize;
    rotate: number;
    rotateCenter: number;
    opacity: number;
};

// Zero value constant
export const zeroInertiaAnimationValues: InertiaAnimationValues = {
    scale: 0,
    translate: { width: 0, height: 0 },
    rotate: 0,
    rotateCenter: 0,
    opacity: 0,
};

// Arithmetic helpers
export function addInertiaAnimationValues(
    a: InertiaAnimationValues,
    b: InertiaAnimationValues
): InertiaAnimationValues {
    return {
        scale: a.scale + b.scale,
        translate: { width: a.translate.width + b.translate.width, height: a.translate.height + b.translate.height },
        rotate: a.rotate + b.rotate,
        rotateCenter: a.rotateCenter + b.rotateCenter,
        opacity: a.opacity + b.opacity,
    };
}

export function subtractInertiaAnimationValues(
    a: InertiaAnimationValues,
    b: InertiaAnimationValues
): InertiaAnimationValues {
    return {
        scale: a.scale - b.scale,
        translate: { width: a.translate.width - b.translate.width, height: a.translate.height - b.translate.height },
        rotate: a.rotate - b.rotate,
        rotateCenter: a.rotateCenter - b.rotateCenter,
        opacity: a.opacity - b.opacity,
    };
}

export function scaleInertiaAnimationValues(v: InertiaAnimationValues, factor: number): InertiaAnimationValues {
    return {
        scale: v.scale * factor,
        translate: { width: v.translate.width * factor, height: v.translate.height * factor },
        rotate: v.rotate * factor,
        rotateCenter: v.rotateCenter * factor,
        opacity: v.opacity * factor,
    };
}

// --- InertiaAnimationKeyframe ---
export type InertiaAnimationKeyframe = {
    id: InertiaID;
    values: InertiaAnimationValues;
    duration: number;
};

export function inertiaAnimationKeyframeFromJSON(json: any): InertiaAnimationKeyframe {
    return {
        id: json.id,
        values: json.values,
        duration: json.duration,
    };
}

export function inertiaAnimationKeyframeToJSON(keyframe: InertiaAnimationKeyframe): any {
    return {
        id: keyframe.id,
        values: keyframe.values,
        duration: keyframe.duration,
    };
}

export function inertiaAnimationSchemaFromJSON(json: any): InertiaAnimationSchema {
    return {
        id: json.id,
        initialValues: json.initialValues,
        invokeType: json.invokeType as InertiaAnimationInvokeType,
        keyframes: (json.keyframes ?? []).map(inertiaAnimationKeyframeFromJSON),
    };
}

// export function inertiaAnimationSchemaToJSON(schema: InertiaAnimationSchema): any {
//     return {
//         id: schema.id,
//         initialValues: schema.initialValues,
//         invokeType: schema.invokeType,
//         keyframes: schema.keyframes.map(inertiaAnimationKeyframeToJSON),
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
    schemaWrappers: InertiaSchemaWrapper[],
    inertiaDataModel: InertiaDataModel | null,
    setInertiaDataModel: React.Dispatch<React.SetStateAction<InertiaDataModel>>
): void {
    if (!inertiaDataModel) return;

    for (const schemaWrapper of schemaWrappers) {
        if (schemaWrapper.container.containerId === inertiaDataModel.containerId) {
            setInertiaDataModel(prev => {
                const updated = { ...prev };

                // Update schema
                updated.inertiaSchema = schemaWrapper.schema;

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

export const InertiaContainer = ({ children, id, baseURL, dev }: InertiaContainerProps): React.ReactElement => {
    const [inertiaDataModel, setInertiaDataModel] = React.useState(
        new InertiaDataModel(id, { id: id, objects: [] }, new Tree(id), new Set())
    );
    const [bounds, setBounds] = React.useState<InertiaCanvasSize | null>(null);
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
        if (!inertiaDataModel?.tree) return;

        ws.connect("ws://127.0.0.1:8080", () => {
            ws.messageReceived = (msg) => {
                setInertiaDataModel(prev => ({ ...prev, actionableIds: msg }));
            };

            ws.messageReceivedSchema = (msg) => {
                handleMessageSchema(msg, inertiaDataModel, setInertiaDataModel)
            };

            ws.messageReceivedIsActionable = (msg) => {
                setInertiaDataModel(prev => ({ ...prev, isActionable: msg }));
            };

            ws.sendMessageActionables({
                tree: inertiaDataModel.tree,
                actionableIds: Array.from(inertiaDataModel.actionableIds),
            });
        });
    }, [inertiaDataModel?.tree]);

    return (
        <InertiaCanvasSizeContext.Provider value={bounds}>
            <div data-inertia-container-id={id} ref={ref}>
                <InertiaContext.Provider value={{ inertiaDataModel, setInertiaDataModel }}>
                    <InertiaParentIdContext.Provider value={id}>
                        <InertiaContainerIdContext.Provider value={id}>
                            <InertiaIsContainerContext.Provider value={true}>
                                {children}
                            </InertiaIsContainerContext.Provider>
                        </InertiaContainerIdContext.Provider>
                    </InertiaParentIdContext.Provider>
                </InertiaContext.Provider>
            </div>
        </InertiaCanvasSizeContext.Provider>
    );
};


import { useState, useRef, useMemo, useCallback, useContext, useEffect } from "react";

const InertiaCanvasSizeContext = React.createContext<InertiaCanvasSize | null>(null)
const manager = WebSocketClient.shared

// ------------------ Draggable Props ------------------
export interface DraggableProps {
  hierarchyId?: string;
  isSelected: boolean;
  actionableIds?: Set<string>;
  containerRef: React.RefObject<HTMLDivElement>;
  children: React.ReactNode;
  handleClick: () => void;
  inertiaDataModel?: InertiaDataModel;
  pos: { x: number; y: number };
  setPos: React.Dispatch<React.SetStateAction<{ x: number; y: number }>>;
  moved?: React.MutableRefObject<boolean>;
}

// ------------------ HOC ------------------
export interface DraggableInjectedProps {
  pos: { x: number; y: number };
  setPos: React.Dispatch<React.SetStateAction<{ x: number; y: number }>>;
  moved: React.MutableRefObject<boolean>;
}

export function withDrag<T extends DraggableProps>(
  WrappedComponent: React.ComponentType<T & Partial<DraggableInjectedProps>>
) {
  return function Draggable(props: T & { pos: { x: number; y: number }; setPos: React.Dispatch<React.SetStateAction<{ x: number; y: number }>> }) {
    const { isSelected, actionableIds, pos, setPos } = props;
    const dragging = useRef(false);
    const moved = useRef(false);
    const offset = useRef({ x: 0, y: 0 });

    const inertiaCanvasSize = useContext(InertiaCanvasSizeContext);

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

    const stopDrag = () => {
      if (dragging.current && actionableIds && inertiaCanvasSize) {
        manager.sendMessageTranslation({
          actionableIds: Array.from(actionableIds),
          translationX: pos.x / inertiaCanvasSize.width,
          translationY: pos.y / inertiaCanvasSize.height,
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
        onPointerDown={(e) => {
          e.stopPropagation();
          if (isSelected) {
            (e.currentTarget as HTMLElement).setPointerCapture(e.pointerId);
            startDrag(e.clientX, e.clientY);
          }
        }}
        onPointerMove={(e) => {
          e.stopPropagation();
          doDrag(e.clientX, e.clientY);
        }}
        onPointerUp={(e) => {
          e.stopPropagation();
          stopDrag();
        }}
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

// ------------------ InertiaableGuts ------------------
const InertiaableGuts: React.FC<DraggableProps> = React.memo(
  ({ hierarchyId, handleClick, isSelected, containerRef, children, inertiaDataModel, moved }) => {
    const onClick = (e: React.MouseEvent) => {
      if (!moved?.current) handleClick();
    };

    const inertiaCanvasSize = useContext(InertiaCanvasSizeContext);

    // Keyframe animation
    useEffect(() => {
      if (!containerRef.current || !inertiaDataModel || !hierarchyId || !inertiaCanvasSize) return;
      const animationId = inertiaDataModel.actionableIdToAnimationIdMap?.get(hierarchyId);
      const animation = inertiaDataModel.inertiaSchema?.objects.find(obj => obj.animation?.id === animationId)?.animation;
      if (!animation) return;

      const keyframesWebAPI = [animation.initialValues, ...(animation.keyframes || []).map(k => k.values)].map(values => ({
        transform: `translateX(${values.translate[0] * inertiaCanvasSize.width}px) translateY(${values.translate[1] * inertiaCanvasSize.height}px) rotate(${values.rotateCenter}deg) scale(${values.scale})`,
        transformOrigin: "center",
        opacity: values.opacity,
      }));

      const totalDuration = (animation.keyframes || []).reduce((acc, k) => acc + k.duration * 1000, 0) || 1000;
      containerRef.current.animate(keyframesWebAPI, {
        duration: totalDuration,
        iterations: Infinity,
        easing: "ease-in-out",
      });
    }, [containerRef, inertiaDataModel, hierarchyId]);

    return (
      <div
        data-inertia-id={hierarchyId}
        ref={containerRef}
        onClick={onClick}
        style={{ display: "inline-block", cursor: "pointer", position: "relative" }}
      >
        {children}
        {isSelected && inertiaDataModel?.isActionable && (
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

export const DraggableInertiaableGuts = React.memo(withDrag(InertiaableGuts));

// ------------------ Inertiaable ------------------
export const Inertiaable: React.FC<InertiaableProps> = ({ children, hierarchyIdPrefix }) => {
  const { inertiaDataModel, setInertiaDataModel } = useContext(InertiaContext)!;
  const inertiaParentId = useContext(InertiaParentIdContext)!;
  const inertiaIsContainer = useContext(InertiaIsContainerContext)!;
  const indexManager = SharedIndexManager.shared;
  const containerRef = useRef<HTMLDivElement>(null);

  const [pos, setPos] = useState({ x: 0, y: 0 });
  const [hierarchyId, setHierarchyId] = useState<string>();

  useEffect(() => {
    const indexValue = indexManager.indexMap[hierarchyIdPrefix] ?? 0;
    const newId = `${hierarchyIdPrefix}--${indexValue}`;
    indexManager.indexMap[hierarchyIdPrefix] = indexValue + 1;
    setHierarchyId(newId);
  }, [hierarchyIdPrefix]);

  useEffect(() => {
    if (hierarchyId) {
      inertiaDataModel?.tree.addRelationship(hierarchyId, inertiaParentId, inertiaIsContainer);
    }
  }, [hierarchyId, inertiaParentId, inertiaIsContainer]);

  useEffect(() => {
    setPos({x: 0, y: 0})
  }, [inertiaDataModel?.inertiaSchema?.objects])

  const isSelected = hierarchyId ? inertiaDataModel?.actionableIds.has(hierarchyId) ?? false : false;

  const handleClick = () => {
      if (!hierarchyId || !inertiaDataModel?.isActionable) return;

      const newActionableIds = new Set(inertiaDataModel.actionableIds);
      if (newActionableIds.has(hierarchyId)) {
        newActionableIds.delete(hierarchyId);
      } else {
        newActionableIds.add(hierarchyId);
      }

      // Update UI immediately
      setInertiaDataModel(prev => ({ ...prev, actionableIds: newActionableIds }));
      
      // Sync to server separately (maybe debounced)
      manager.sendMessageActionables({ 
        tree: inertiaDataModel.tree, 
        actionableIds: Array.from(newActionableIds)
      });
    }

  return (
    <DraggableInertiaableGuts
      key={hierarchyId}
      hierarchyId={hierarchyId}
      handleClick={handleClick}
      isSelected={isSelected}
      containerRef={containerRef}
      children={children}
      inertiaDataModel={inertiaDataModel}
      actionableIds={inertiaDataModel?.actionableIds}
      pos={pos}
      setPos={setPos}
    />
  );
};