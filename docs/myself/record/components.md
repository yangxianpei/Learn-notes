# 日常记录

## 写组件的一些学习笔记
1. 自定适配行数col组件, 一行24  假设配置了整行 span=2 就设置 col=16 一行也就2列,  如果某单行设置 1.5 就设置  24/2*1.5倍 . 利用 antd col组件来设置 一行大小 然后用弹性布局来自动换行
   <img src="/Learn-notes/dailyRecord/1.png" />
2. 组件里显示的样式
- 内部整体用弹性布局 
    <img src="/Learn-notes/dailyRecord/2.png" />

## rem布局 公式
1. 原理根据改变根元素的font-size 来计算页面大小  (屏幕的宽度 / 设计稿的大小 * 一个基数(例如100) = fontsize) 1920/1920*100 = 100,  fontSize= 100px 也就是 1rem = 100px   1px = 1/100 rem  10px = (1/100) *10
2. px 转rem: px / 基数(例如100)  
3. rem 转 px:  rem值 * 根元素   