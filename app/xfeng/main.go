package main

import (
	"context"
	"os"

	"github.com/dzthink/smart/go/cli"
)

func main() {
	cliCommand := cli.NewCli("xfeng", "cli tools", "a cli tools develop by zx")
	cliCommand.NewSubCommand(cmdTime)
	cliCommand.Run(context.Background(), cliCommand, os.Args[1:])
}
