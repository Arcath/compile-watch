# compile-watch [![Build Status](https://travis-ci.org/Arcath/compile-watch.svg)](https://travis-ci.org/Arcath/compile-watch)

Spiritual successor to [sass-watch], supports any kind of compiling.

## Usage

### Commands

- `Ctrl-Shift-W`, `Compile Watch: Watch` Watches the current file. You will be asked where to save the output.

### Project Config

compile-watch looks for a `.compile-watch.json` file in your projects root which allows you to:

 - Auto watch files
 - Pre-set the output of a file

An example config file:

```json
{
  "files": {
    "scss/layout.scss": {
      "output": "css/layout.css",
      "format": "scss"
    },
    "coffee/layout.coffee": {
      "output": "js/layout.js",
      "format": "coffee"
    }
  },

  "autowatch": [
    "scss/layout.scss",
    "coffee/layout.coffee"
  ]
}
```

## Supported Languages

 - Coffee Script
 - LESS
 - SASS

### Adding a Language

All the _formats_ are stored in `lib/formats` and should be written as there own class.

The Coffee format in `lib/formats/coffee.coffee` shows an example of compiling a file using an _internal_ library and writing the output to the destination file.

The SASS format in `lib/formats/sass.coffee` shows an example of running a child process to compile the source file to the destination file.

There is a guide on how to write a compiler [here](http://arcath.net/2015/04/27/creating-the-less-compiler-for-compile-watch.html).

[sass-watch]: https://github.com/Arcath/sass-watch
