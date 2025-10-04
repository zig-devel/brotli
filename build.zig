const std = @import("std");

const public_path = "c/include";
const public_headers = [_][]const u8{
    "brotli/types.h",
    "brotli/port.h",
    "brotli/encode.h",
    "brotli/decode.h",
    "brotli/shared_dictionary.h",
};

const common_headers = [_][]const u8{
    "c/common/transform.h",
    "c/common/shared_dictionary_internal.h",
    "c/common/platform.h",
    "c/common/dictionary.h",
    "c/common/context.h",
    "c/common/constants.h",
    "c/common/version.h",
};

const common_sources = [_][]const u8{
    "c/common/transform.c",
    "c/common/shared_dictionary.c",
    "c/common/platform.c",
    "c/common/dictionary.c",
    "c/common/context.c",
    "c/common/constants.c",
};

const decoder_headers = [_][]const u8{
    "c/dec/state.h",
    "c/dec/prefix.h",
    "c/dec/huffman.h",
    "c/dec/bit_reader.h",
};

const decoder_sources = [_][]const u8{
    "c/dec/state.c",
    "c/dec/huffman.c",
    "c/dec/decode.c",
    "c/dec/bit_reader.c",
};

const encoder_headers = [_][]const u8{
    "c/enc/write_bits.h",
    "c/enc/utf8_util.h",
    "c/enc/static_dict_lut.h",
    "c/enc/static_dict.h",
    "c/enc/state.h",
    "c/enc/ringbuffer.h",
    "c/enc/quality.h",
    "c/enc/prefix.h",
    "c/enc/params.h",
    "c/enc/metablock_inc.h",
    "c/enc/metablock.h",
    "c/enc/memory.h",
    "c/enc/literal_cost.h",
    "c/enc/histogram.h",
    "c/enc/hash_longest_match_quickly_inc.h",
    "c/enc/hash_longest_match_inc.h",
    "c/enc/hash_longest_match64_inc.h",
    "c/enc/hash_forgetful_chain_inc.h",
    "c/enc/hash.h",
    "c/enc/find_match_length.h",
    "c/enc/fast_log.h",
    "c/enc/entropy_encode_static.h",
    "c/enc/entropy_encode.h",
    "c/enc/encoder_dict.h",
    "c/enc/dictionary_hash.h",
    "c/enc/compress_fragment_two_pass.h",
    "c/enc/compress_fragment.h",
    "c/enc/compound_dictionary.h",
    "c/enc/command.h",
    "c/enc/cluster.h",
    "c/enc/brotli_bit_stream.h",
    "c/enc/block_splitter_inc.h",
    "c/enc/block_splitter.h",
    "c/enc/bit_cost_inc.h",
    "c/enc/bit_cost.h",
    "c/enc/backward_references_hq.h",
    "c/enc/backward_references.h",
    "c/enc/histogram_inc.h",
    "c/enc/hash_to_binary_tree_inc.h",
    "c/enc/hash_rolling_inc.h",
    "c/enc/hash_composite_inc.h",
    "c/enc/cluster_inc.h",
    "c/enc/block_encoder_inc.h",
    "c/enc/backward_references_inc.h",
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

    const brotlicmn = cc_library(b, mod, upstream, "brotlicommon", &common_headers, &common_sources);
    brotlicmn.installHeadersDirectory(upstream.path(public_path), "", .{
        .include_extensions = &public_headers,
    });

    const brotlidec = cc_library(b, mod, upstream, "brotlidec", &decoder_headers, &decoder_sources);
    const brotlienc = cc_library(b, mod, upstream, "brotlienc", &encoder_headers, &encoder_sources);

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
    headers: []const []const u8,
    sources: []const []const u8,
) *std.Build.Step.Compile {
    const lib = b.addLibrary(.{
        .name = name,
        .linkage = .static,
        .root_module = m,
    });
    lib.addIncludePath(upstream.path(public_path));
    lib.installHeadersDirectory(upstream.path(""), "", .{
        .include_extensions = headers,
    });
    lib.addCSourceFiles(.{
        .root = upstream.path(""),
        .files = sources,
    });

    b.installArtifact(lib);

    return lib;
}
