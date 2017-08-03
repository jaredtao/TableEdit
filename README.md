# TableEdit


## 简介：

这是一个使用Qt + qml制作的表格编辑器。

主要是为了展示如何用qml中的TableView控件制作表格编辑器。

工程是从工作的项目里面单独扣出来的，内容上有些汽车行业相关的文字，请忽略。

当然工程里面也有一些常用组件的封装，比如Slack风格的按钮、带三角形箭头的ToolTip、Popup做自定义弹窗等。

## 效果图：

![Demo](Image/demo1.png)

## 功能：

* 从特定格式JSON文件导入数据
* 从表格导出数据到JSON文件
* 从表格独立创建数据
* 表格列的定制（不同的列用不同的组件和数据类型）
* 编辑表格内容，包括以行为单位的增、删、改、查
* 对行的增、删、改、查 操作，可以进行撤销、恢复
* 其它一些特殊规则的内容校验

## 开发环境

* Qt 5.9.0 Windows/Ubuntu

## 所用JSON格式介绍

如下
`
{

    "version": "0.0.1",

    "heartBeatInterval": 3000,
    
    "commands": [
            {
                "name": "applicationState" ,"bits": 8, "min": 0,
    
                "description": "0: 显示未初始化，例如开机视频播放,1: 开机动画进行中,2: 关机动画进行中,3: 自检中"
            }
        ],
        "signals": [
            {
                "bits": 8,
                "coefficient": 1,
                "description": "MCU临时版本",
                "invalid": "0xff",
                "max": 100,
                "min": 0,
                "name": "mcuVersionMin",
                "offset": 0
            },
            {
                "bits": 5,
                "coefficient": 1,
                "description": "MCU中版本号 交付版本，每次交付样机加一",
                "invalid": "0x1f",
                "max": 30,
                "min": 0,
                "name": "mcuVersionMid",
                "offset": 0
            },
            {
                "bits": 3,
                "coefficient": 1,
                "description": "MCU主版本号 SOP版本号，量产加一",
                "invalid": "0x7",
                "max": 6,
                "min": 0,
                "name": "mcuVersionMax",
                "offset": 0
            }
        ],
        "specialSignals": [
        ]
    }
`

