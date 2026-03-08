import React, { useEffect, useState } from "react";

const API_BASE = import.meta.env.VITE_API_BASE || "/api";

export default function App() {
  const [data, setData] = useState(null);
  const [err, setErr] = useState("");

  useEffect(() => {
    fetch(`${API_BASE}/message`)
      .then((r) => {
        if (!r.ok) throw new Error(`HTTP ${r.status}`);
        return r.json();
      })
      .then(setData)
      .catch((e) => setErr(String(e)));
  }, []);

  return (
    <div style={{ fontFamily: "system-ui", padding: 24, maxWidth: 720 }}>
      <h1>DevOps Microservice Demo</h1>
      <p>
        Frontend calling backend via <code>{API_BASE}/message</code>
      </p>

      {err && (
        <pre style={{ padding: 12, background: "#fee" }}>
          error: {err}
        </pre>
      )}

      {data ? (
        <pre style={{ padding: 12, background: "#f6f6f6" }}>
          {JSON.stringify(data, null, 2)}
        </pre>
      ) : (
        <p>Loading…</p>
      )}
    </div>
  );
}