from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.primitives.asymmetric import padding
import cryptography.hazmat.primitives.hashes as hashes
from passlib.context import CryptContext


def generate_key_pair():
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048
    )
    public_key = private_key.public_key()
    return public_key, private_key


def pubKeyEncode(publicKey: rsa.RSAPublicKey):
    return publicKey.public_bytes(encoding=serialization.Encoding.PEM,
                                  format=serialization.PublicFormat.SubjectPublicKeyInfo)


def pvtKeyEncode(privateKey: rsa.RSAPrivateKey):
    return privateKey.private_bytes(encoding=serialization.Encoding.PEM,
                                    format=serialization.PrivateFormat.TraditionalOpenSSL,
                                    encryption_algorithm=serialization.NoEncryption()
                                    )


def pubKeyDecode(pemKeyBytes):
    return serialization.load_pem_public_key(pemKeyBytes, backend=default_backend())


def pvtKeyDecode(pemKeyBytes):
    # type: ignore
    return serialization.load_pem_private_key(pemKeyBytes, backend=default_backend(), password=None)


def encrypt(message, public_key):
    ciphertext = public_key.encrypt(
        message.encode('utf-8'),
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )

    )
    return ciphertext


def decrypt(ciphertext, private_key):
    plaintext = private_key.decrypt(
        ciphertext,
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()),
            algorithm=hashes.SHA256(),
            label=None
        )

    )
    return plaintext.decode('utf-8')


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def get_password_hash(password):
    return pwd_context.hash(password)


def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)
