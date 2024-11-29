# backend/main.py

from fastapi import FastAPI
from endpoints import auth, client, common, user
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router, tags=["auth"])
app.include_router(client.router, tags=["client"])
app.include_router(common.router, tags=["common"])
app.include_router(user.router, tags=["user"])

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
