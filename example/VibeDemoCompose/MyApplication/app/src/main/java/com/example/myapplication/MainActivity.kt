@file:Suppress("unused")
package com.example.myapplication

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.TransformOrigin
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.IntSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.launch
import kotlinx.serialization.Serializable
import kotlinx.serialization.KSerializer
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import kotlinx.serialization.encodeToString
import kotlinx.serialization.decodeFromString
import okhttp3.*
import okio.ByteString
import java.nio.charset.StandardCharsets
import java.util.*
import java.util.concurrent.TimeUnit
import java.util.regex.Pattern
import android.os.Build
import java.net.InetAddress
import java.net.NetworkInterface

fun getHostForWebSocket(defaultHost: String = "192.168.64.1"): String {
    return try {
        // In Waydroid, the default gateway usually points to the host
        val proc = Runtime.getRuntime().exec("ip route show default")
        val reader = proc.inputStream.bufferedReader()
        val output = reader.readText()
        proc.waitFor()

        // Parse: "default via 192.168.240.1 dev eth0"
        val pattern = """default via (\d+\.\d+\.\d+\.\d+)""".toRegex()
        pattern.find(output)?.groupValues?.get(1) ?: defaultHost
    } catch (e: Exception) {
        e.printStackTrace()
        defaultHost
    }
}

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                VibeContainer(
                    id = "animation",
                    baseURL = "ws://192.168.64.1:8070",
                    dev = true
                ) {
                    DemoApp()
                }
            }
        }
    }
}

fun isValidIPv4(ip: String): Boolean {
    val pattern = Pattern.compile(
        "^((25[0-5]|2[0-4]\\d|[01]?\\d\\d?)\\.){3}" +
        "(25[0-5]|2[0-4]\\d|[01]?\\d\\d?)$"
    )
    return pattern.matcher(ip).matches()
}

fun getFirstDnsIP(): String? {
    val dnsProps = listOf("net.dns1", "net.dns2", "net.dns3", "net.dns4")
    val dnsIPs = mutableListOf<String>()

    try {
        val systemProperties = Class.forName("android.os.SystemProperties")
        val getProp = systemProperties.getMethod("get", String::class.java)
        for (prop in dnsProps) {
            val value = getProp.invoke(null, prop) as String
            if (isValidIPv4(value)) {
                dnsIPs.add(value)
            }
        }
    } catch (e: Exception) {
        e.printStackTrace()
    }

    return dnsIPs.firstOrNull()
}

@Serializable
data class VibeSchema(
    val id: String,
    val objects: List<VibeShape> = emptyList()
)

@Serializable
data class VibeCanvasSize(val width: Int, val height: Int)

@Serializable
enum class MessageType { actionable, actionables, schema }

@Serializable
data class MessageWrapper(
    val type: String,
    val payload: String
)


@Serializable
data class VibeAnimationValues(
    val scale: Float = 1.0f,
    val translate: List<Float> = listOf(0.0f, 0.0f),  // [x, y] normalized (-1..1)
    val rotate: Float = 0.0f,
    val rotateCenter: Float = 0.0f,
    val opacity: Float = 1.0f
)

@Serializable
enum class VibeAnimationInvokeType { trigger, auto }

@Serializable
data class VibeAnimationKeyframe(
    val id: String,  // Added id field to match Swift
    val values: VibeAnimationValues,
    val duration: Float // seconds
)

@Serializable
data class VibeAnimationSchema(
    val id: String,
    val initialValues: VibeAnimationValues = VibeAnimationValues(),
    val invokeType: VibeAnimationInvokeType,
    val keyframes: List<VibeAnimationKeyframe> = emptyList()
)

@Serializable
data class AnimationContainer(
    val actionableId: String,
    val containerId: String
)

@Serializable
enum class VibeObjectType { shape, animation }  // Added enum to match Swift

@Serializable
data class VibeShape(
    val id: String,
    val containerId: String,  // Changed from container to containerId to match Swift
    val width: Float,
    val height: Float,
    val position: List<Float>,  // Changed from Position to List<Float> [x, y] to match Swift
    val color: List<Float>,  // Changed from List<Int> to List<Float> to match Swift
    val shape: String,
    val objectType: VibeObjectType,  // Added objectType field
    val zIndex: Int,
    val animation: VibeAnimationSchema
)

