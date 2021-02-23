---
title: 一点好玩的东西
date: 2020-12-27 20:50:38
author: ljahum 
tags: 
- crypto
- bin
categories: 
- CTF

---
# 一个逆向
> 解题思路逐渐离谱 
>                   ---- pandaos



## main
```python

from data import sums

def tolist(m):
    l = list(list(m)[0])
    return l

def xor(a,b):
    return eval("%s^%s" % (a, b))


def xorl(a, b):
    return [xor(a[i],b[i]) for i in range(42)]

def slove_flag(enc,m):
    enc = matrix(42, enc)
    m = matrix(42, 42, m)
    flag = m ^ (-1)*enc
    flag = (tolist(flag.T))
    flag = xorl(flag, xordata)
    return flag
xordata = [0xA0, 0xE4, 0xBA, 0xFB, 0x10, 0xDD, 0xAC, 0x65, 0x8D, 0x0B, 0x57, 0x1A, 0xE4, 0x28, 0x96, 0xB3, 0x0C, 0x79, 0x4D, 0x80, 0x90, 0x99, 0x58, 0xFE, 0x50, 0xD3, 0xF9, 0x3C, 0x0F, 0xC1, 0xE3, 0xA6, 0x39, 0xC3, 0x28, 0x75, 0xF8, 0xC9, 0xC8, 0xCD, 0x78, 0x26]

enc = [775008, 736965, 579982, 832102, 739711, 689694, 621261, 786007, 687380, 870278, 671072, 705346, 695702, 726075, 693811, 726115, 797388, 839688, 798029, 773858, 732406, 632966, 740936, 775656, 710214, 858672, 686622, 608896, 815068, 521720, 693197, 560581, 885102, 635306, 732285, 770318, 702253, 632762, 839978, 813599, 651986, 875709]
print(enc
ans=[]
for i in range(0x100):
    try:
        flag = bytes(slove_flag(enc,sums[i]))
        print(flag)
        ans.append(flag)
    except:
        
        continue
print(ans)
# b'flag{94bb46eb-a0a2-4a4a-a3d5-2ba877deb448}'
```

## data

利用srand(x)函数生成x=0~0xff的所有随机数数据

数据来源鸣谢 : c0rrsx2@syclover

数据：[data.py](https://github.com/ljahum/Crypto/blob/main/xctf-huawe-%E7%9F%A9%E9%98%B5%E6%B1%82%E8%A7%A3/data.py)

