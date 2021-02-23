---
title: 字节CTF2020
date: 2020-11-05 19:05:14
tags:
- crypto
categories:
- CTF

math:
  enable: true

---

## NOiSE 2021-1-19更新

- CRT 
- 同余式性质及其应用


$$
\begin{aligned}
n_i\times r_i\equiv c_i mod \;s \\\\
n_i r_i= c_i +k_is
\end{aligned}
$$

$r_i<s$



可以选取n的值得到

$n_i r_i= c_i +s$

$-c_i=  s\; mod\;n_i$

CRT得解
---

> ⑧说了，学到很多

[WP](https://www.cnblogs.com/coming1890/p/13902043.html)
# noise
题目附件[server](https://github.com/ljahum/Crypto/blob/main/BytesCTF2020/noise/server.py)

这个题核心点在这段代码上
    
     print(num * getrandbits(992) % secret)

num是输入，乘上一个992bits的随机数后返回模上 secret 的结果。

于是我们可以得到下式：

$n_i\cdot\ g_i\equiv c_i \;mod \;m$

$n_i\cdot\ g_i=c_i+k\cdot m$

则有

$0\equiv c_i+k\cdot m\; mod \;n_i$

若$k=1$则有下式

$n_i-c_i\equiv m\;mod\;n_i$

若能求出多个上述式子，则有几率使用**中国剩余定理**求出$m$

## 整点概率的东西

要$k=1$则需要$m<n_i\cdot g_i<2m$,因为$g,m$有固定的bit长度，想怼参数取对数分析：

$m,g$均有二分之一的概率分别大于$2^{1024},2^{992}$,当满足改条件时，设：

$$
log(m)=2^{1024}\cdot 2^\gamma,
log(n)=2^{32}\cdot 2^\beta ,
log(g)=2^{992}\cdot 2^\alpha
$$

可得下式：

$$
\gamma<\beta\cdot\alpha<\gamma +1
$$

已知我们只能控制 $n_i$ 即  $\beta$，又因为当$\beta$过小时会有$m>n_i\cdot g_i$则会出现$c_i=n_i\cdot g_i$,验证是否过小只需要验证$c_i\;mod \;n_i\neq\;0$就ok了

所以综上，应该将$n_i$控制的尽量小。

## 选取 $n$

因为我们求出的式子$n_i-c_i\equiv m\;mod\;n_i$需要满足CRT的成立条件故所以$n_i$应该均为素数。

这里用下式生成$n_i$:

    point = int(sqrt(1.1)*pow(2,32))
    ed = pow(2, 16)
    num = next_prime(getRandomRange(point-ed, point+ed))

## 编写代码测试算法

[test.py](https://github.com/ljahum/Crypto/tree/main/BytesCTF2020/noise)

![测试截图](https://i.loli.net/2020/11/05/fes91CBbVHFTKzx.png)

平均测试下来30~40次时可以打通的，在可接受范围内 =v=




