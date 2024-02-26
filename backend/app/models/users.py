from datetime import datetime
from fastapi import WebSocket
from pydantic import BaseModel
from cryptography.hazmat.primitives.asymmetric import rsa


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: str | None = None


class UserBase(BaseModel):
    username: str
    full_name: str | None = None
    publicKeyStr: str | None = None


class UserInDB(UserBase):
    hashed_password: str


# class RegisterUser(BaseModel):
#     username: str
#     password: str
    # public_key: str | None = None


# class WSConnection(BaseModel):
#     username: str
#     wssocket: WebSocket | None = None
#     connection_on: datetime = datetime.now()
#     # is_active: bool = True
