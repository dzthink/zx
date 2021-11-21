package main

import (
	"context"
	"fmt"
	"time"

	"github.com/dzthink/smart/xfeng/cli"
)

func newTimeCmd() *cli.Command {
	return &cli.Command{
		Name:  "time.unix",
		Short: "print unix timestamp for time string,default now",
		Long:  "print unix timestamp for time string,defualt now",
		Run: func(ctx context.Context, cmd *cli.Command, args []string) {
			fmt.Println(time.Now().Unix())
		},
	}
}
