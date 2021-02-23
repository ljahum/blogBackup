---
title: ntru密码算法.md
date: 2021-02-22 19:22:03
author: ljahum 
tags: 
- crypto
- math
categories: 
- notes
hiddenFromHomePage: false

math:
  enable: true

---

[toc]



# timing attack

时序攻击属于侧信道攻击/旁路攻击

比如加解密的速度/加解密时芯片引脚的电压/密文传输的流量和途径等进行攻击的方式，一个词形容就是“旁敲侧击”。

某个函数负责比较用户输入的密码和存放在系统内密码是否相同，如果该函数是从第一位开始比较，发现不同就立即返回，那么通过计算返回的速度就知道了大概是哪一位开始不同的



center-lifts ?

# ntru密码算法

选取 n p q d

- n = 109 
- q = 2048
- p = 3

q > (6d+1)p

为公开参数



q 最好为2的幂,不能为3的倍数

取多项式 f g

prikey 

- f
- fq*f = 1 mod q
- g

pubkey
$$
h \equiv pg*f_{q}\;mod\;q
$$

### enc

取随机数 r,msg多项式化为m

c = rh+m mod q

### dec

a = f*c= f (rh +m )=fprh + fm  = f  *r *pg fq   mod q

a = rpg + m mod q

m = a mod p 



### 攻击实例

This attack breaks NTRU with n = 7, d = 5, q = 256.

```python


def convolution(f, g):
    return (f * g) % (x ^ n-1)
Zx.<x> = ZZ[]
n = 7
d = 5
q = 256

h=-82*x^6 + 118*x^5 - 94*x^4 + 108*x^3 + 70*x^2 - 122*x + 5

h3 = ((171)*h) % q
# lift(1/Integers(q)(p)) * h
M = matrix(2*n)
for i in range(n): M[i,i] = q
for i in range(n,2*n): M[i,i] = 1
for i in range(n):
    for j in range(n):
        M[i+n,j] = convolution(h3,x^i)[j]
print(M)
print(M.LLL()[0])
```

