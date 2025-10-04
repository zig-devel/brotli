# [brotli](https://github.com/google/brotli)@v1.1.0 [![Build and test library](https://github.com/zig-devel/brotli/actions/workflows/library.yml/badge.svg)](https://github.com/zig-devel/brotli/actions/workflows/library.yml)

Generic-purpose lossless compression algorithm.

## Usage

Install library:

```sh
zig fetch --save https://github.com/zig-devel/brotli/archive/refs/tags/1.1.0+0.tar.gz
```

Statically link with `mod` module:

```zig
const brotli = b.dependency("brotli", .{
    .target = target,
    .optimize = optimize,
});

mod.linkLibrary(brotli.artifact("brotlicommon"));
mod.linkLibrary(brotli.artifact("brotlidec")); // if decoder required
mod.linkLibrary(brotli.artifact("brotlienc")); // if encoder required
```

## License

All code in this repo is dual-licensed under [0BSD](./LICENSES/0BSD.txt) OR [MIT](./LICENSES/MIT.txt).
