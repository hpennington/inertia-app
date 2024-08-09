// src/index.jsx

import { render } from 'solid-js/web';

function App() {
  return (
    <div>
      <h1>Hello, SolidJS!</h1>
      <p>This is a simple SolidJS component.</p>
    </div>
  );
}

render(() => <App />, document.getElementById('root'));

