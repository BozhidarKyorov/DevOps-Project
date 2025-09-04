import psycopg2
import pytest
import os

pytestmark = pytest.mark.skipif(
    os.getenv("SKIP_DB_TESTS") == "1",
    reason="Skipping DB tests in container, already tested in db-test job",
)


DB_URL = os.getenv(
    "DATABASE_URL", "postgresql://testuser:testpass@localhost:5432/testdb"
)


def test_users_table_has_rows():
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM users;")
    count = cur.fetchone()[0]
    cur.close()
    conn.close()
    assert count > 0, "users table should have at least one row"
