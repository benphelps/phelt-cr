# phelt

[![Build Status](https://travis-ci.com/benphelps/phelt.svg?branch=master)](https://travis-ci.com/benphelps/phelt)

phelt is a toy programming language.

## Features

phelt is based on Monkey, as implemented in the Interpreter Book, with the following additions:

* Run code from files, not just a REPL.
* Improved error reporting, including line and column information.
* 64 bit Floats & Integers.
* Infix assignment operators `+=, -=, *= /=`.
* Additional comparsion operators, `<=, >=`.
* `do { }` blocks for scoped expressions.
* For loops, `for(initial; condition; final) { }`.
* `eval()` for executing code from string input.
* Arrays are mutable, with an extended array toolset.
* Truly constant constants, once defined they can never be redefined, regardless of scope.
* Fully reworked hashes. Hash keys are limited to identifiers and integers. You can access as well as index hash entries, `hash.entry` or `hash["entry"]` both work.
  * This allows for some level of psudo-class functionality.
  * This may be expanded upon in the future by implementing meta-functions on hashes.

## Installation

Once you have Crystal setup locally, simply run:

```sh
shards build phelt
```

The phelt interpreter can be found in the bin/ directory.

## Usage

```
Usage: phelt [command] [program file]
    -v, --version                    Show version
    -h, --help                       Show help
    -d, --debugger                   Interactive Debugger
    -i, --interactive                Interactive REPL
```

## Contributing

1. Fork it (<https://github.com/benphelps/phelt/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Ben Phelps](https://github.com/benphelps) - creator and maintainer
