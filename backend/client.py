import json
import requests as r
import app.util as util

ap, apvt = None, None
bp, bpvt = None, None

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

# res = r.post("http://127.0.0.1:8080/register", data=json.dumps({
#     'username': 'aab',
#     'hashed_password': 'aab',
#     "publicKeyStr": util.pubKeyEncode(ap).decode()
# }))

# tknReq = r.post("http://127.0.0.1:8080/token",
#                 data={"username": "aab", "password": "aab"})

# print(tknReq.content.decode())
# tkn = json.loads(tknReq.content.decode())["access_token"]
HEADER = {"Authorization": f"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhYWIiLCJleHAiOjE3MDc2NzI0Njd9.njyRkbw4YqbexPwxsjaw3SRKE3_D1nJ_1nCLydbFzbg"}
# print(res.content.decode())

rUn = input("Enter Receiver Username: ")
res = r.get(f"http://127.0.0.1:8080/publicKey/{rUn}", headers=HEADER)
resD = json.loads(res.content.decode())
print(resD['publicKey'] if 'publicKey' in resD else "Invalid UserName")
