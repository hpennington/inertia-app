import React from 'react'
import { CSSProperties } from "react";
// import logo from './logo.svg'
// import gearIcon from './gear.png'
import {VibeContainer, Vibeable} from 'vibe-react'
// import './App.css';

// function App() {
//   return (
//     <VibeContainer id={"animation1"} baseURL={"http://localhost:8000"} dev={true}>
//     <div className="App">
//       <header className="App-header">
//         <h1 className="title">Inertia Pro </h1>
        
//           <div className="gear-cancel-container">
//             <Vibeable hierarchyIdPrefix={"homeCard"}>
//               <div className="icon-container">
//                 <img src={gearIcon} className="App-logo" alt="Gear" />
//               </div>
//             </Vibeable>
//             <Vibeable hierarchyIdPrefix={"car"}>
//               <button
//                 className="App-link"
//                 onClick={e => {}}
//               >
//                 Cancel
//               </button>
//             </Vibeable>
//           </div>
        
//       </header>
//     </div>
//     </VibeContainer>
//   );
// }

// export default App;


import { useState } from "react";

export default function App() {
  const [showAlert, setShowAlert] = useState(false);

  const containerStyle: CSSProperties = {
    display: "flex",
    alignItems: "center",
    justifyContent: "center",
    height: "100vh",
    backgroundColor: "#f2f2f7",
  };

  const cardStyle: CSSProperties = {
    display: "flex",
    flexDirection: "column",
    backgroundColor: "white",
    borderRadius: "20px",
    boxShadow: "0 4px 10px rgba(0,0,0,0.1)",
    padding: "12px",
    width: "228px",
    alignItems: "center",
    margin: "24px"
  };

  const titleStyle: CSSProperties = {
    fontSize: "24px",
    fontWeight: "bold",
    marginBottom: "8px"
  };

  const subtitleStyle: CSSProperties = {
    color: "gray",
    marginBottom: "16px"
  };

  const buttonStyle: CSSProperties = {
    backgroundColor: "#007aff",
    color: "white",
    padding: "10px 16px",
    border: "none",
    borderRadius: "10px",
    cursor: "pointer",
    fontSize: "16px"
  };

  return (
    <VibeContainer id={"animation1"} baseURL={"http://localhost:8000"} dev={true}>
      <div style={containerStyle}>
        <Vibeable hierarchyIdPrefix={"card1"}>
          <div style={cardStyle}>
            <h1 style={titleStyle}>Welcome</h1>
            <p style={subtitleStyle}>This is a demo app.</p>
            <button style={buttonStyle} onClick={() => setShowAlert(true)}>
              Press Me
            </button>

            {showAlert && (
              <div style={{ marginTop: "12px", color: "green", fontWeight: "600" }}>
                Button pressed!
              </div>
            )}
          </div>
        </Vibeable>
      </div>
    </VibeContainer>
  );
}
