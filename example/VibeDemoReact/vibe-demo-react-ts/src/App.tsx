import React from 'react';
import logo from './logo.svg';
import {VibeContainer} from 'vibe-react'
import './App.css';

function App() {
  return (
    <div className="App">
      <VibeContainer id={'123'}>
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <p>
            Edit <code>src/App.tsx</code> and save to reload.
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
      </VibeContainer>
    </div>
  );
}

export default App;
