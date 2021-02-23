---
title: dicectf2021
date: 2021-02-23 18:20:30+08:00
author: ljahum 
description: "partial dicectf2021"
categories: 
- CTF
tags:
- crypto
hiddenFromHomePage: false
math:
  enable: true
---
<!--more-->


[toc]

## garbled

这个有意思了

---

文件里面给了一堆文件，并有一个示例文件和flag获取文件来调用整个加密电路

`from generate_garbled_circuit import g_tables, keys`

分析一遍数据生成流程

1. 生成了7组key，每组两个元素为 keyi0，keyi1 每个元素的小于2**24
1. 将7组数据按照“门”的指引得到 3 组加密后的 table 每组4行没行两个元素从左到右分别为 gl，v

具体流程如下，以第1组table生成的情况示例：

```python
input : key1,key2,key5
#  g_tables 钟元素的顺序
g_tables = {5: 
 [(g1, v1),
  (g2, v2),
  (g3, v3),
  (g4, v4)],
g1 = enc(key5_0,(key1_0,key2_0))
g2 = enc(key5_0,(key1_0,key2_1))
g3 = enc(key5_0,(key1_1,key2_0))
            
g4 = enc(key5_1,(key1_1,key2_1))
            
v1 = enc(0,(key1_0,key2_0))
v2 = enc(0,(key1_0,key2_1))
v3 = enc(0,(key1_1,key2_0))
            
v4 = enc(0,(key1_1,key2_1))
            
```

分析调用电路生成input的代码发现input的4个元素为   $key_{11},key_{21},key_{31},key_{41}$

evaluate_circuit 对 g_tables内容进行解密，恢复出  $key_{51},key_{61},key_{71}$

以第一组 g_tables 即 key1，key2，key5为例

```python
key5_1 = dec(g1, (key1_1, key2_1))

0 = dec(v1, (key1_1, key2_1))

def dec(data, key1, key2):
    decrypted = decrypt_data(data, key2)
    decrypted = decrypt_data(decrypted, key1)
    return decrypted
```

通过key1_1~4_1可以恢复出所有keyi_1

你问我为什么不恢复出所有key？

这就涉及到GarbledCircuit设计初衷了 ~~咕咕咕~~

对解密的场景可以扩展出这样的式子

```python
0 = dec(v1, (key1_0, key2_0))
0 = dec(v2, (key1_0, key2_1))
0 = dec(v3, (key1_1, key2_0))
0 = dec(v4, (key1_1, key2_1))
```

我们可以想办法找出所有的key1,key2开缩小范围，但2**48的复杂度是我们不愿意看到的，这里用中间相遇攻击的思想将复杂度降到$O(2\times2^{24})$,这是一个我们可以接受的范围

现在，我们得到了所有满足下式成立的key，需要我们想办法准确的定位地定位到 key1_1, key2_1

```python
0 = dec(v1, (key1_0, key2_0))
0 = dec(v2, (key1_0, key2_1))
0 = dec(v3, (key1_1, key2_0))
0 = dec(v4, (key1_1, key2_1))
```

由数据生成的代码我们可知：

```python
key5_0 = dec(g1, (key1_0, key2_0))
key5_0 = dec(g2, (key1_0, key2_1))
key5_0 = dec(g3, (key1_1, key2_0))

key5_1 = dec(g4, (key1_1, key2_1))
```

$algorithm1$

---
<div>
$$
assume (k11,k21)is\;global\;keys\\\\
there\;must\;exist\;\\\\
(k10,k21)\\\\
(k11,k20)\\\\
(k10,k20)\\\\
dec(g1, (key1\_0, key2\_0))=
dec(g2, (key1\_0, key2\_1))=
dec(g3, (key1\_1, key2\_0))
$$
</div>

综上，可以得到 key1_1, key2_1  的准确值







## plagiarism

algorithm：

So we have two ciphertexts:

C1 = P1e mod(N)

C2 = P2e mod(N)

where second text is simply first with known difference:

P2 = P1+δ

so we have after substitution:

f = P1e mod(N) - C1

g = (P1+δ)e mod(N) - C2

Calculating **GCD(f,g)** will give us common dividor **a \* P1 + b** so **P1 = -b⁄a**.



sage 多项式环算 gcd

```python

R = PolynomialRing(Zmod(n), 'X')
X = R.gen()
f1 = (X)**e - c1
f2 = (X + delta)**e - c2
r = gcd(f1, f2)
def hgcd(a0,a1):
    if a1.degree() <= (a0.degree()//2):
        return np.array([[1,0],[0,1]])

    m = a0.degree()//2
    X = a0.variables()[0]
    b0 = a0 // X**m
    b1 = a1 // X**m
    
    R = hgcd(b0,b1)
    [d,e] = (R.dot(np.array([a0,a1]).transpose())).transpose()
    ff = d % e
    m = m // 2
    g0 = e // X**m
    g1 = ff // X**m

    S = hgcd(g0,g1)
    q = d // e
    return S.dot(np.array([[0,1],[1,-q]])).dot(R)

def gcd(a0,a1):
    while True:
        print(a0.degree(), end=", ", flush=True)
        if a0 % a1 == 0:
            return a1
        if a0.degree() == a1.degree():
            a1 = a0%a1
        #print(a0.degree())
        R = hgcd(a0,a1)
        [b0,b1] = R.dot(np.array([a0,a1]).transpose()).transpose()

        if b0%b1==0:
            return b1
        c = b0 % b1
        a0 = b1
        a1 = c
```