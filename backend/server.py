import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "app.app:fastApp",
        host="127.0.0.1",
        port=8080,
        log_level="debug",
        reload=True,
        reload_excludes="client.py"
    )
