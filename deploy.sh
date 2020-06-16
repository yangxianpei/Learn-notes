#!/usr/bin/env sh

# 确保脚本抛出遇到的错误
set -e

# 生成静态文件
npm run docs:build

git init
git add .
git commit -m "master1"

# 如果发布到 https://<USERNAME>.github.io
git push -f git@github.com:yangxianpei/Learn-notes.git master

echo '发布子分支'
# 进入生成的文件夹
cd docs/.vuepress/build
git init
git add -A
git commit -m 'gh-pages1'
# 如果发布到 https://<USERNAME>.github.io/<REPO>
git push -f git@github.com:yangxianpei/Learn-notes.git master:gh-pages

cd -