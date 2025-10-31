const std = @import("std");

const encoder = @cImport({
    @cInclude("brotli/encode.h");
});
const decoder = @cImport({
    @cInclude("brotli/decode.h");
});

fn formatVersion(buf: []u8, version: u32) ![]const u8 {
    const major = version >> 24;
    const minor = (version >> 12) & 0xFFF;
    const patch = version & 0xFFF;

    return std.fmt.bufPrint(buf, "{d}.{d}.{d}", .{ major, minor, patch });
}

// Just a smoke test to make sure the library is linked correctly.
test {
    const encoderVersion = encoder.BrotliEncoderVersion();
    const decoderVersion = decoder.BrotliDecoderVersion();

    var encoderVersionBuf: [16]u8 = undefined;
    var decoderVersionBuf: [16]u8 = undefined;

    const encVersionStr = try formatVersion(&encoderVersionBuf, encoderVersion);
    const decVersionStr = try formatVersion(&decoderVersionBuf, decoderVersion);

    try std.testing.expectEqual(encoderVersion, decoderVersion);

    try std.testing.expectEqualStrings(encVersionStr, "1.2.0");
    try std.testing.expectEqualStrings(decVersionStr, "1.2.0");
}
