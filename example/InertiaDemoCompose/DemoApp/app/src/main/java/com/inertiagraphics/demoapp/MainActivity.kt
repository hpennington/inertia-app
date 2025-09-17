package com.inertiagraphics.demoapp

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.animation.core.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.ui.draw.clip
import okhttp3.*
import java.util.*
import org.inertiagraphics.inertia.InertiaContainer
import org.inertiagraphics.inertia.Inertiaable

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                InertiaContainer(
                    id = "animation",
                    baseURL = "ws://127.0.0.1:8070",
                    dev = true
                ) {
                    DemoApp()
                }
            }
        }
    }
}
@Composable
fun DemoApp() {
    var cardColor by remember { mutableStateOf(Color.White) }

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
            // Header row with circular image and text
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.Center,
                modifier = Modifier.padding(bottom = 20.dp)
            ) {
                Box(
                    modifier = Modifier
                        .size(60.dp)
                        .clip(CircleShape)
                        .background(Color.Blue),
                    contentAlignment = Alignment.Center
                ) {
                    Text("👤", fontSize = 30.sp) // placeholder emoji
                }

                Spacer(modifier = Modifier.width(12.dp))

                Text(
                    text = "Inertia Demo",
                    fontSize = 28.sp,
                    fontWeight = FontWeight.Bold
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            Inertiaable(hierarchyIdPrefix = "card0") {
                DemoCard(cardColor)
            }
            Spacer(modifier = Modifier.height(12.dp))
            Inertiaable(hierarchyIdPrefix = "card1") {
                DemoCard(cardColor)
            }

            Spacer(modifier = Modifier.height(20.dp))

            // Button to change card color
            Button(
                onClick = {
                    val colors = listOf(
                        Color.White,
                        Color.Yellow.copy(alpha = 0.3f),
                        Color.Blue.copy(alpha = 0.3f),
                        Color.Green.copy(alpha = 0.3f)
                    )
                    val currentIndex = colors.indexOf(cardColor)
                    cardColor = colors[(currentIndex + 1) % colors.size]
                },
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF9500)),
                shape = RoundedCornerShape(10.dp),
                contentPadding = PaddingValues(horizontal = 16.dp, vertical = 10.dp),
                modifier = Modifier.padding(bottom = 40.dp)
            ) {
                Text("Change Card Color", color = Color.White, fontSize = 16.sp)
            }
        }
    }
}

@Composable
fun DemoCard(cardColor: Color) {
    var isChecked by remember { mutableStateOf(false) }

    Card(
        modifier = Modifier
            .width(300.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = cardColor),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center,
            modifier = Modifier.(16.dp)
        ) {
            Text(
                text = "Welcome",
                fontSize = 18.sp,
                fontWeight = FontWeight.SemiBold,
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

            Spacer(modifier = Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Checkbox(
                    checked = isChecked,
                    onCheckedChange = { isChecked = it }
                )
                Text(text = "Check Me")
            }

            if (isChecked) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Checked!",
                    color = Color(0xFF34C759),
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.fillMaxWidth(),
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}
