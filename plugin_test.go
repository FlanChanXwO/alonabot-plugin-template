package plugin

import (
	"testing"

	"github.com/AlonaBot/AlonaBot/plugintest"
)

// TestCommands 用真实 Core 与测试 Adapter 走一遍全部命令。
func TestCommands(t *testing.T) {
	p := New()
	h := plugintest.Start(t, plugintest.Plugin(p))
	user := plugintest.User{ID: "alice"}
	chat := plugintest.Private(user.ID)

	reply := func(text string) string {
		t.Helper()
		result := h.Text(chat, user, text)
		if len(result.Sends) != 1 {
			t.Fatalf("%s: sends = %+v, want 1", text, result)
		}
		return result.Sends[0].Text()
	}

	if got := reply("/hello"); got != "Hello AlonaBot" {
		t.Errorf("/hello = %q", got)
	}
}
