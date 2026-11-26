package example

import (
	"testing"

	"github.com/AlonaBot/AlonaBot/plugintest"
)

// TestCommands 通过真实 Core 与测试 Adapter 验证命令和配置。
func TestCommands(t *testing.T) {
	for _, scenario := range []struct {
		name   string
		config string
		want   string
	}{
		{name: "default", config: `{}`, want: "Hello AlonaBot"},
		{name: "configured", config: `{"recipient":"World"}`, want: "Hello World"},
	} {
		t.Run(scenario.name, func(t *testing.T) {
			p := New()
			h := plugintest.Start(t, plugintest.Plugin(p), plugintest.Config(p, scenario.config))
			user := plugintest.User{ID: "example-user"}
			h.Text(plugintest.Private(user.ID), user, "/hello").RequireReply(t, scenario.want)
		})
	}
}
