---
title: openssl-rsa和一些有关pem格式秘钥的一些情报
date: 2020-10-09 15:33:01
tags:
- codes
- crypto

categories:
- posts
---
> 这种东西不记下来马上就会忘记
> openssl下载速度就十分玄学。。。最后要自己配环境变量

# openssl-rsa 基本使用


## 生成rsa密钥对（私钥）

- 生成2048bit长度
- 包含 e,d,n,q,p,dp,dq
 
`openssl genrsa -out privkey.pem 2048`

## 提取公钥

- 包含 n,e
`openssl rsa -in privkey.pem -pubout -out pubkey.pem`

## 提取csr证书
`openssl req -new -key privkey.pem -out ca.csr`

## 提取密钥信息

### 公私钥模数

`openssl rsa -in .\pubkey.pem -pubout -modulus`

`openssl rsa -in .\pubkey.pem -pubin -modulus`

### 提取所有信息

`openssl asn1parse -i -in privkey.pem`

公钥要指定偏移查看，bit string的偏移是19

![](https://i.loli.net/2020/10/12/eCbmTJQY4NkuAv3.png)

`openssl asn1parse -i -in .\pubkey.pem -strparse 19`



## pem、der格式转化

`openssl rsa -in .\private.pem -outform der  -out .\private.der`

# 除了生孩子什么都能干的python

crypto yyds

`from Crypto.PublicKey import RSA`



## 读取公钥信息
```python

rsakey = RSA.importKey(open("public.key", "r").read())
n = rsakey.n
e = rsakey.e
print("n=%\ne=%d",n,e)

```
## 生成秘钥对文件
```python

rsa = RSA.generate(2048)
public_key = rsa.publickey().exportKey()
f = open("public_key.key", "w")
f.write(public_key.decode())
f.close()
private_key = rsa.exportKey()

f = open("private_key.key", "w")
f.write(private_key.decode())
f.close()
```

## 对文件加解密

载入编码方式

`from Crypto.Cipher import PKCS1_OAEP`

```python
rsakey=RSA.importKey(open("public_key.key","r").read())
rsa = PKCS1_OAEP.new(rsakey)
encrypt = rsa.encrypt(flag.encode())

rsakey=RSA.importKey(open("private_key.key","r").read())
rsa = PKCS1_OAEP.new(rsakey)
decrypt = rsa.decrypt(f.read())
```

## 算得 n e d q p 生成 private_key.key

```python
rsa_components = (n, e, int(d), p, q)
rsa = RSA.construct(rsa_components)
public_key = rsa.exportKey()
# 此rsa与上文随机生成的rsa相同
f = open("public_key.key", "w")
f.write(public_key.decode())
f.close()
```