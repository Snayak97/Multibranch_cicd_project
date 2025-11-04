import React from "react";

const Login = () => {
  return (
    <div style={{ padding: "50px", fontFamily: "Arial" }}>
      <h1>dev--feature1 create login</h1>
      <button
        style={{
          padding: "10px 20px",
          fontSize: "16px",
          backgroundColor: "#007bff",
          color: "white",
          border: "none",
          borderRadius: "5px",
          cursor: "pointer",
        }}
        onClick={() => alert("Login clicked!")}
      >
        Login
      </button>
    </div>
  );
};

export default Login;
