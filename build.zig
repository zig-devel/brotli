const std = @import("std");

const public_path = "c/include";

const common_sources = [_][]const u8{
    "c/common/transform.c",
    "c/common/shared_dictionary.c",
    "c/common/platform.c",
    "c/common/dictionary.c",
    "c/common/context.c",
    "c/common/constants.c",
};

const decoder_sources = [_][]const u8{
    "c/dec/state.c",
    "c/dec/huffman.c",
    "c/dec/decode.c",
    "c/dec/bit_reader.c",
};

const encoder_sources = [_][]const u8{
    "c/enc/utf8_util.c",
    "c/enc/static_dict.c",
    "c/enc/metablock.c",
    "c/enc/memory.c",
    "c/enc/literal_cost.c",
    "c/enc/histogram.c",
    "c/enc/fast_log.c",
    "c/enc/entropy_encode.c",
    "c/enc/encoder_dict.c",
    "c/enc/encode.c",
    "c/enc/dictionary_hash.c",
    "c/enc/compress_fragment_two_pass.c",
    "c/enc/compress_fragment.c",
    "c/enc/compound_dictionary.c",
    "c/enc/command.c",
    "c/enc/cluster.c",
    "c/enc/brotli_bit_stream.c",
    "c/enc/block_splitter.c",
    "c/enc/bit_cost.c",
    "c/enc/backward_references_hq.c",
    "c/enc/backward_references.c",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("brotli", .{});

    const mod = b.createModule(.{
        .link_libc = true,
        .target = target,
        .optimize = optimize,
    });

    const brotlicmn = cc_library(b, mod, upstream, "brotlicommon", &common_sources);
    brotlicmn.installHeadersDirectory(upstream.path(public_path), "", .{});

    const brotlidec = cc_library(b, mod, upstream, "brotlidec", &decoder_sources);
    const brotlienc = cc_library(b, mod, upstream, "brotlienc", &encoder_sources);

    // Smoke unit test
    const test_mod = b.addModule("test", .{
        .root_source_file = b.path("tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_mod.linkLibrary(brotlicmn);
    test_mod.linkLibrary(brotlidec);
    test_mod.linkLibrary(brotlienc);

    const run_mod_tests = b.addRunArtifact(b.addTest(.{ .root_module = test_mod }));

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}

fn cc_library(
    b: *std.Build,
    m: *std.Build.Module,
    upstream: *std.Build.Dependency,
    name: []const u8,
    sources: []const []const u8,
) *std.Build.Step.Compile {
    const lib = b.addLibrary(.{
        .name = name,
        .linkage = .static,
        .root_module = m,
    });
    lib.addIncludePath(upstream.path(public_path));
    lib.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = sources,
    });

    b.installArtifact(lib);

    return lib;
}
