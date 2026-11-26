// Package example 集中登记示例插件的命令；业务逻辑也归本包所有。
//
// Register 连接 SDK 路由与 handler 包中的命令处理函数。
package example

import (
	"github.com/AlonaBot/AlonaBot/sdk"
	"github.com/OWNER/alonabot-plugin-example/internal/example/handler"
)

// Register 登记插件的全部命令。
func Register(p *sdk.Plugin) {
	p.Command("hello").Menu().Description("Show a greeting").Handle(func(c *sdk.Context) error {
		return handler.Hello(c, p.Config().String("recipient"))
	})
}
