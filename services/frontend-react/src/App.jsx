import React, { useState } from "react";
import axios from "axios";
import "./index.css";

const API_BASE = process.env.REACT_APP_API_BASE || "";
// const res = await axios.get(`${API_BASE}/api/movies`);

export default function App() {
  const [movies, setMovies] = useState([]);
  const [loading, setLoading] = useState(false);

  const loadMovies = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_BASE}/api/movies`);
      setMovies(res.data);
    } catch (e) {
      alert("Failed to load movies");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="app">
      <h1>🎬 Movie DB (React + FastAPI)</h1>
      <button disabled={loading} onClick={loadMovies}>
        {loading ? "Loading..." : "Load Movies"}
      </button>
      {movies.length > 0 && (
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Title</th>
              <th>Year</th>
              <th>Rating</th>
            </tr>
          </thead>
          <tbody>
            {movies.map((m) => (
              <tr key={m.id}>
                <td>{m.id}</td>
                <td>{m.title}</td>
                <td>{m.year ?? ""}</td>
                <td>{m.rating ?? ""}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}
