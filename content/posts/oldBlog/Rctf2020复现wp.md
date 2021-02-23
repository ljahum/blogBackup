---
title: Rctf2020复现wp
date: 2020-06-07 23:35:06
tags: 
- bin
categories:
- CTF
---

> 太马了。。。。

# rust-flag

> 用rust语言编写代码看着很丑,加密流程却意外简单。。。。
## 分析
拖进ida一顿操作找到输入,再往后面找到输出错误的函数，下断点改流程发现没有输出 right 于是判断判断正误的字符串在之前被载入了要输出的字符串，于是往回找找到了一个大循环。。。。

给循环下断点发现里面有明显用来判断数据的 cmp 指令，循环次数刚好是 RCTF{ 的长度。。。。

![](http://roomoflja.cn/wp-content/uploads/2020/06/r2.png)

更改 RCTF{ 为其他字符判断使用了字符串的函数并跟进观察寄存器的变化，成功找到加密flag的位置

![](http://roomoflja.cn/wp-content/uploads/2020/06/r1.png)

接下来解比较简单了，先从内存中读出加密用的 key，由于提取密文的函数过于奇怪，干脆修改流程把所有密文记下来。

## exp:
```py
l1=[0x39,0x15,0x22,0xf4,0x95,0x70,0xe5,0x91,0x07,0x3d,0x8d,0xce,0x78,0xc2,0x52,0x9d,0xe1,0x8d,0x2e,0x6e]
l=[0x6b,0x56,0x76,0xb2,0xee,0x3,0xb1,0xe3,0x62,0x5c,0xe6,0x91,0x1d,0x93,0x27,0xfc,0x8d,0xf8,0x53,0x64,0xd7,0x25,0xee,0xe3,0xc8,0xab,0x93,0x86,0xa5,0xaf,0x8c,0xaf,0x4a,0xde,0x64,0x33,0x5d,0x18]
for i in range(len(l1)):
    print(chr(l1[i]^l[i]),end='')
```
> RCTF{sTreak_eQualu}

# cipher

> 太痛苦了。。。再也不想看这个题了

先拖到ghidra里面看伪代码大概复原后是这个样子的

## demo:
```cpp
    //i j为两个char类型的随机数
    x = (i << 56) | (j << 48);
    y = 0;
    a = (flag2 >> 8) + (flag2 << 56) + flag1 ^ x;
    b = (flag1 >> 61) + (flag1 << 3 ) ^ a;
    i = 0;
    while (i < 31)
    {   
        y = ((y >> 8) + (y << 56) + x) ^ i;
        x = ((x >> 61) + (x << 3)) ^ y;

        a = ((a >> 8) + (a << 56) + b) ^ x;
        b = ((b >> 61) + (b << 3)) ^ a;
        i = i + 1;
    }
```
注意 x和 y的变化都是由互相的值引起的，故 x 和 y 最终的状态只有 0x100^0x100种。通过爆破i、j可以得到最终的x、y

## 爆破demo：
```cpp
#include<iostream>
#include<stdlib.h>
using namespace std;
int main()
{
    for (uint64_t i = 0; i <= 0xfff; ++i)
    {
        for (uint64_t j = 0; j <= 0xfff; ++j)
        {
            uint64_t t;
            uint64_t b = 0x2a00f82be11d77c1;
            uint64_t a = 0xc3b171fc23d591f4;
            uint64_t x = (i << 56) | (j << 48);
            uint64_t y = 0;
            int i=0;
            while (i<31)
            {
                y = ((y >> 8) + (y << 56) + x) ^ i;
                x = ((x >> 61) + (x << 3)) ^ y;
                i += 1;
            }
            uint64_t t1,t2;
            t1=x;
            t2=y;
            i = 31;
            while (i > 0)
            {
                i -= 1;
                t = a ^ b;
                b = (t << 61) + (t >> 3); //b1

                t = a ^ x;
                t -= b;
                a = (t << 8) + (t >> 56);

                t = x ^ y;
                x = (t << 61) + (t >> 3);

                t = (y ^ i);
                t -= x;
                y = (t << 8) + (t >> 56);
            }
            t = a ^ b;
            b = (t << 61) ^ (t >> 3);
            t = (a ^ x) - b;
            a = (t << 8) + (t >> 56);

            t = b / 0x1000000;

            if (t == 0x524354467b)
            {
                cout<<hex<<"x="<<t1<<";"<<endl<<"y="<<t2<<";"<<endl;
                system("pause");
            }
        }
    }
    system("pause");
    return 0;
}
```

得到x、y
```cpp
        x = 0x411e3239d455bc70;
        y = 0x7eb3b6f1136403ac;
```
## exp：
```cpp
#include <iostream>
#include <stdlib.h>
using namespace std;
int main()
{
    uint64_t v[10] = {
        0x2a00f82be11d77c1,
        0xc3b171fc23d591f4,
        0x30f11e8bc2885957,
        0xd594ab77422feb75,
        0xe15d76f0466e98b9,
        0xb651fdb55d7736f2,
    };
    for (int j = 0; j < 3; j++)
    {
        uint64_t t;
        uint64_t b = v[j*2];
        uint64_t a = v[j * 2+1];
        uint64_t x;
        uint64_t y;
        int i = 0;
        x = 0x411e3239d455bc70;
        y = 0x7eb3b6f1136403ac;

        uint64_t t1, t2;
        t1 = x;
        t2 = y;

        i = 31;
        while (i > 0)
        {
            i -= 1;

            t = a ^ b;
            b = (t << 61) + (t >> 3); //b1

            t = a ^ x;
            t -= b;
            a = (t << 8) + (t >> 56);

            t = x ^ y;
            x = (t << 61) + (t >> 3);

            t = (y ^ i);
            t -= x;
            y = (t << 8) + (t >> 56);
        }
        t = a ^ b;
        b = (t << 61) ^ (t >> 3);
        t = (a ^ x) - b;
        a = (t << 8) + (t >> 56);
        t = b / 0x1000000;
        cout << hex << b << a ;
    }
    system("pause");
    return 0;
}
```
## py dome:
```cpp
import Crypto.Util.number
a=0x524354467b393837363233356533613962643639636662366234613364666364626361373066333035346639317d0a00
a = Crypto.Util.number.long_to_bytes(a)
print(a)

```

> b'RCTF{9876235e3a9bd69cfb6b4a3dfcdbca70f3054f91}