@Serializable
data class VibeAnimationState(
    val id: String,
    val trigger: Boolean? = null,
    val isCancelled: Boolean = false
)

class VibeDataModel(
    val containerId: String,
    var vibeSchema: VibeSchema,
    var tree: Tree,
    var actionableIds: MutableSet<String>
) {
    val states: MutableMap<String, VibeAnimationState> = mutableMapOf()
    val actionableIdToAnimationIdMap: MutableMap<String, String> = mutableMapOf()
    var isActionable: Boolean = false
}

// ---------- Tree / Node with (de)serialization ----------

@Serializable
data class NodeDTO(
    val id: String,
    val parentId: String? = null,
    val children: List<NodeDTO>? = null  // Changed to nullable to match Swift
)

class Node(val id: String, var parentId: String? = null) {
    var parent: Node? = null
    val children: MutableList<Node> = mutableListOf()
    var tree: Tree? = null

    fun addChild(child: Node) {
        // avoid adding the same child multiple times
        if (children.any { it.id == child.id }) {
            // ensure parent reference is correct
            child.parent = this
            child.parentId = id
            return
        }
        child.parent = this
        child.parentId = id
        children += child
    }

    fun link() {
        if (parentId != null && tree != null) {
            parent = tree!!.nodeMap[parentId]
        }
        children.forEach { it.link() }
    }

    fun toDTO(): NodeDTO = NodeDTO(
        id = id,
        parentId = parentId,
        children = if (children.isEmpty()) null else children.map { it.toDTO() }  // Only include children if non-empty
    )

    override fun toString() =
        "{id: $id, parentId: $parentId, children: [${children.joinToString { it.id }}]}"
}

@Serializable
data class TreeDTO(
    val id: String,
    val nodeMap: Map<String, NodeDTO> = emptyMap(),
    val rootNode: NodeDTO? = null
)

class Tree(val id: String) {
    var rootNode: Node? = null
    val nodeMap: MutableMap<String, Node> = mutableMapOf()

    fun addRelationship(id: String, parentId: String?, parentIsContainer: Boolean = false) {
        val current = nodeMap.getOrPut(id) {
            Node(id, parentId).also { it.tree = this }
        }
        if (parentId != null) {
            val parent = nodeMap.getOrPut(parentId) {
                Node(parentId).also { it.tree = this }
            }
            parent.addChild(current)
            if (parentIsContainer || (rootNode == null && parent.parent == null)) {
                rootNode = parent
            }
        }
    }

    fun toDTO(): TreeDTO {
        val map = nodeMap.mapValues { (_, node) -> node.toDTO() }
        return TreeDTO(id = id, nodeMap = map, rootNode = rootNode?.toDTO())
    }

    companion object {
        fun fromDTO(dto: TreeDTO): Tree {
            val t = Tree(dto.id)
            fun build(n: NodeDTO): Node {
                val node = Node(n.id, n.parentId)
                node.tree = t
                n.children?.let { children ->
                    node.children.addAll(children.map { build(it) })
                }
                return node
            }
            dto.nodeMap.forEach { (k, v) ->
                t.nodeMap[k] = build(v)
            }
            t.rootNode = dto.rootNode?.let { build(it) }
            t.nodeMap.values.forEach { it.link() }
            return t
        }
    }
}

// ---------- Messages ----------
@Serializable
data class MessageActionableWrapper(val type: String, val payload: MessageActionable)

@Serializable
data class MessageActionablesWrapper(val type: String, val payload: MessageActionables)

@Serializable
data class MessageSchemaWrapper(val type: String, val payload: MessageSchema)

@Serializable
data class MessageActionables(
    val tree: TreeDTO,
    val actionableIds: Set<String>  // Changed from List to Set to match Swift
)

@Serializable
data class MessageActionable(
    val isActionable: Boolean
)

@Serializable
data class VibeSchemaWrapper(
    val schema: VibeSchema,
    val actionableId: String,
    val container: AnimationContainer,
    val animationId: String
)

@Serializable
data class MessageSchema(
    val schemaWrappers: List<VibeSchemaWrapper>
)

// ---------- WebSocket Client (OkHttp + coroutines) ----------

