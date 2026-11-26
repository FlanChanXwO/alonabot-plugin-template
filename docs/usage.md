# Use the example plugin

[简体中文](usage.zh-CN.md)

After following the [README setup](../README.md), start development mode from the plugin root:

```fish
alonabot run . --data-dir ./data
```

Type `/hello` in the terminal. With the default configuration and English locale, it replies `Hello AlonaBot`. In a platform conversation, send the same command after configuring an Adapter; the command prefix follows Core configuration. See the [component documentation](https://alonabot.github.io/) for setup and installation.

## Configuration

[plugin_config_schema.json](../plugin_config_schema.json) declares one example string field, `recipient`, defaulting to `AlonaBot`. Set it to `World` in the plugin configuration to receive `Hello World`. For a development override, create `config.json` in the plugin's data directory, for example `data/plugins/alonabot-plugin-example/config.json` before renaming:

```json
{"recipient": "World"}
```

Restart the development command after editing configuration. Runtime data stays in the ignored `data/` directory.

## Languages

[i18n/en-US.json](../i18n/en-US.json) is the source catalog and contains only `messages` for replies. English command descriptions are declared with `.Description(...)` in [register.go](../internal/example/register.go). [i18n/zh-CN.json](../i18n/zh-CN.json) contains translated `messages` and `commands` overrides for Chinese menu descriptions. Replies use `c.T`, selecting the actor's locale, then the Core default, then English. With Simplified Chinese selected, `/hello` replies `你好，AlonaBot` (or the configured recipient).

To turn this example into your own plugin, replace the command and configuration, keep both dictionaries in sync, and update this page and its translation. Development details are in [development](development.md).
