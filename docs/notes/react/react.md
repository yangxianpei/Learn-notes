# react 笔记
### react 自定义常用hook
```js
 // useRefState 
 //使用场景:
 const [A,setA]=useState(0)
 //异步的去设置setA,当前组件卸载后继续去设置会警告
 ```
  <img src="/Learn-notes/react/useRefState.png" />

```js
//useRefCallback
//使用常见: 当页面使用一个函数的时候,会产生一个闭包拿不到最新的值,固可以那useRefCallback包一下
```
  <img src="/Learn-notes/react/useRefCallback.png" />