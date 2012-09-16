A work in progress javascript port of opusenc thanks to emscripten

### Requirements

* emscripten from git
* wget
* whatever will break at configure time :)

### How to build

Set `EMSCRIPTEN` environemnt variable to a different value of `~/src/emscripten` if needed
Set `NODEJS` environment variable to a different value of `nodejs` if needed

```
# download and patch libogg, opus and opus-tools
make setup

# build opusenc.js
make

# convert test data to opus
make go
```

### License

IANAL the resulting work should be BSD licensed, see LICENSE
