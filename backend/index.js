const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");

const app = express();
const port = process.env.PORT || 3000;

const pool = new Pool({
  host: process.env.DB_HOST || "localhost",
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || "notes",
  password: process.env.DB_PASSWORD || "notes",
  database: process.env.DB_NAME || "notes",
});

app.use(cors());
app.use(express.json());

async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS notes (
      id SERIAL PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT NOT NULL,
      created_at TIMESTAMP DEFAULT NOW()
    )
  `);
  console.log("Table 'notes' OK");
}

app.get("/notes", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM notes ORDER BY id DESC");
    res.json(result.rows);
  } catch (err) {
    console.error("GET /notes error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.get("/notes/:id", async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM notes WHERE id = $1", [
      req.params.id,
    ]);
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Note not found" });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("GET /notes/:id error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.post("/notes", async (req, res) => {
  const { title, content } = req.body;
  if (!title || !content) {
    return res.status(400).json({ error: "title and content are required" });
  }
  try {
    const result = await pool.query(
      "INSERT INTO notes (title, content) VALUES ($1, $2) RETURNING *",
      [title, content]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("POST /notes error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.put("/notes/:id", async (req, res) => {
  const { title, content } = req.body;
  if (!title || !content) {
    return res.status(400).json({ error: "title and content are required" });
  }
  try {
    const result = await pool.query(
      "UPDATE notes SET title = $1, content = $2 WHERE id = $3 RETURNING *",
      [title, content, req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Note not found" });
    }
    res.json(result.rows[0]);
  } catch (err) {
    console.error("PUT /notes/:id error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.delete("/notes/:id", async (req, res) => {
  try {
    const result = await pool.query(
      "DELETE FROM notes WHERE id = $1 RETURNING *",
      [req.params.id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: "Note not found" });
    }
    res.status(204).send();
  } catch (err) {
    console.error("DELETE /notes/:id error:", err);
    res.status(500).json({ error: "Internal server error" });
  }
});

initDb()
  .then(() => {
    app.listen(port, () => {
      console.log(`Notes API listening on port ${port}`);
    });
  })
  .catch((err) => {
    console.error("DB init error:", err);
    process.exit(1);
  });

