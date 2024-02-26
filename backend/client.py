import datetime
import json
import requests as r
import app.util as util
import websocket
import rel

ap, apvt = None, None
bp, bpvt = None, None
# region File
with open("aa.pub") as f:
    rl = f.read()
    ap = util.pubKeyDecode(rl.encode())

with open("aa.pvt") as f:
    rl = f.read()
    apvt = util.pvtKeyDecode(rl.encode())

with open("bb.pub") as f:
    rl = f.read()
    bp = util.pubKeyDecode(rl.encode())

with open("bb.pvt") as f:
    rl = f.read()
    bpvt = util.pvtKeyDecode(rl.encode())

res = r.post("http://127.0.0.1:8080/register", data=json.dumps({
    'username': 'aab',
    'hashed_password': 'aab',
    "publicKeyStr": util.pubKeyEncode(ap).decode()  # type: ignore
}))
# endregion

u = input("UserNamee: ")
p = input("Passw: ")

tknReq = r.post("http://127.0.0.1:8080/token",
                data={"username": u, "password": p})

print(tknReq.content.decode())
tkn = json.loads(tknReq.content.decode())["access_token"]

# HEADER = {"Authorization": f"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhYWIiLCJleHAiOjE3MDc2NzI0Njd9.njyRkbw4YqbexPwxsjaw3SRKE3_D1nJ_1nCLydbFzbg"}
HEADER = {"Authorization": f"Bearer {tkn}"}
print(res.content.decode())

rUn = input("Enter Receiver Username: ")
res = r.get(f"http://127.0.0.1:8080/publicKey/{rUn}", headers=HEADER)
resD = json.loads(res.content.decode())
print(resD['publicKey'] if 'publicKey' in resD else "Invalid UserName")


def rec(ws, m):
    print("AA", m)


websocket.enableTrace(True)
ws = websocket.WebSocketApp(
    f"ws://localhost:8080/ws?token={tkn}", on_message=rec, on_data=rec)
# ws.on_message = rec
ws.run_forever(dispatcher=rel, reconnect=5)

# ws.send_text(json.dumps(
#     {"to": u, "msg": "echo", "timestamp": datetime.datetime.now().isoformat()}))

while True:
    msg = input("MSG: ")
    to = input("TO: ")
    print(
        {"to": to, "msg": msg, "timestamp": datetime.datetime.now().isoformat()})
    ws.send_text(json.dumps(
        {"to": to, "msg": msg, "timestamp": datetime.datetime.now().isoformat()}))

rel.signal(2, rel.abort)
rel.dispatch()
