import React from 'react'
import {InertiaAnimationSchema, MessageTranslation, MessageActionables, MessageActionable, InertiaSchemaWrapper, InertiaAnimationInvokeType, WebSocketClient, InertiaDataModel, InertiaCanvasSize, MessageType, MessageWrapper, InertiaID, Tree, Node} from 'inertia-base'

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

// --- MessageSelected ---
export type MessageSelected = {
    selectedIds: Set<string>;
};

// --- MessageSchema ---
export type MessageSchema = {
    schemaWrappers: Array<InertiaSchemaWrapper>;
};

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

// --- InertiaAnimationKeyframe ---
export type InertiaAnimationKeyframe = {
    id: InertiaID;
    values: InertiaAnimationValues;
    duration: number;
};

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
        console.log(
            `[INERTIA_LOG]: [handleMessageSchema] wrapper - containerId: ${schemaWrapper.container.containerId}, actionableId: ${schemaWrapper.actionableId}, animationId: ${schemaWrapper.animationId}`
        );
        console.log(`[INERTIA_LOG]: [handleMessageSchema] my containerId: ${inertiaDataModel.containerId}`);

        if (schemaWrapper.container.containerId === inertiaDataModel.containerId) {
            setInertiaDataModel(prev => {
                const updated = { ...prev };

                // Store the mapping from actionable ID to animation ID
                updated.actionableIdToAnimationIdMap.set(schemaWrapper.actionableId, schemaWrapper.animationId);
                // Store the schema by its animation ID
                updated.inertiaSchemas.set(schemaWrapper.animationId, schemaWrapper.schema);

                console.log(
                    `[INERTIA_LOG]: ✅ stored schema - animationId: ${schemaWrapper.animationId} actionableId: ${schemaWrapper.actionableId}`
                );
                console.log(`[INERTIA_LOG]: map now:`, Object.fromEntries(updated.actionableIdToAnimationIdMap));

                return updated;
            });
        } else {
            console.log(`[INERTIA_LOG]: ❌ skipped - container mismatch`);
        }
    }
}

export const InertiaContainer = ({ children, id, baseURL, dev }: InertiaContainerProps): React.ReactElement => {
    const [inertiaDataModel, setInertiaDataModel] = React.useState(
        new InertiaDataModel(id, new Map(), new Tree(id), new Set())
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

    useEffect(() => {
      const element = containerRef.current;
      if (!element || !inertiaDataModel || !hierarchyId || !inertiaCanvasSize)
        return;

      console.log(`[INERTIA_LOG]: [InertiaableGuts.animation] hierarchyId: ${hierarchyId}`);
      console.log(`[INERTIA_LOG]: [InertiaableGuts.animation] actionableIdToAnimationIdMap:`, Object.fromEntries(inertiaDataModel.actionableIdToAnimationIdMap));
      console.log(`[INERTIA_LOG]: [InertiaableGuts.animation] available schema IDs:`, Array.from(inertiaDataModel.inertiaSchemas.keys()));

      // First try to get the animation ID from the map
      const animationId = inertiaDataModel.actionableIdToAnimationIdMap.get(hierarchyId);
      if (!animationId) {
        console.log(`[INERTIA_LOG]: no mapping for hierarchyId: ${hierarchyId}`);
        return;
      }

      // Look up the animation using the mapped animation ID
      const schema = inertiaDataModel.inertiaSchemas.get(animationId);
      if (!schema) {
        console.log(`[INERTIA_LOG]: animation not found for animationId: ${animationId}`);
        return;
      }

      console.log(`[INERTIA_LOG]: found animation - hierarchyId: ${hierarchyId} -> animationId: ${animationId}`);

      const keyframesWebAPI = [
        schema.initialValues,
        ...(schema.keyframes || []).map((k) => k.values),
      ].map((values) => {
        const tx = values.translate[0];
        const ty = values.translate[1];

        return {
          transform: `
            translateX(${tx * inertiaCanvasSize.width}px)
            translateY(${ty * inertiaCanvasSize.height}px)
            rotate(${values.rotateCenter}deg)
            scale(${values.scale})
          `,
          transformOrigin: "center",
          opacity: values.opacity,
        };
      });

      const totalDuration =
        (schema.keyframes || []).reduce(
          (acc, k) => acc + k.duration * 1000,
          0
        ) || 1000;

      console.log("[INERTIA_LOG] Running animation:", keyframesWebAPI);

      const animationHandle = element.animate(keyframesWebAPI, {
        duration: totalDuration,
        iterations: Infinity,
        easing: "ease-in-out",
      });

      return () => animationHandle.cancel();
    }, [
      hierarchyId,
      inertiaDataModel,
      inertiaCanvasSize,
    ]);

    return (
      <div
        data-inertia-id={hierarchyId}
        ref={containerRef}
        onClick={onClick}
        style={{
          display: "inline-block",
          cursor: "pointer",
          position: "relative",
        }}
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
    setPos({x: 0, y: 0});
  }, [inertiaDataModel])

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