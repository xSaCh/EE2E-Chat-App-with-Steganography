from app.models.users import *
import app.util as util

AAB_PUB = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAucNVIWtE4WJAOWi/VRI4
fohDi1Ku2i9T5ZQGeEIUtqsW9pckAYagBk/qY5Uzsfoz4bxer5bPosUr2lt8PZxY
sZA7+PF5QRpPxcFT7aLnE1GczJU0mFOUpzv+KQRr4VRY+wYeFaSpV/0zHD2TeEbL
Xcn3cfmT6xGH1qpNS3Yky4z10x0IEbbAZg+Rvh/BTS4ZzU862S7CZBixyWIIVuID
yBRmEwuCFEHWQ6dLQY3qcNo1gUb6aPNATfELyVcLqYcdh62o+BuKIm3MJNujS3tk
7RdiimniRAWAPaTQCcqj3hyeWzseeDNgGDDpYvQaYAGvHZx4/Qh4QSQUfT0REoCr
7QIDAQAB
-----END PUBLIC KEY-----
'''
BBB_PUB = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAurKUdjbYRgpCZqsICFYT
aKvPS7Nza/hWVilQ96IxrJswqbD0VVQM3zD1/46iEYkcEyDIHKC1jthGtofMEfua
1eA6fH66RZePG7OWAjEH9SYCzjv2U9RSl71mh0YQv/3Vo5NUPL7QTOLz281Os7HJ
wMQL9yc+jo0e32f0D81mrwnfTDEhBRfDxgi2UqZljZB+kjuPFxUxh9NCwB2TZlz2
vli6VTLolj2mCvdlDb0z0GCXSvx8izBeYtwGaTIqNUj4GFzSyY2C8aSyp3iapu2K
GiGzcSDWN/Ul49l7bMBQMAWDRJrG7O1z4gBypIO2AOoX6qwnUgwOvrAXegCGDJnE
PwIDAQAB
-----END PUBLIC KEY-----
'''


class LocalDb(object):
    def __init__(self) -> None:
        self.users: list[UserInDB] = [
            UserInDB(username="aab", hashed_password="aab",
                     publicKeyStr=AAB_PUB),
            UserInDB(username="bbb", hashed_password="bb",
                     publicKeyStr=BBB_PUB),
        ]
        self.publicKeys: dict[str, str] = {}
        pass

    def addRegisterUser(self, user: UserInDB) -> bool:
        for u in self.users:
            if u.username == user.username:
                return False

        self.users.append(user)
        return True

    # def validateUser(self, user: UserInDB) -> bool:
    #     for u in self.users:
    #         if user.username == u.username and user.hashed_password == u.hashed_password:
    #             return True

    #     return False

    def get_user(self, username: str):
        for u in self.users:
            if u.username == username:
                return u
        return None

    def authenticate_user(self, username: str, password: str):
        #  passHash = util.get_password_hash(password)
        passHash = password
        user = self.get_user(username)
        if user and user.hashed_password == passHash:
            return user
        return None

    def addPublicKey(self, user: UserInDB, publicKey: str) -> None:
        pass


# def get_user(db, username: str):
#     if username in db:
#         user_data = db[username]
#         return UserInDB(**user_data)


# def authenticate_user(db, username: str, password: str):
#     user = get_user(db, username)
#     if not user:
#         return False
#     if not verify_password(password, user.hashed_password):
#         return False

#     return user
