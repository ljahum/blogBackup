---
title: sagemath基础
date: 2020-11-24 20:46:21
author: ljahum 
hiddenFromHomePage: false"
tags:
- crypto
categories: 
- notes
math:
  enable: true

---
```python
#整数域,有理数域和实数域
ZZ(3)
QQ(0.25)
RR(2^0.5)
#复数域
CC(1,2)
#生成虚数单位i
i=ComplexField().gen();(2+i)*(4+3*i)

#构造多项式环,返回具有给定属性和变量名的全局唯一的单变量或多元多项式环
#定义在整数域上的多项式环R，变量为w;ZZ也可换成其他数域
R.<w>=PolynomialRing(ZZ);R
(1 + w)^3

#有限环
FR=Integers(17);FR
#自身的代数扩展;exR=FR[w]/(w^2+3)
exR=FR.extension(w^2+3)；exR
#以python整数的形式返回所有可逆元素的列表
FR.list_of_elements_of_multiplicative_group()
#假设环的乘法群是循环的，返回这个环的乘法群的生成元
FR.multiplicative_generator()
#返回这个环的一个随机元素
FR.random_element()
#上述几种方法对如下的域同样支持
    
#有限域
#素数域
G1=GF(37);G1
#伽罗瓦域
G2=GF(3^5);G2

# ans = c mod n 中国剩余定理扩展梭哈函数
# return ans, 通解的 ans+k*N (N = lcm([n1~ni]))
crt(c,n)

```

