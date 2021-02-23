---
title: 很古典的思维catthefish2021
date: 2021-02-16 14:27:29
author: ljahum 
tags: 
- crypto

categories: 
- CTF

---

> 蛮有意思的小case

整个题的核心再这里

```python
return e == hashs(m, s*G + e*P, s*hashp(P) + e*I)
```

除要求输入的参数 e , s 和点 I 外其他参数都是给出了的，所以需要选取事等式实现的e s I，但hashs是单向的
所以构造常规的等式并不现实，将hashs参数设为 $hashs（ m ，A ，B）$ 进行思考，

由于无法从e推到A和B 不妨假设A B已知,得到

$e=hashs(m,A,B)$

有
$$
\begin{cases}
A = s\cdot G+e\cdot P\\
B = s\cdot H_p(p)+e\cdot I
\end{cases}
$$
不妨令$A= a\cdot G\;,B= b\cdot G$ 并且输入的 $I$一定在ecc上

故有
$$
\begin{cases}
a\cdot G = s\cdot G+e\cdot P\\
b\cdot G = s\cdot H_p(p)+e\cdot I
\end{cases}
\to
\begin{cases}
s = a - ex\\
  iG=(b\cdot G-s\cdot H_p(p))\cdot e^{-1} 
\end{cases}
$$
$$e=hashs(m,aG,bG)$$

那么接下来的任务就是去找a和b了

a和b的范围还有约束条件除了满足e有逆元外好像完全没有任何头绪,但是G的选取帮了我们大忙

由于G是生成元,所以不用担心会不存在使
$$
\begin{cases}
A = s\cdot G+e\cdot P\\
B = s\cdot H_p(p)+e\cdot I
\end{cases}
$$
成立的$e ,s, I$

经验证,只需要满足e能够取到逆元就ok了



```python
# sage
# -*- encoding: utf-8 -*-
'''
@File    :   exp_me.sage
@Time    :   2021/02/10 15:05:20
@Author  :   ljahum 
@Contact :   roomoflja@gmail.com
@Desc    :   None
'''

# code here

from os import environ
environ['PWNLIB_NOTERM'] = 'True'
from pwn import remote
from hashlib import sha256


ha = lambda x: x if isinstance(x, int) or isinstance(x, Integer) else product(x.xy())


hashs = lambda *x: int.from_bytes(
    sha256(b'.'.join([b'%X' % ha(x) for x in x])).digest(), 'little') % p


def hashp(x):
    x = hashs((x))
    while True:
        try:
            return E.lift_x(x)
        except:
            x = hashs((x))


E = EllipticCurve(GF(2 ^ 255 - 19), [0, 486662, 0, 1, 0])
p = E.order()
ZmodP = Zmod(p)
G = E.lift_x(9)
cn = remote('0.0.0.0', 10000)
data = cn.recvline().decode().strip()
print(data)
x = int(data.split()[0])
P = x*G
m = int(data.split()[-1])

tot =0 
while tot <8:
    a = randint(1, p)
    b = randint(1, p)
    aG = a*G
    bG = b*G
    e = hashs(m, aG, bG)
    if not e & 1: 
        print('try again')
        continue
    s =  a - e*x
    e_inv = inverse_mod(e,p)
    I = e_inv*(bG - s*hashp(P))
    Ix = I.xy()[0]
    Iy = I.xy()[1]
    cn.sendlineafter('I (x): ', str(Ix))
    cn.sendlineafter('I (y): ', str(Iy))
    cn.sendlineafter('e: ', str(e))
    cn.sendlineafter('s: ', str(s))
    cn.recvline()
    tot += 1
print(cn.recvall())

```

