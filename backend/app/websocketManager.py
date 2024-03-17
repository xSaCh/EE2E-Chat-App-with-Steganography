from datetime import datetime
from fastapi import WebSocket

# from app.models.users import UserBase, WSConnection


class WSManager:
    def __init__(self):
        self.connections: list[WebSocket] = []
        self.userCon: dict[str, WebSocket] = {}

    async def connect(self, username: str, websocket: WebSocket):
        existingUser = self.getUserSocket(username)
        if existingUser:
            self.removeSocket(existingUser)

        await websocket.accept()
        self.connections.append(websocket)
        self.userCon[username] = websocket

    def removeSocket(self, socket: WebSocket):
        if socket in self.connections:
            self.connections.remove(socket)

        for k, v in self.userCon.items():
            if v == socket:
                self.userCon.pop(k)
                return

    async def broadcast(self, data: str):
        for connection in self.connections:
            await connection.send_text(data)

    def isUserConnected(self, username: str) -> bool:
        return username in self.userCon

    def getUserSocket(self, username: str):
        if not self.isUserConnected(username):
            return None

        return self.userCon[username]
