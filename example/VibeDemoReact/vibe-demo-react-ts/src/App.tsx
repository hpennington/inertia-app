import React from 'react'
import logo from './logo.svg'
import {VibeContainer, Vibeable} from 'vibe-react'
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <VibeContainer id={"animation1"} baseURL={"http://127.0.0.1:8000"}>
          <div className="logo-container">
            <Vibeable id={"bird"}>
              <div>
                <img src={logo} className="App-logo" alt="logo" />
              </div>
            </Vibeable>
            <div>
              <img src={logo} className="App-logo" alt="logo" />
            </div>
          </div>
        </VibeContainer>
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
          <a
            className="App-link"
            href="https://reactjs.org"
            target="_blank"
            rel="noopener noreferrer"
          >
            Learn React
          </a>
      </header>
    </div>
  );
}

export default App;
