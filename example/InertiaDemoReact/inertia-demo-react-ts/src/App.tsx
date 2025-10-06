import React, { useState } from "react";
import { CSSProperties } from "react";
import { InertiaContainer, Inertiaable } from "inertia-react";

function Card({ id, cardColor }: { id: string; cardColor: string }) {
  const [isChecked, setIsChecked] = useState(false);

  const cardStyle: CSSProperties = {
    display: "flex",
    flexDirection: "column",
    backgroundColor: cardColor,
    borderRadius: "16px",
    boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
    padding: "12px",
    width: "218px",
    // height: "140px", // shorter card
    alignItems: "center",
    justifyContent: "center",
  };

  const titleStyle: CSSProperties = {
    fontSize: "18px",
    fontWeight: "600",
    marginBottom: "2px",
  };

  const subtitleStyle: CSSProperties = {
    color: "gray",
    marginBottom: "8px",
    fontSize: "14px",
  };

  return (
    <Inertiaable hierarchyIdPrefix={id}>
      <div 
        style={cardStyle} 
        onClick={e => setIsChecked(isChecked => !isChecked)}
      >
        <h1 style={titleStyle}>Welcome</h1>
        <p style={subtitleStyle}>This is a demo app.</p>
        <label>
          <input
            type="checkbox"
            checked={isChecked}
            style={{ marginRight: "6px" }}
          />
          Check Me
        </label>
        {isChecked && (
          <div style={{ marginTop: "6px", color: "green", fontWeight: 600 }}>
            Checked!
          </div>
        )}
      </div>
    </Inertiaable>
  );
}

export default function App() {
  const [cardColor, setCardColor] = useState("white");

  const containerStyle: CSSProperties = {
    display: "flex",
    justifyContent: "center",
    backgroundColor: "rgba(0,0,0,0.05)",
    minHeight: "100vh",
    overflowY: "auto",
    padding: "16px",
  };

  const contentStyle: CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "16px",
    width: "100%",
    alignItems: "center",
  };

  const headerStyle: CSSProperties = {
    display: "flex",
    alignItems: "center",
    gap: "12px",
    marginBottom: "20px",
  };

  const imageStyle: CSSProperties = {
    width: "60px",
    height: "60px",
    borderRadius: "50%",
    backgroundColor: "lightblue", // placeholder circular image
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    fontSize: "30px",
  };

  const changeButtonStyle: CSSProperties = {
    backgroundColor: "orange",
    color: "white",
    padding: "10px 16px",
    border: "none",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "16px",
  };

  const cycleCardColor = () => {
    const colors = ["white", "rgba(255,255,0,0.3)", "rgba(0,0,255,0.2)", "rgba(0,128,0,0.2)"];
    const index = colors.indexOf(cardColor);
    setCardColor(colors[(index + 1) % colors.length]);
  };

  return (
    <InertiaContainer id={"animation"} baseURL={"http://localhost:8000"} dev={true}>
      <div style={containerStyle}>
        <div style={contentStyle}>
          {/* Header row with circular image + text */}
          <div style={headerStyle}>
            <div style={imageStyle}>👤</div>
            <h1 style={{ fontSize: "28px", fontWeight: "bold" }}>Inertia Demo</h1>
          </div>

          <Card id="card0" cardColor={cardColor} />
          <Card id="card1" cardColor={cardColor} />

          <button style={changeButtonStyle} onClick={cycleCardColor}>
            Change Card Color
          </button>
        </div>
      </div>
    </InertiaContainer>
  );
}
