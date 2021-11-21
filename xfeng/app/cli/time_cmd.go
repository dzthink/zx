package main

import (
	"context"
	"fmt"
	"os"
	"time"

	"github.com/dzthink/smart/xfeng/cli"
)

func init() {
	cmdTime.NewSubCommand(&cli.Command{
		UsageLine: "unix [timestr]",
		Short:     "print unix timestamp for timestr, default now",
		Long: `
A time tool for unix timestamp
unix - print current timetamp
unix "time string" - print the unix timestamp for "time string",now support time string are:
	"2021-11-21 00:00:00"
	"24 hours ago"
`,
		Run: cmdTimeUnixRun,
	})
}

var cmdTime = &cli.Command{
	UsageLine: "time <command> [options]",
	Short:     "tools for time",
	Long:      "tools for time",
}

func cmdTimeUnixRun(ctx context.Context, cmd *cli.Command, args []string) {
	if len(args) > 1 {
		cmd.Usage()
	}
	t := time.Now()
	if len(args) == 0 {
		fmt.Fprintln(os.Stdout, t.Unix())
		return
	}
	timeStr := args[0]
	fmt.Fprintf(os.Stdout, "unimplement for unix [%s]", timeStr)
}
