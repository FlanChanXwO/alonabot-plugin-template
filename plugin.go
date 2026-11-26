package plugin

import "github.com/AlonaBot/AlonaBot/sdk"

func New() *sdk.Plugin {
	p := sdk.NewPlugin()
	p.Command("hello").Menu().Description("Show a greeting").Handle(func(c *sdk.Context) error {
		return c.Reply("Hello AlonaBot")
	})
	return p
}
