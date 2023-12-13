#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run docs:build
echo '准备'
git init
git add .
git commit -m "2023/12/13 less笔记2"
echo '发布主分支'
# 如果发布到 master
git push -f git@github.com:yangxianpei/Learn-notes.git master

echo '发布子分支'
# 进入生成的文件夹
cd docs/.vuepress/build
git init
git add -A
git commit -m '2023/12/13 less笔记2'
# 如果发布到 gh-pages
echo '开始子分支上传'
git push -f git@github.com:yangxianpei/Learn-notes.git master:gh-pages
echo '子分支上传结束'
cd -