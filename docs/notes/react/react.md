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


- react 里面的ref 
 1. useRef 和createRef 区别: 前者只会创建一次 , 后面每次会创建一个新的引用
 2. ref:原生 DOM 组件返回DOM引用, 类组件返回类实例, 函数组件没有Ref 必须配合forwardRef
 3. forwardRef: 使用 向下传递Ref属性 , 里面包一个函数,第二个参数就是ref 