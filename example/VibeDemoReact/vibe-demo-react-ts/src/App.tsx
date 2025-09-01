import React from 'react'
import logo from './logo.svg'
import gearIcon from './gear.png'
import {VibeContainer, Vibeable} from 'vibe-react'
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1 className="title">Inertia Pro </h1>
        <VibeContainer id={"animation1"} baseURL={"http://localhost:8000"}>
          <div className="gear-cancel-container">
            <Vibeable hierarchyIdPrefix={"homeCard"}>
              <div className="icon-container">
                <img src={gearIcon} className="App-logo" alt="Gear" />
              </div>
            </Vibeable>
            <Vibeable hierarchyIdPrefix={"car"}>
            <button
              className="App-link"
              onClick={e => {}}
            >
              Cancel
            </button>
            </Vibeable>
          </div>
        </VibeContainer>
      </header>
    </div>
  );
}

export default App;
