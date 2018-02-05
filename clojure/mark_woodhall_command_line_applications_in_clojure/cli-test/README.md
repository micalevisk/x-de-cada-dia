# cli-test

(c) [Command line applications in Clojure.](http://markwoodhall.com/26-06-2014-command-line-applications-in-clojure/)

## Usage

### Compile
```bash
lein compile :all # will generate a 'target' directory
```

### Run ~ using [tools.cli](https://github.com/clojure/tools.cli)

Command line application that represents a HTTP server and supports the following commands.
The application will print help when it receives an unexpected command or when it receives the `-h` option.

```bash
lein run -- --help
```
