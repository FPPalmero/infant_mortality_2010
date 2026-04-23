import subprocess
import sys


def main():
    fastapi_process = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "uvicorn",
            "src.api.app:app",
            "--host",
            "0.0.0.0",
            "--port",
            "8000",
        ]
    )

    streamlit_process = subprocess.Popen(
        [
            sys.executable,
            "-m",
            "streamlit",
            "run",
            "src/app/streamlit.py",
            "--server.address",
            "0.0.0.0",
            "--server.port",
            "8501",
        ]
    )

    try:
        fastapi_process.wait()
        streamlit_process.wait()
    except KeyboardInterrupt:
        fastapi_process.terminate()
        streamlit_process.terminate()


if __name__ == "__main__":
    main()
