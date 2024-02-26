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
