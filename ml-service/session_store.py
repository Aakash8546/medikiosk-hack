import json
import sqlite3
import time
from contextlib import contextmanager
from typing import Optional

DB_PATH = "sessions.db"

SESSION_TTL_SECONDS = 60 * 60 * 2  


@contextmanager
def _connect():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    try:
        yield conn
        conn.commit()
    finally:
        conn.close()


def init_db():
    with _connect() as conn:
        conn.execute()
        
        
        existing_cols = {row["name"] for row in conn.execute("PRAGMA table_info(sessions)")}
        for col, ddl in [
            ("status", "ALTER TABLE sessions ADD COLUMN status TEXT NOT NULL DEFAULT 'in_progress'"),
            ("documents", "ALTER TABLE sessions ADD COLUMN documents TEXT NOT NULL DEFAULT '[]'"),
            ("summary", "ALTER TABLE sessions ADD COLUMN summary TEXT"),
            ("summary_status", "ALTER TABLE sessions ADD COLUMN summary_status TEXT"),
        ]:
            if col not in existing_cols:
                conn.execute(ddl)


def _purge_expired(conn):
    cutoff = time.time() - SESSION_TTL_SECONDS
    conn.execute(
        "DELETE FROM sessions WHERE updated_at < ?",
        (cutoff,)
    )


def create_session(
    session_id: str,
    history: dict,
    completed_fields: list,
    current_field: Optional[str],
    current_question: Optional[str],
    language: str
):
    now = time.time()
    with _connect() as conn:
        _purge_expired(conn)
        conn.execute(
            ,
            (
                session_id,
                json.dumps(history),
                json.dumps(completed_fields),
                current_field,
                current_question,
                language,
                now,
                now,
            )
        )


def get_session(session_id: str) -> Optional[dict]:
    with _connect() as conn:
        _purge_expired(conn)
        row = conn.execute(
            "SELECT * FROM sessions WHERE session_id = ?",
            (session_id,)
        ).fetchone()

    if row is None:
        return None

    return {
        "history": json.loads(row["history"]),
        "completed_fields": json.loads(row["completed_fields"]),
        "current_field": row["current_field"],
        "current_question": row["current_question"],
        "language": row["language"],
        "status": row["status"],
        "documents": json.loads(row["documents"]),
        "summary": json.loads(row["summary"]) if row["summary"] else None,
        "summary_status": row["summary_status"],
    }


def update_session(
    session_id: str,
    history: dict,
    completed_fields: list,
    current_field: Optional[str],
    current_question: Optional[str],
):
    with _connect() as conn:
        conn.execute(
            ,
            (
                json.dumps(history),
                json.dumps(completed_fields),
                current_field,
                current_question,
                time.time(),
                session_id,
            )
        )


def set_status(session_id: str, status: str):
    
    with _connect() as conn:
        conn.execute(
            "UPDATE sessions SET status = ?, updated_at = ? WHERE session_id = ?",
            (status, time.time(), session_id)
        )


def add_documents(session_id: str, new_pages: list):
    
    with _connect() as conn:
        row = conn.execute(
            "SELECT documents FROM sessions WHERE session_id = ?",
            (session_id,)
        ).fetchone()

        if row is None:
            return False

        existing = json.loads(row["documents"])
        existing.extend(new_pages)

        conn.execute(
            "UPDATE sessions SET documents = ?, updated_at = ? WHERE session_id = ?",
            (json.dumps(existing), time.time(), session_id)
        )
        return True


def get_documents(session_id: str) -> Optional[list]:
    with _connect() as conn:
        row = conn.execute(
            "SELECT documents FROM sessions WHERE session_id = ?",
            (session_id,)
        ).fetchone()

    if row is None:
        return None

    return json.loads(row["documents"])


def save_summary(session_id: str, summary: dict, status: str):
    
    with _connect() as conn:
        conn.execute(
            "UPDATE sessions SET summary = ?, summary_status = ?, updated_at = ? WHERE session_id = ?",
            (json.dumps(summary), status, time.time(), session_id)
        )


def delete_session(session_id: str):
    with _connect() as conn:
        conn.execute(
            "DELETE FROM sessions WHERE session_id = ?",
            (session_id,)
        )