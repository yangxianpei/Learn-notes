module.exports = {
  title: "学习笔记", // 设置网站标题
  description: "构建自己的前端体系", //描述
  base: "/Learn-notes/",
  dest: "./docs/.vuepress/build", // 设置输出目录
  port: 1234, //端口
  themeConfig: {
    //主题配置
    nav: [
      // {
      //   text: "前端笔记",
      //   link: "/components/basic/layout",
      // }, // 导航条
      {
        text: "前端笔记",
        items:[
          { text: "js", link: "/notes/js/js"},
          { text: "node", link: "/notes/node/node" }
        ]
      }, // 导航条
      {
        text: "个人随笔",
        link: "/myself/record/t",
      },
      { text: "github", link: "https://github.com/yangxianpei" },
    ],
    // 为以下路由添加侧边栏
    sidebar: {
      "/notes/js": [
        {
          title: "javaScript 进阶",
          collapsable: false,
          children: ["/notes/js/js", "/notes/js/promise"],
        },
      ],
      "/notes/node": [
        {
          title: "node",
          collapsable: false,
          children: ["/notes/node/node"],
        },
      ],
      "/myself": [
        {
          title: "个人随笔",
          collapsable: false,
          children: ["/myself/record/t", "/myself/record/d"],
        },
      ],
    },
  },
};
