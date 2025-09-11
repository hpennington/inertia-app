import React, { useState } from "react";
import { CSSProperties } from "react";
import { InertiaContainer, Inertiaable } from "inertia-react";

function Card({ id }: { id: string }) {
  const [showMessage, setShowMessage] = useState(false);

  const cardStyle: CSSProperties = {
    display: "flex",
    flexDirection: "column",
    backgroundColor: "white",
    borderRadius: "20px",
    boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
    padding: "12px",
    width: "218px", // match SwiftUI frame
    alignItems: "center",
  };

  const titleStyle: CSSProperties = {
    fontSize: "24px",
    fontWeight: "bold",
    marginBottom: "4px", // tighter spacing
  };

  const subtitleStyle: CSSProperties = {
    color: "gray",
    marginBottom: "12px", // less spacing than before
    fontSize: "14px",
  };

  const buttonStyle: CSSProperties = {
    backgroundColor: "red",
    color: "white",
    padding: "8px 14px", // slightly smaller
    border: "none",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "15px",
  };

  return (
    <Inertiaable hierarchyIdPrefix={id}>
      <div style={cardStyle}>
        <h1 style={titleStyle}>Welcome</h1>
        <p style={subtitleStyle}>This is a demo app.</p>
        <button style={buttonStyle} onClick={() => setShowMessage(true)}>
          Press Me
        </button>
        {showMessage && (
          <div style={{ marginTop: "8px", color: "green", fontWeight: 600 }}>
            Button pressed!
          </div>
        )}
      </div>
    </Inertiaable>
  );
}

export default function App() {
  const containerStyle: CSSProperties = {
    display: "flex",
    justifyContent: "center",
    backgroundColor: "rgba(0,0,0,0.05)", // like SwiftUI black.opacity(0.1)
    minHeight: "100vh",
    overflowY: "auto",
    padding: "16px",
  };

  const contentStyle: CSSProperties = {
    display: "flex",
    flexDirection: "column",
    gap: "12px", // less spacing between cards
    width: "100%",
    alignItems: "center",
  };

  return (
    <InertiaContainer id={"animation"} baseURL={"http://localhost:8000"} dev={true}>
      <div style={containerStyle}>
        <div style={contentStyle}>
          <Card id="card0" />
          <Card id="card1" />
          <Card id="card2" />
        </div>
      </div>
    </InertiaContainer>
  );
}
