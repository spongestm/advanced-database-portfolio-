# Group-16-Multi-User-Chat-App

A real-time, multi-user chat application built with Python, allowing users on the same local network to connect, communicate, and see active participants. The application features a Tkinter-based GUI for the client and a robust socket-based server.

## Features

- **Real-time Messaging:** Send and receive messages instantly with all connected users.
- **User List:** Dynamically updated panel showing all currently active users.
- **Timestamps:** All messages are displayed with a timestamp for context.
- **Graceful Disconnects:** The server automatically handles user disconnections and notifies other clients.
- **Error Handling:** Custom exceptions and user-friendly error messages for network issues.

## Roles and Responsibilities

Our team collaborated on GitHub with the following roles:
*   **Networking Team:** Implemented the core socket communication (`serverr.py`, `clientss.py`).
*   **GUI Team:** Designed and built the Tkinter user interface (`clientss.py`).
*   **Testing Team:** Wrote and maintained unit tests (`test_chat_app.py`).
*   **Docs/Media Team:** Prepared this README, reports, and the demo video.
*   **Coordinator:** Oversaw project integration and final submission.

*Commit history reflects these contributions.*

## Prerequisites

- Python 3.6 or higher

## How to Run Locally

1.  **Clone the repository** (if applicable) or download the project files.
    ```bash
    git clone <your-repo-url>
    cd Group-16-Multi-User-Chat-App
    ```

2.  **Start the Server:**
    Open a terminal and run:
    ```bash
    python updated_serverr.py
    ```
    You should see: `✅ Server started on 0.0.0.0:12345`

3.  **Start Clients:**
    Open one or more new terminal windows and run the client script on each:
    ```bash
    python updated_clientss.py
    ```
    - You will be prompted to enter a username for each client.
    - The client GUI will open. You can now start chatting!

**Note:** By default, the client is configured to connect to `127.0.0.1` (localhost). To connect from another machine on the same network, change the `host` parameter in the `ChatClient` instantiation in `clientss.py` to the server's local IP address (e.g., `192.168.1.100`).

## Running the Tests

This project uses `pytest` for unit testing. The tests verify core networking functions and error handling.

To run the tests, ensure `pytest` is installed (`pip install pytest`), then execute:

```bash
python -m pytest test_chat_app.py -v