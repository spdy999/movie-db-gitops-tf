from fastapi import FastAPI
import os
import psycopg2
import json
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()
DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://movie:moviepass@postgres:5432/moviedb")
instrumentator = Instrumentator().instrument(app).expose(app)


def query(sql):
    conn = psycopg2.connect(DATABASE_URL)
    try:
        with conn.cursor() as cur:
            cur.execute(sql)
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            return [dict(zip(cols, r)) for r in rows]
    finally:
        conn.close()


@app.get("/api/health")
def health():
    return {"ok": True}


@app.get("/api/movies")
def movies():
    rows = query("SELECT id, title, year, rating FROM movies ORDER BY id")
    return rows
