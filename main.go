package main

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/jessevdk/go-flags"
	"github.com/pkg/errors"
	"go.starlark.net/repl"
	"go.starlark.net/starlark"
	"gopkg.in/yaml.v2"
)

type options struct {
	ScriptPath string `short:"s" long:"script" description:"path to Starlark script to execute" required:"true"`
}

func main() {
	opts := &options{}
	if _, err := flags.Parse(opts); err != nil {
		os.Exit(1)
	}

	thread := &starlark.Thread{
		Load: makeLoad(filepath.Dir(opts.ScriptPath)),
	}

	result, err := starlark.ExecFile(thread, opts.ScriptPath, nil, nil)
	if err != nil {
		log.Fatalf("error occurred while executing starlight script: %v", err)
	}

	outputs, ok := result["outputs"]
	if !ok {
		log.Fatalf("Starlark scripts didn't produce any config files to output")
	}

	outputsList, ok := outputs.(*starlark.List)
	if !ok {
		log.Fatalf("Starlark should produce a list of configuration objects, found %T instead", outputs)
	}

	iter := outputsList.Iterate()
	defer iter.Done()
	var v starlark.Value
	for iter.Next(&v) {
		// TODO: Convert v to a map[string]interface{} and output that.

		buf, err := yaml.Marshal(v)
		if err != nil {
			log.Fatalf("error occurred while marshalling object to YAML: %v", err)
		}

		// TODO: Write the bytes to a file.
		_ = buf
	}
}

// makeLoad returns a simple module loading function. It is a simple wrapper around
// `repl.MakeLoad` that ensures that all load calls are relative to the directory of
// the Starlark script we are executing.
func makeLoad(workingDir string) func(thread *starlark.Thread, module string) (starlark.StringDict, error) {
	f := repl.MakeLoad()

	return func(thread *starlark.Thread, module string) (starlark.StringDict, error) {
		// To ensure config generation is hermetic we require that all loads specify a module
		// with an explicit relative path.
		if !isExplicitRelativePath(module) {
			return nil, fmt.Errorf(
				"cannot load '%s', path to module must be relative (ie begin with ./ or ../)",
				module,
			)
		}

		path, err := filepath.Abs(filepath.Join(workingDir, module))
		if err != nil {
			return nil, errors.Wrapf(err, "failed to get absolute path to %s", module)
		}

		return f(thread, path)
	}
}

func isExplicitRelativePath(path string) bool {
	return strings.HasPrefix(path, "../") || strings.HasPrefix(path, "./")
}
