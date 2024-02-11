from fastapi import Depends, FastAPI, Form, HTTPException, Request, status
from fastapi.datastructures import FormData
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from datetime import datetime, timedelta
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.models.users import *
import app.util as util
import app.db.localDb


SECRET_KEY = "83daa0256a2289b0fb23693bf1f6034d44396675749244721a2b20e896e11662"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

fastApp = FastAPI()
db = app.db.localDb.LocalDb()


def create_access_token(data: dict, expires_delta: timedelta | None = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)

    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


async def get_current_user(token: str = Depends(oauth2_scheme)):
    credential_exception = HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                                         detail="Could not validate credentials", headers={"WWW-Authenticate": "Bearer"})
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str | None = payload.get("sub")
        if username is None:
            raise credential_exception

        token_data = TokenData(username=username)
    except JWTError:
        raise credential_exception

    user = db.get_user(username)

    return user if user else credential_exception
    # if user is None:
    #     raise credential_exception

    # return user


async def get_current_active_user(current_user: UserInDB = Depends(get_current_user)):
    # if current_user.disabled:
    #     raise HTTPException(status_code=400, detail="Inactive user")

    return current_user


@fastApp.post("/register")
async def register_user(registerUser: UserInDB):
    isAlready = not db.addRegisterUser(registerUser)
    print(registerUser)
    if isAlready:
        raise HTTPException(status_code=400, detail="User ALready Exist")
    return "Lol"


@fastApp.post("/token", response_model=Token)
async def login_for_access_token(form_data: OAuth2PasswordRequestForm = Depends()):
    user = db.authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED,
                            detail="Incorrect username or password", headers={"WWW-Authenticate": "Bearer"})

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.username}, expires_delta=access_token_expires)

    return {"access_token": access_token, "token_type": "bearer"}


@fastApp.get("/users/me/", response_model=UserBase)
async def read_users_me(current_user: UserBase = Depends(get_current_active_user)):
    return current_user


@fastApp.get("/users/me/items")
async def read_own_items(current_user: UserBase = Depends(get_current_active_user)):
    return [{"item_id": 1, "owner": current_user}]


class T(BaseModel):
    username: str


@fastApp.get("/publicKey/{username}")
async def get_user_public_key(username, user: UserInDB = Depends(get_current_active_user)):
    print(username)
    recUser = db.get_user(username)
    if not recUser:
        raise HTTPException(
            status_code=400, detail="Invalid Receiver username")
    return {"publicKey": recUser.publicKeyStr, "username": recUser.username}