class WebSocketClient private constructor() : WebSocketListener() {
    companion object {
        val shared: WebSocketClient by lazy { WebSocketClient() }
        private val json = Json { ignoreUnknownKeys = true; encodeDefaults = true }
    }

    private var socket: WebSocket? = null
    var isConnected: Boolean = false
        private set

    private val _onSelectedIds = MutableSharedFlow<Set<String>>(replay = 0)
    val onSelectedIds = _onSelectedIds.asSharedFlow()

    private val _onSchema = MutableSharedFlow<List<VibeSchemaWrapper>>(replay = 0)
    val onSchema = _onSchema.asSharedFlow()

    private val _onIsActionable = MutableSharedFlow<Boolean>(replay = 0)
    val onIsActionable = _onIsActionable.asSharedFlow()

    private val scope = CoroutineScope(Dispatchers.IO)
    private var onConnected: (() -> Unit)? = null

    fun connect(url: String, onConnect: () -> Unit = {}) {
        if (isConnected) return
        val client = OkHttpClient.Builder()
            .pingInterval(20, TimeUnit.SECONDS)
            .build()
        val request = Request.Builder().url(url).build()
        socket = client.newWebSocket(request, this)
        onConnected = onConnect
    }

    fun sendMessageActionables(type: String, message: MessageActionables) {
        val wrapper = MessageActionablesWrapper(type, message)
        sendJson(wrapper)
    }

    fun sendMessageSchema(type: String, message: MessageSchema) {
        val wrapper = MessageSchemaWrapper(type, message)
        sendJson(wrapper)
    }

    // private fun sendJson(wrapper: Any) {
    //     if (!isConnected || socket == null) return
    //     try {
    //         // 1️⃣ Serialize inner payload
    //         val payloadBytes = when (wrapper) {
    //             is MessageActionableWrapper -> json.encodeToString(wrapper.payload).toByteArray(StandardCharsets.UTF_8)
    //             is MessageActionablesWrapper -> json.encodeToString(wrapper.payload).toByteArray(StandardCharsets.UTF_8)
    //             is MessageSchemaWrapper -> json.encodeToString(wrapper.payload).toByteArray(StandardCharsets.UTF_8)
    //             else -> return
    //         }

    //         // 2️⃣ Wrap with type + payload bytes
    //         val type = when (wrapper) {
    //             is MessageActionableWrapper -> "actionable"
    //             is MessageActionablesWrapper -> "actionables"
    //             is MessageSchemaWrapper -> "schema"
    //             else -> return
    //         }

    //         val wrapperBytes = json.encodeToString(
    //             MessageWrapper(type, payloadBytes)
    //         ).toByteArray(StandardCharsets.UTF_8)

    //         // 3️⃣ Send as binary WebSocket frame
    //         socket?.send(text=wrapperBytes)

