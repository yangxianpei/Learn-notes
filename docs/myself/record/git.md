# git 常用命令
```sh
# 初始化
git init

#拷贝
git clone [仓库地址]

#查看本地和远程全部分支
git branch -a

#查看远程分支
git branch -r

#同步远程某分支 并创建某分支 并会建立映射关系
 ## -b创建  origin/dev 是远程分支  你用git branch -a 看到的是会加前缀 remotes/origin/dev 
git checkout -b  dev origin/dev

#更新
git fetch

#拉取代码
git pull origin/dev

#上传代码
git push origin/dev

#合并代码
git merge xx



```