---
title: 一次SMC的实现
date: 2020-05-09 00:58:50
tags:
- bin
categories:
- posts
---

# VC6实现SMC动态代码加密技术 

> 自己做re经常碰到smc，折腾久了也会手痒痒自己弄一个，算是对PE结构的巩固。。。技术本身也不太难懂，折腾完发现也没弄出啥有技术含量的东西，就算作学习加密技术的一个开端吧

### 预备知识：

- pe结构

- C语言功底

### 添加区块：

  相对汇编编写smc，C语言编写smc一大缺点就是难以准确定位到某个函数，所以要用到添加段的操作，以区块为加密单位，所以讲要加密的代码放到一个新区块中

  ```cpp
  #pragma code_seg(".SMC")
  void fun()
  {	
  	puts("You got my secrets =.= \n");
  }
  #pragma code_seg()
  #pragma comment(linker, "/SECTION:.SMC,ERW")
  ```

  #pragma code_seg(".SMC") 表示将代码放入 .SMC 段中

  后面还要跟一个 #pragma code_seg( ) 是为了把其余代码放入原本的段中

  #pragma comment(linker, "/SECTION:.SMC,ERW") 设置段的属性位可读写，没有这一步也可以用 VirtualProtect 进行修改

运行程序应该看到fun()是可以正常运行的,若使用 vs20xx 可能需要修改一下编译的设置才能成功生成新段

### 定位区块：

首先需要定位到镜像文件的基址

```cpp
HMODULE pBuf = GetModuleHandle(0);
```

通过基找到程序的 DOS 头(PIMAGE_DOS_HEADER 类型)，再通过 DOS 头找到 PE 文件头(PIMAGE_NT_HEADERS32 类型)：

```cpp
pDH = (PIMAGE_DOS_HEADER)pBuf;
pNtH = (PIMAGE_NT_HEADERS32)((DWORD)pBuf + pDH->e_lfanew);
```

利用 PE 文件头找到第一个段和段的总数：

```cpp
Snum = pNtH->FileHeader.NumberOfSections;
pSH = IMAGE_FIRST_SECTION(pNtH);
```

通过遍历每 Snum 个段对比段的 name 就可以定位到想要的段了。

集合上述方法编写了一个查找指定区段的函数：

```cpp
PIMAGE_SECTION_HEADER get_SH(char s[])
{
	char name[10];
    int Snum;
	HMODULE pBase = GetModuleHandle(0);
    
    PIMAGE_DOS_HEADER pDH;
    PIMAGE_NT_HEADERS pNtH;
    PIMAGE_SECTION_HEADER pSH;
    
    pDH = (PIMAGE_DOS_HEADER)pBase;

	pNtH = (PIMAGE_NT_HEADERS32)((DWORD)pBase + pDH->e_lfanew);
	
	Snum = pNtH->FileHeader.NumberOfSections;

	pSH = IMAGE_FIRST_SECTION(pNtH);

	for(int i = 0;i<Snum;i++)
	{
		memset(name,0,sizeof(name));
		memcpy(name,pSH->Name,8);
		if(strcmp(name,s)==0)
			return pSH;
		pSH++;
	}
    cout<<"sth worry!\n";
    system("pause");
    return pSH;
}
```

###  对代码进行操作：

对代码的操作有一点麻烦，用上面得到的目标段得到段首的偏移再加上映像文件的基址得到定位到真正的段首地址。

然后先把代码开始的位置转成一个 void 类型的指针，再把数据转成 BYTE 类型输出。

```cpp
void axor(void *soure,int len,int key)
{	
	printf("读取数据：\n");
	for(int i=0;i<len;i++)
		printf("%X\n",*((BYTE*)soure+i));//*((BYTE*)soure+i) = *((BYTE*)soure+i) ^ key;
		
}//段操作函数
    .
    .
    .
    .
void *Start = GetModuleHandle(0) + SH->VirtualAddress;
int size = SH->SizeOfRawData;
axor( soure, size, 4396)；//代码长度可能只占段很小一部分,所以 size 的值视情况而定

```



打印出来颇有一种一位位读取机器码的效果。


编写赋值语句尝试对机器码的值进行修改，动调查看流程确认无误后加入 key 对代码进行加密

  ```cpp
void axor(void *soure,int len,int key
{	for(int i=0;i<len;i++)
		*((BYTE*)soure+i) = *((BYTE*)soure+i) ^ key;
}
  ```

利用异或以外的加密方式可以提高 smc 的威力

把各个步骤整合到一起，编译

但是编译好的代码并没有对敏感代码进行加密，于是我们还需要直接对生成好的 pe 文件动刀，方法也很简单，只有找到位置一个个 BYTE 改就ok了，这里我做了一个读取文件的 demo ，因为代码不太长，所以试了试直接用 winhex 一位位抠也是可行的。。。。


最后把写好的程序放在这里：[smc1](http://roomoflja.cn/wp-content/uploads/2020/04/smc1.zip "smc1")
密码是：2077
smc 还是要配合上其他加密算法和保护手段才能发挥其真正威力，回头看自己折腾出来的代码总觉得很幼稚。。。

### 参考资料：
《加密与解密 第四版》11章
https://bbs.pediy.com/thread-201708.htm
https://blog.csdn.net/orbit/article/details/1497457