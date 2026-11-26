// alonabot-plugin-example 命令运行示例插件。
package main

import (
	"log/slog"
	"os"

	"github.com/AlonaBot/AlonaBot/sdk"
	plugin "github.com/OWNER/alonabot-plugin-example"
)

func main() {
	if err := sdk.Run(plugin.New()); err != nil {
		slog.Error("Example plugin stopped", "error", err)
		os.Exit(1)
	}
}
