import 'dart:convert';
import 'dart:typed_data';
import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/src/platform_check/platform_check.dart';
import "package:pointycastle/export.dart";

const A =
    "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAucNVIWtE4WJAOWi/VRI4\nfohDi1Ku2i9T5ZQGeEIUtqsW9pckAYagBk/qY5Uzsfoz4bxer5bPosUr2lt8PZxY\nsZA7+PF5QRpPxcFT7aLnE1GczJU0mFOUpzv+KQRr4VRY+wYeFaSpV/0zHD2TeEbL\nXcn3cfmT6xGH1qpNS3Yky4z10x0IEbbAZg+Rvh/BTS4ZzU862S7CZBixyWIIVuID\nyBRmEwuCFEHWQ6dLQY3qcNo1gUb6aPNATfELyVcLqYcdh62o+BuKIm3MJNujS3tk\n7RdiimniRAWAPaTQCcqj3hyeWzseeDNgGDDpYvQaYAGvHZx4/Qh4QSQUfT0REoCr\n7QIDAQAB\n-----END PUBLIC KEY-----\n";

const B =
    "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAucNVIWtE4WJAOWi/VRI4fohDi1Ku2i9T5ZQGeEIUtqsW9pck\nAYagBk/qY5Uzsfoz4bxer5bPosUr2lt8PZxYsZA7+PF5QRpPxcFT7aLnE1GczJU0\nmFOUpzv+KQRr4VRY+wYeFaSpV/0zHD2TeEbLXcn3cfmT6xGH1qpNS3Yky4z10x0I\nEbbAZg+Rvh/BTS4ZzU862S7CZBixyWIIVuIDyBRmEwuCFEHWQ6dLQY3qcNo1gUb6\naPNATfELyVcLqYcdh62o+BuKIm3MJNujS3tk7RdiimniRAWAPaTQCcqj3hyeWzse\neDNgGDDpYvQaYAGvHZx4/Qh4QSQUfT0REoCr7QIDAQABAoIBAFXIVi+wkYZjELVy\nIajvWRdVZZuY+xXWdS+3Q6WVHmucZmZJNV9fA9bmYJ7L76tolzzO+Aqt4gSQeMfF\nJ4JsCKk2qfszx4LA28W+mTtL1tmc/oObA0a0khkIIz5dxFOx18VT9eCYwXrYehm4\ndbk9N/x/n70KO7x5w/jle/w0+pjkHdfigT93n727HbsmqQRjRIi3HA3YetEUh1e6\nD1dfiPCnn/B5vJk4Av53z2R5e5W9sXofs6mF9bvlLq08p7zt5S0fIVyqPDXtFMkr\nWVg4gLML+XG17WP+/+mNStT2pSgYB/8S63k2SeWmcfOd5CLgyhchVXKbymE7YOp1\nYIylHyECgYEA2zoU2nOzjiH0Umejc+hLKVCi3+jr6Uj2/rICTg2jYNg86l4AX+fr\nJyqOAxdbjBW8jjjr6gCqGBu1xat08AzALYS3tx3xG6qfKJJssg/HPuFowjMioEUL\nb20Zzav0qE4za3a9RsnvrqXZpHedh3m04zVXocJacgbhG0XnMoQB9ecCgYEA2OxD\nuB+Yav8xag2RCsembv+WDRMkHqijN/YisjibaTY3B6Z64iGbiZ7/Cygowj7ANMja\ncKAZyyH3PhxvF6yQgxpn+8SMWCKZJ+JIwSgQPcSn0jvxy/YTI3y42mvmI10Lxyrp\nnwFIM2jdMZ2V2TQUhQ5oDwZKtWK/eGN4sc8SrQsCgYBwMbViZzxJTU9ArRGVzBhL\nOJ1igk3ZwiHGD0vmrkwi0Ae82gbPDl3mWXz8UAPmGWm6T59MzrI+TFAmrazW/W+M\n3BM5f/VY92Uk2msOZczOfYWjfZAG/c7wY6GFBK/dQshGAyqzA73KX86WwTC5mKve\na/pBKronCSZDUu8Th0OJmQKBgQCPRFvle1ibMjhcpuEokXvmy3862217oj1KdJGt\ny504+8mUj+uQ9klXt18S608gG3muYwmCYPsoIiK9LuJgbGR1cjdDHSjj/NXSda0/\nhUpUwVFllJm576fsRC+CcsjoikeBH2J01c/txFByuHWDotX6mu03Hxywd6ulw2yv\nYugeyQKBgHGOrjOAeTUHy+OgjfCwtfDcYlKE5PUejl7A80ziuDXK04fMfvFnUFyF\npviFkfJwdXi1AgaHoCiZEjOJ8pp/1mO01eXaQBvx9HhlXffnIQNCuLKzB4wrD3pj\nWQqodz6XgaesJmVECvkXLJERBfIKRb0jzbsPl1Y8+DKsTqhalCS1\n-----END RSA PRIVATE KEY-----\n";

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    {int bitLength = 2048, SecureRandom? secureRandom}) {
  // Create an RSA key generator and initialize it

  final keyGen = RSAKeyGenerator();

  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom ?? _secureRandom()));

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

SecureRandom _secureRandom() {
  final secureRandom = SecureRandom('Fortuna')
    ..seed(KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));
  return secureRandom;
}

void main() {
  final pair = generateRSAkeyPair();
  final public = pair.publicKey;
  final private = pair.privateKey;

  final newP = CryptoUtils.rsaPublicKeyFromPem(A);
  final newPvt = CryptoUtils.rsaPrivateKeyFromPemPkcs1(B);

  var t1 = CryptoUtils.rsaEncrypt("Hello", public);
  var t2 = CryptoUtils.rsaEncrypt("Hello", newP);
  print(CryptoUtils.rsaDecrypt(t1, private));
  print(CryptoUtils.rsaDecrypt(t2, newPvt));
}