    //     } catch (e: Exception) {
    //         e.printStackTrace()
    //     }
    // }
    private fun sendJson(wrapper: Any) {
        if (!isConnected || socket == null) return
        try {
            // 1️⃣ Serialize inner payload to JSON string
            val payloadJson = when (wrapper) {
                is MessageActionableWrapper -> json.encodeToString(wrapper.payload)
                is MessageActionablesWrapper -> json.encodeToString(wrapper.payload)
                is MessageSchemaWrapper -> json.encodeToString(wrapper.payload)
                else -> return
            }

            // 2️⃣ Encode JSON string to Base64
            val payloadBase64 = Base64.getEncoder().encodeToString(payloadJson.toByteArray(StandardCharsets.UTF_8))

            // 3️⃣ Wrap with type + Base64 payload
            val type = when (wrapper) {
                is MessageActionableWrapper -> "actionable"
                is MessageActionablesWrapper -> "actionables"
                is MessageSchemaWrapper -> "schema"
                else -> return
            }

            val wrapperObj = MessageWrapper(type, payloadBase64)
            val wrapperJson = json.encodeToString(wrapperObj)

            // 4️⃣ Send as text WebSocket frame
            socket?.send(wrapperJson)

        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    override fun onOpen(webSocket: WebSocket, response: Response) {
        isConnected = true
        onConnected?.invoke()
    }

    override fun onMessage(webSocket: WebSocket, text: String) {
        runCatching {
            // Parse the outer wrapper
            val wrapper = json.decodeFromString<MessageWrapper>(text)
            
            // Decode Base64 payload
            val payloadBytes = Base64.getDecoder().decode(wrapper.payload)
            val payloadJson = String(payloadBytes, StandardCharsets.UTF_8)

            // Deserialize based on type
            when (wrapper.type) {
                "actionable" -> {
                    val decoded = json.decodeFromString<MessageActionable>(payloadJson)
                    scope.launch { _onIsActionable.emit(decoded.isActionable) }
                }
                "actionables" -> {
                    val decoded = json.decodeFromString<MessageActionables>(payloadJson)
                    scope.launch { _onSelectedIds.emit(decoded.actionableIds) }
                }
                "schema" -> {
                    val decoded = json.decodeFromString<MessageSchema>(payloadJson)
                    scope.launch { _onSchema.emit(decoded.schemaWrappers) }
                }
            }

        }.onFailure { it.printStackTrace() }
    }


    override fun onMessage(webSocket: WebSocket, bytes: ByteString) {
        onMessage(webSocket, bytes.string(StandardCharsets.UTF_8))
    }

    override fun onClosed(webSocket: WebSocket, code: Int, reason: String) {
        isConnected = false
    }

    override fun onFailure(webSocket: WebSocket, t: Throwable, response: Response?) {
        isConnected = false
        t.printStackTrace()
    }

    private inline fun <reified T> decodePayload(payloadElement: JsonElement): T {
        val base64 = payloadElement.jsonPrimitive.content
        val jsonText = String(Base64.getDecoder().decode(base64), StandardCharsets.UTF_8)
        return json.decodeFromString(jsonText)
    }
}

// ---------- Composition Locals ----------

private val LocalVibeDataModel = compositionLocalOf<VibeDataModel?> { null }
private val LocalVibeParentId = compositionLocalOf<String?> { null }
private val LocalVibeContainerId = compositionLocalOf<String?> { null }
private val LocalVibeIsContainer = compositionLocalOf<Boolean> { false }
private val LocalCanvasSize = compositionLocalOf<IntSize> { IntSize.Zero }

// ---------- Shared index manager (IDs) ----------

object SharedIndexManager {
    val indexMap: MutableMap<String, Int> = mutableMapOf()
    val objectIndexMap: MutableMap<String, Int> = mutableMapOf()
    val objectIdSet: MutableSet<String> = mutableSetOf()
}

// ---------- VibeContainer composable ----------

@Composable
fun VibeContainer(
    id: String,
    baseURL: String,
    dev: Boolean = false,
    content: @Composable () -> Unit
) {
    var model by remember {
        mutableStateOf(
            VibeDataModel(
                containerId = id,
                vibeSchema = VibeSchema(id, emptyList()),
                tree = Tree(id),
                actionableIds = mutableSetOf()
            )
        )
    }
    var size by remember { mutableStateOf(IntSize.Zero) }

    LaunchedEffect(model.tree, baseURL) {
        val ws = WebSocketClient.shared

        val host = "192.168.64.1"
        val finalUrl = if (host != null) baseURL.replace("127.0.0.1", host) else baseURL

        ws.connect(url = finalUrl) {
            val msg = MessageActionables(
                tree = model.tree.toDTO(),
                actionableIds = model.actionableIds.toSet()  // Convert to Set
            )
            ws.sendMessageActionables("actionables", msg)
        }

        launch {
            ws.onSelectedIds.collect { set ->
                model = model.copyMutable { actionableIds = set.toMutableSet() }
            }
        }
        launch {
            ws.onSchema.collect { wrappers ->
                wrappers.forEach { w ->
                    if (w.container.containerId == model.containerId) {
                        model = model.copyMutable {
                            vibeSchema = w.schema
                            actionableIdToAnimationIdMap[w.actionableId] = w.animationId
                        }
                    }
                }
            }
        }
        launch {
            ws.onIsActionable.collect { value ->
                model = model.copyMutable { isActionable = value }
            }
        }
    }

    Box(
        modifier = Modifier
            .wrapContentSize()
            .onSizeChanged { size = it }
    ) {
        CompositionLocalProvider(
            LocalCanvasSize provides size,
            LocalVibeDataModel provides model,
            LocalVibeParentId provides id,
            LocalVibeContainerId provides id,
            LocalVibeIsContainer provides true
        ) { content() }
    }
}

private inline fun VibeDataModel.copyMutable(block: VibeDataModel.() -> Unit): VibeDataModel {
    val copy = VibeDataModel(
        containerId = containerId,
        vibeSchema = vibeSchema,
        tree = tree,
        actionableIds = actionableIds.toMutableSet()
    )
    copy.states.putAll(states)
    copy.actionableIdToAnimationIdMap.putAll(actionableIdToAnimationIdMap)
    copy.isActionable = isActionable
    block(copy)
    return copy
}

// ---------- Vibeable composable ----------

@Composable
fun Vibeable(
    hierarchyIdPrefix: String,
    content: @Composable () -> Unit
) {
    val model = LocalVibeDataModel.current
    val parentId = LocalVibeParentId.current
    val isContainer = LocalVibeIsContainer.current
    val canvasSize = LocalCanvasSize.current

    val indexMap = SharedIndexManager.indexMap
    var hierarchyId by remember { mutableStateOf<String?>(null) }
    var isSelected by remember { mutableStateOf(false) }

    LaunchedEffect(hierarchyIdPrefix) {
        val next = (indexMap[hierarchyIdPrefix] ?: 0)
        indexMap[hierarchyIdPrefix] = next + 1
        hierarchyId = "$hierarchyIdPrefix--$next"
    }

    LaunchedEffect(hierarchyId) {
        val id = hierarchyId ?: return@LaunchedEffect
        model?.tree?.addRelationship(id, parentId, isContainer)
    }


    LaunchedEffect(hierarchyId, model?.actionableIds) {
        hierarchyId?.let { id ->
            isSelected = model?.actionableIds?.contains(id) == true
        }
    }

    val tx = remember { Animatable(0f) }
    val haveAnim = remember(model?.vibeSchema, hierarchyId) {
        val id = hierarchyId ?: return@remember false
        val animId = model?.actionableIdToAnimationIdMap?.get(id)
        model?.vibeSchema?.objects?.any { it.animation.id == animId } == true
    }

    if (haveAnim && canvasSize != IntSize.Zero) {
        val id = hierarchyId!!
        val animationId = model!!.actionableIdToAnimationIdMap[id]!!
        val animation = model.vibeSchema.objects.first { it.animation.id == animationId }.animation

        val totalMs = (animation.keyframes.sumOf { (it.duration * 1000f).toDouble() })
            .toInt()
            .coerceAtLeast(1)

        LaunchedEffect(id, animationId, canvasSize) {
            while (true) {
                tx.animateTo(
                    targetValue = 1f,
                    animationSpec = infiniteRepeatable(
                        animation = tween(durationMillis = totalMs, easing = LinearEasing),
                        repeatMode = RepeatMode.Restart
                    )
                )
                tx.snapTo(0f)
            }
        }
    }

    val modifierWithAnim = run {
        val id = hierarchyId
        if (!haveAnim || id == null || canvasSize == IntSize.Zero) {
            Modifier
        } else {
            val animationId = model!!.actionableIdToAnimationIdMap[id]!!
            val animation = model.vibeSchema.objects.first { it.animation.id == animationId }.animation

            val times = mutableListOf(0f)
            var acc = 0f
            animation.keyframes.forEach {
                acc += it.duration
                times += acc
            }
            val total = times.lastOrNull()?.coerceAtLeast(0.0001f) ?: 0.0001f
            val normTimes = times.map { it / total }

            val values = listOf(animation.initialValues) + animation.keyframes.map { it.values }

            fun sample(t: Float): VibeAnimationValues {
                val clamped = t.coerceIn(0f, 1f)
                val idx = (1 until normTimes.size).firstOrNull { clamped <= normTimes[it] } ?: normTimes.lastIndex
                val t0 = normTimes.getOrElse(idx - 1) { 0f }
                val t1 = normTimes.getOrElse(idx) { 1f }
                val local = if (t1 > t0) (clamped - t0) / (t1 - t0) else 0f
                val a = values.getOrElse(idx - 1) { VibeAnimationValues() }
                val b = values.getOrElse(idx) { VibeAnimationValues() }
                fun lerpFloat(x: Float, y: Float) = x + (y - x) * local
                return VibeAnimationValues(
                    scale = lerpFloat(a.scale, b.scale),
                    translate = listOf(
                        lerpFloat(a.translate.getOrElse(0) { 0f }, b.translate.getOrElse(0) { 0f }),
                        lerpFloat(a.translate.getOrElse(1) { 0f }, b.translate.getOrElse(1) { 0f })
                    ),
                    rotate = lerpFloat(a.rotate, b.rotate),
                    rotateCenter = lerpFloat(a.rotateCenter, b.rotateCenter),
                    opacity = lerpFloat(a.opacity, b.opacity)
                )
            }

            val v by remember {
                derivedStateOf { sample(tx.value) }
            }

            val pxX = v.translate.getOrElse(0) { 0f } * (canvasSize.width / 2f)
            val pxY = v.translate.getOrElse(1) { 0f } * (canvasSize.height / 2f)

            Modifier.graphicsLayer {
                translationX = pxX
                translationY = pxY
                rotationZ = v.rotateCenter
                scaleX = v.scale
                scaleY = v.scale
                alpha = v.opacity
                transformOrigin = TransformOrigin.Center
            }
        }
    }

    val clickableModifier = Modifier
        .then(modifierSelectedBorder(isSelected && (model?.isActionable == true)))
        .clickable(enabled = model?.isActionable == true) {
            val id = hierarchyId ?: return@clickable
            val m = model ?: return@clickable
            val set = m.actionableIds.toMutableSet()
            if (set.contains(id)) set.remove(id) else set.add(id)

            val newModel = m.copyMutable { actionableIds = set }
            WebSocketClient.shared.sendMessageActionables("actionables",
                MessageActionables(
                    tree = newModel.tree.toDTO(),
                    actionableIds = newModel.actionableIds.toSet()  // Convert to Set
                )
            )
        }

    Box(modifier = modifierWithAnim.then(clickableModifier)) {
        CompositionLocalProvider(
            LocalVibeParentId provides hierarchyId
        ) {
            content()
        }
    }
}

@Composable
private fun modifierSelectedBorder(show: Boolean): Modifier =
    if (!show) Modifier
    else Modifier.background(Color.Green)

// ---------- Utilities ----------

@JvmName("toColorFromInts")
fun List<Int>.toColor(): Color = when (size) {
    3 -> Color(this[0], this[1], this[2])
    4 -> Color(this[0], this[1], this[2], this[3])
    else -> Color.Unspecified
}

@JvmName("toColorFromFloats")
fun List<Float>.toColor(): Color = when (size) {
    3 -> Color(this[0], this[1], this[2])
    4 -> Color(this[0], this[1], this[2], this[3])
    else -> Color.Unspecified
}

// ---------- Demo App ----------

@Composable
fun DemoApp() {
    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0x1A000000))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Spacer(modifier = Modifier.height(12.dp))
            Vibeable(hierarchyIdPrefix = "test123321anim") {
                DemoCard()
            }
            Spacer(modifier = Modifier.height(12.dp))
            Vibeable(hierarchyIdPrefix = "demo-card1") {
                DemoCard()
            }
            Spacer(modifier = Modifier.height(12.dp))
            Vibeable(hierarchyIdPrefix = "demo-card2") {
                DemoCard()
            }
            Spacer(modifier = Modifier.height(12.dp))
        }
    }
}

@Composable
fun DemoCard() {
    var showMessage by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier.width(300.dp),
        shape = RoundedCornerShape(20.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 5.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = "Welcome",
                fontSize = 24.sp,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(4.dp))

            Text(
                text = "This is a demo app.",
                color = Color.Gray,
                fontSize = 14.sp,
                modifier = Modifier.fillMaxWidth(),
                textAlign = TextAlign.Center
            )

            Spacer(modifier = Modifier.height(12.dp))

            Button(
                onClick = { showMessage = true },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF007AFF)),
                shape = RoundedCornerShape(10.dp),
                contentPadding = PaddingValues(horizontal = 14.dp, vertical = 8.dp)
            ) {
                Text(
                    text = "Press Me",
                    color = Color.White,
                    fontSize = 15.sp
                )
            }

            if (showMessage) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Button pressed!",
                    color = Color(0xFF34C759),
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}