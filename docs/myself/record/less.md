 # less常用
 ### 变量定义
 ```less
    @primary-color: #3498db;
    body {
    color: @primary-color;
    }
 ```
 ### 嵌套规则
 ```less
      nav {
         ul {
            margin: 0;
            padding: 0;
            list-style: none;
         }
         li { display: inline-block; }
      }
 ```
 ### 混合（Mixin）
 ```less
   .border-radius(@radius) {
       border-radius: @radius;
      -webkit-border-radius: @radius;
      -moz-border-radius: @radius;
   }

   .button {
      .border-radius(5px);
   }
 ```

 ### 运算
```less
   @base: 5%;
   @width: @base * 2
```
### 条件语句
```less
   @theme: light;
   body {
   color: if(@theme == light, #000, #fff);
   }
```

### 循环
```less
   .generate-columns(@n) {
   .column {
      width: (@n * 100%) / 12;
   }
   }

   .generate-columns(3);
```

### 命名空间
```less
   #header {
   color: black;
   }
   #footer {
   color: red;
   }
```

### 函数颜色
```less
   @color: #336699;
   .lighter {
   color: lighten(@color, 20%); // 使颜色变亮
   }
```