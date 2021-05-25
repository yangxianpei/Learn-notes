# eslint 项目配置

```sh
# 初始化
npm init -y

#安装eslint 
npm i eslint -D
```
## 初始化eslint
```sh
npx eslint --init
```

## 检查和格式化文件
```sh
npx eslint yourfile.js
npx eslint yourfile.js --fix
```
> 也可以配置packjson.json script
```js

"scripts": {
  "lint": "eslint --ext .js,.vue,.ts ./ --fix",
}
```

## 配置eslint 插件
- vscode 插件配置 setting.json里
- 配置 ESLint 后在编辑器中保存(Ctrl + S)即会自动格式化。
```json
// eslint + format
"eslint.options": {
  "extensions": [
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".html",
    ".vue"
  ]
},
"eslint.validate": [
  "javascript",
  "javascriptreact",
  "typescript",
  "typescriptreact",
  "html",
  "vue"
],
"editor.codeActionsOnSave": {
  "source.fixAll.eslint": true,
}
```