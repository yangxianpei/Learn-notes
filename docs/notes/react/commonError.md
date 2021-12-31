# react 常见错误

## hook 组件加载后又卸载

1. hook 组件加载了, 当它卸载后去改变它内部的 useState 方法,浏览器将会报 warn.
   <img src="/Learn-notes/react/react1.png" />

- 解决方式: 尽量避免这类情况, 应当确保改变 useState 的时候,组件未卸载.
  <img src="/Learn-notes/react/react2.png" />

## 更多

121
