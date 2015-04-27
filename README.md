# compile-watch [![Build Status](https://travis-ci.org/Arcath/compile-watch.svg)](https://travis-ci.org/Arcath/compile-watch)

Spiritual successor to [sass-watch], supports any kind of compiling.

## Usage

_soon_

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
