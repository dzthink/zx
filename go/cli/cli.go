package cli

import (
	"context"
	"flag"
	"fmt"
	"os"
	"strings"
)

func NewCli(usageLine, short, long string) *Command {
	cmd := &Command{
		UsageLine: usageLine,
		Short:     short,
		Long:      long,
		Run:       cliRun,
	}
	cmd.Flag = *flag.NewFlagSet(cmd.Name(), flag.ContinueOnError)
	return cmd
}

func cliRun(ctx context.Context, cliCmd *Command, args []string) {
	if len(args) < 1 {
		cliCmd.Usage()
	}
	var withoutHelpArgs []string
	for _, arg := range args {
		if strings.EqualFold(arg, "help") {
			continue
		}
		withoutHelpArgs = append(withoutHelpArgs, arg)
	}
	if len(args)-len(withoutHelpArgs) > 1 {
		cliCmd.Usage()
	}
	cmd, remainArg, err := cliCmd.FindCommand(withoutHelpArgs)
	if err != nil {
		fmt.Fprintf(os.Stderr, "find command fail for %s, err:%s\n", cliCmd.Name(), err.Error())

		cmd.Help(os.Stderr)
		os.Exit(0)
	}
	if len(args)-len(withoutHelpArgs) == 1 {
		cmd.Usage()
	}
	if !cmd.Runnable() {
		fmt.Fprintf(os.Stderr, "%s is not runnalble", cmd.Name())
		cmd.Usage()
	}
	if cmd == cliCmd {
		cliCmd.Usage()
	}
	cmd.Flag.Usage = func() { cmd.Usage() }
	cmd.Flag.Parse(remainArg)
	args = cmd.Flag.Args()
	cmd.Run(ctx, cmd, args)
}
