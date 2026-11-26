// Package example 提供示例插件的公开构造入口。
package example

import (
	"github.com/AlonaBot/AlonaBot/sdk"
	implementation "github.com/OWNER/alonabot-plugin-example/internal/example"
)

// New 创建独立插件并登记全部命令。
func New() *sdk.Plugin {
	p := sdk.NewPlugin()
	implementation.Register(p)
	return p
}
