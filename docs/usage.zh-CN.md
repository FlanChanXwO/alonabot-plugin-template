# 使用示例插件

[English](usage.md)

按 [README](../README.zh-CN.md) 准备环境后，在插件根目录启动开发模式：

```fish
alonabot run . --data-dir ./data
```

在终端输入 `/hello`。默认配置和英文语言下回复 `Hello AlonaBot`。配置 Adapter 后，在平台会话发送同一命令；命令前缀遵循 Core 配置。接入与安装步骤见[组件文档](https://alonabot.github.io/)。

## 配置

[plugin_config_schema.json](../plugin_config_schema.json) 声明一个示例字符串字段 `recipient`，默认值为 `AlonaBot`。在插件配置中改为 `World` 后，回复 `Hello World`。开发时可在插件数据目录创建 `config.json` 覆盖，例如改名前的 `data/plugins/alonabot-plugin-example/config.json`：

```json
{"recipient": "World"}
```

修改配置后重新启动开发命令。运行数据保存在已忽略的 `data/` 目录。

## 语言

[i18n/en-US.json](../i18n/en-US.json) 是源语言目录，仅包含回复用的 `messages`。英文命令说明在 [register.go](../internal/example/register.go) 中通过 `.Description(...)` 声明。[i18n/zh-CN.json](../i18n/zh-CN.json) 包含翻译后的 `messages`，并通过 `commands` 覆盖中文菜单说明。回复经 `c.T`，依次按 Actor 语言、Core 默认语言、英文选择。选择简体中文时，`/hello` 回复 `你好，AlonaBot`，或使用配置的问候对象。

将示例改成自己的插件时，替换命令与配置，同步维护两份词典、本页及其译文。实现细节见[开发指南](development.zh-CN.md)。
