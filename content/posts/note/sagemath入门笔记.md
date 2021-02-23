---
title: sagemath入门笔记.md
date: 2021-02-23 00:07:06
author: ljahum 
hiddenFromHomePage: false
tags:
- crypto
categories: 
- notes

math:
  enable: true


---

[toc]

<!--more-->

```python

SR.var('x',10) 创建 x数组[0~9]
# the same command works also with SR.var('a, b, c, x'
a, b, c, x = var('a, b, c, x')


a, x = var('a, x')
expr = cos(x+a) * (x+1)
expr
    (x+1)cos(a+x)
expr.subs(a == -x)
    x+1
expr.subs(x == pi, a == pi)
5cos(8)

substitute/subs 添加条件



n = var('n')
assume(n, 'integer') 不妨设 n 为整数
sin(n * pi) 
    0
assume(n > 0)
assumptions()将所有现存的假设作为条件输出
    [n is integer, n > 0] 
forget() 遗忘所有假设
```

## Sage还是简化符号表达式的强大工具。



```python
f=(x^2-1) / (x+1)
# (x^2 - 1)/(x + 1) 未知数f 拥有这些符号变量
```

# 生成常规ecc曲线

In Sage, an elliptic curve is always specified by (the coefficients of) a long Weierstrass equation

$y^2+a\_1xy+a\_3y=x^3+a\_2x^2+a\_4x+a\_6$

parameter2：EllipticCurve(p，[a1,a2,a3,a4,a6])

25519

```python
E = EllipticCurve(GF(2^255 - 19), [0, 486662, 0, 1, 0])
p = E.order()	# 求阶
ZmodP = Zmod(p) #构建环
G = E.lift_x(9) # x为9的点

```

*ctf ecc

```python

_F=GF(2**100)

_G = (_F.fetch_int(698546134536218110797266045394),_F.fetch_int(1234575357354908313123830206394))
_P = (_F.fetch_int(403494114976379491717836688842), _F.fetch_int(915160228101530700618267188624))

E = EllipticCurve(GF(2**100), [1, 2, 0, 0, 3])
# 常规点转为ecc点
G = E(G)
P = E(P)
```



## 多项式环

```python
R = PolynomialRing(Zmod(n), 'X')
X = R.gen()
f1 = (X)**e - c1
f2 = (X + delta)**e - c2
```

```python
return sympy.nextPrime((B!)%A)
```

# 解方程
```python
var('x')
sol = solve([x^2 - p_q*x + N == 0], [x])
print(sol) # sagemath会返回算式
```

# small_roots
```python
PR.<x> = PolynomialRing(Zmod(N))
f = p0 + x
f = f.monic()
roots = f.small_roots(X=2^430, beta=0.4)
if roots:
    p = p0 + roots[0]
print(p)
```