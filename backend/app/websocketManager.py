from datetime import datetime
from fastapi import WebSocket
# from app.models.users import UserBase, WSConnection


# class WSManager(object):
#     def __init(self):
#         self.activeconnection: list[WSConnection] = []

#     def getUserConnection(self, username: str) -> WSConnection | None:
#         for c in self.activeconnection:
#             if c.username == username:
#                 return c

#         return None

#     def createConnection(self, username: str, sk: WebSocket):
#         if self.getUserConnection(username):
#             return False
#         self.activeconnection.append(WSConnection(
#             username=username,  connection_on=datetime.now()))

#         return True


class WSManager:
    def __init__(self):
        self.connections: list[WebSocket] = []
        self.userCon: dict[str, WebSocket] = {}

    async def connect(self, username: str, websocket: WebSocket):
        await websocket.accept()
        self.connections.append(websocket)
        self.userCon[username] = websocket

    async def broadcast(self, data: str):
        for connection in self.connections:
            await connection.send_text(data)

    def isUserConnected(self, username: str) -> bool:
        return username in self.userCon

    def getUserSocket(self, username: str):
        if not self.isUserConnected(username):
            return None

        return self.userCon[username]
