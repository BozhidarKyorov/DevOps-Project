from fastapi import FastAPI
from src.db import get_users


app = FastAPI()


@app.get("/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/")
def root():
    return {"message": "Hello, CI/CD!"}

@app.get("/users")
def users():
    return {"users": get_users()}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8080)
