// Package handler 处理示例命令的输入与回复，每个命令单独一个文件。
package handler

import "github.com/AlonaBot/AlonaBot/sdk"

// Hello 按调用语言向配置的接收者发送问候。
func Hello(c *sdk.Context, recipient string) error {
	return c.Reply(c.T("hello", "recipient", recipient))
}
