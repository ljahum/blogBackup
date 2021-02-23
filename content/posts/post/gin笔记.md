---
title: gin笔记.md
date: 2021-02-23 00:07:00
author: ljahum 

tags: 
- codes
categories: 
- posts
---

[toc]



# 这几天写gin的一些东西



# 登录

get得到html界面



post：

gin接受html表单传回的post数据

html的js接收gin传回的json实现前后端简单的交互

登录流程

1. 检测cookie是否已经登录
1. 检测用户名是非为空
1. 检测数据库中是非有改用户名
1. 检测密码

# 注册

注册流程

1. 检测cookie
1. 检测是非为空
1. 检测数据库是非有对应邮箱
1. 注册成功

后期加上邮箱格式验证（



# cookie
### setUserCookie

将该user的结构体json化传回

### logout

清除usercookie





