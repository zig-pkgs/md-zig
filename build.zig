const std = @import("std");
const Sha1 = std.crypto.hash.Sha1;
const sha2 = std.crypto.hash.sha2;
const Md5 = std.crypto.hash.Md5;

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const config_h = b.addConfigHeader(.{
        .style = .{ .cmake = b.path("src/config.h.in") },
        .include_path = "md_config.h",
    }, .{
        .SHA1_CTX_SIZE = @sizeOf(Sha1),
        .SHA2_CTX_SIZE = @sizeOf(sha2.Sha256),
        .MD5_CTX_SIZE = @sizeOf(Md5),
    });

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("src/c.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    translate_c.addConfigHeader(config_h);
    translate_c.addIncludePath(b.path("include"));

    const lib = b.addLibrary(.{
        .name = "md",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/root.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "c", .module = translate_c.createModule() },
            },
        }),
    });
    lib.installConfigHeader(config_h);
    lib.installHeadersDirectory(b.path("include"), "", .{});
    b.installArtifact(lib);

    const mod_tests = b.addTest(.{
        .root_module = lib.root_module,
    });

    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
