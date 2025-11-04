import { useState } from "react";
import reactLogo from "./assets/react.svg";
import viteLogo from "/vite.svg";
import "./App.css";
import Login from "./components/Login";

function App() {
  const [count, setCount] = useState(0);

  return (
    <>
      <div>
        <center>
          <h1>first pages in pratice version control</h1>
          <Login />
        </center>
      </div>
    </>
  );
}

export default App;
