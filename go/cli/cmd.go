package cli

import (
	"bufio"
	"context"
	"flag"
	"fmt"
	"io"
	"os"
	"strings"
	"text/template"
	"unicode"
	"unicode/utf8"
)

var usageTemplate = `{{.Long | trim}}

Usage:
	{{.Name}} {{if .HasSubCommand}}<command>{{end}} [options]

The commands are:
{{range .GetSubCommands}}{{if or (.Runnable) .HasSubCommand}}
	{{.Name | printf "%-11s"}} {{.Short}}{{end}}{{end}}

Use "{{.Path}} help <command>" for more information about a command.
`

var helpTemplate = `{{if .Runnable}}usage: {{.Name}} [options]{{end}}
	{{.Long | trim}}
`

func capitalize(s string) string {
	if s == "" {
		return s
	}
	r, n := utf8.DecodeRuneInString(s)
	return string(unicode.ToTitle(r)) + s[n:]
}

// An errWriter wraps a writer, recording whether a write error occurred.
type errWriter struct {
	w   io.Writer
	err error
}

func (w *errWriter) Write(b []byte) (int, error) {
	n, err := w.w.Write(b)
	if err != nil {
		w.err = err
	}
	return n, err
}

// tmpl executes the given template text on data, writing the result to w.
func tmpl(w io.Writer, text string, data interface{}) {
	t := template.New("top")
	t.Funcs(template.FuncMap{"trim": strings.TrimSpace, "capitalize": capitalize})
	template.Must(t.Parse(text))
	ew := &errWriter{w: w}
	err := t.Execute(ew, data)
	if ew.err != nil {
		// I/O error writing. Ignore write on closed pipe.
		if strings.Contains(ew.err.Error(), "pipe") {
			os.Exit(1)
		}
		//base.Fatalf("writing output: %v", ew.err)
	}
	if err != nil {
		panic(err)
	}
}

func printUsage(w io.Writer, cmd *Command) {
	bw := bufio.NewWriter(w)
	tmpl(bw, usageTemplate, cmd)
	bw.Flush()
}

// A Command is an implementation of a go command
// like go build or go fix.
type Command struct {
	// Run runs the command.
	// The args are the arguments after the command name.
	Run func(ctx context.Context, cmd *Command, args []string)

	UsageLine string

	// Short is the short description shown in the 'go help' output.
	Short string

	// Long is the long message shown in the 'go help <this-command>' output.
	Long string

	// Flag is a set of flags specific to this command.
	Flag flag.FlagSet

	// CustomFlags indicates that the command will do its own
	// flag parsing.
	CustomFlags bool

	// commands lists the available commands and help topics.
	// The order here is the order in which they are printed by 'go help'.
	// Note that subcommands are in general best avoided.
	commands []*Command

	parent *Command
}

// Name returns the command's short name: the last word in the usage line before a flag or argument.
func (c *Command) Name() string {
	name := c.UsageLine
	if i := strings.Index(name, " "); i >= 0 {
		name = name[0:i]
	}
	return name
}

func (c *Command) Path() string {
	if c.parent == nil {
		return c.Name()
	}
	return c.parent.Path() + " " + c.Name()
}

func (c *Command) Usage() {
	c.Help(os.Stderr)
	os.Exit(1)
}

// Runnable reports whether the command can be run; otherwise
// it is a documentation pseudo-command such as importpath.
func (c *Command) Runnable() bool {
	return c.Run != nil
}

func (c *Command) NewSubCommand(sc *Command) {
	c.commands = append(c.commands, sc)
}

func (c *Command) FindCommand(args []string) (*Command, []string, error) {
	if len(c.commands) == 0 {
		return c, args, nil
	}
	if len(args) == 0 {
		return c, args, fmt.Errorf("not enough args for command:%s", c.Name())
	}
	for _, cmd := range c.commands {
		if cmd.Name() != args[0] {
			continue
		}
		return cmd.FindCommand(args[1:])
	}
	return c, args, fmt.Errorf("unexpected arg for command:%s", c.Name())
}
func (c *Command) Help(w io.Writer) {
	if len(c.commands) > 0 {
		printUsage(w, c)
	} else {
		tmpl(w, helpTemplate, c)
	}
	// not exit 2: succeeded at 'go help cmd'.
}

func (c *Command) HasSubCommand() bool {
	return len(c.commands) > 0
}

func (c *Command) GetSubCommands() []*Command {
	return c.commands
}
