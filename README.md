# compile-watch [![Build Status](https://travis-ci.org/Arcath/compile-watch.svg)](https://travis-ci.org/Arcath/compile-watch)

The last compiler package you need to install.

## Usage

Watch a file and everytime you save it compile-watch will compile it to your desired output location. When you close a file compile-watch will stop watching it. See _Project Config_ for details on how to make compile-watch even faster.

### Commands

- `Ctrl-Shift-W`, `Compile Watch: Watch` Watches the current file. You will be asked where to save the output.

### Project Config

compile-watch looks for a `.compile-watch.json` file in your projects root which allows you to:

 - Auto watch files
 - Pre-set the output of a file
 - Watch a parent file

An example config file:

```json
{
  "files": {
    "scss/layout.scss": {
      "output": "css/layout.css",
      "format": "scss"
    },
    "scss/imported.scss": {
      "parent": "scss/layout.scss"
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

This config file defined 3 files,

 - __scss/layout.scss__ which is to be compiled to _css/layout.css_ using the _scss_ format.
 - __scss/imported.scss__ which is to trigger a compile of its parent (which must be defined in this file).
 - __coffee/layout.coffee__ which is be compiled to _js/layout.js_ using the _coffee_ format.

It then declares 2 auto watch files which will be watched automatically when you open them. (These entries must match keys in the files object).

## Supported Languages

 - Coffee Script
 - LESS
 - SASS

### Adding a Language

All the _formats_ are stored in `lib/formats` and should be written as there own class.

The Coffee format in `lib/formats/coffee.coffee` shows an example of compiling a file using an _internal_ library and writing the output to the destination file.

The SASS format in `lib/formats/sass.coffee` shows an example of running a child process to compile the source file to the destination file.

There is a guide on how to write a compiler [here](http://arcath.net/2015/04/27/creating-the-less-compiler-for-compile-watch.html).
