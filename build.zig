const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Build the game static library
    const game_lib = b.addLibrary(.{
        .linkage = .static,
        .name = "game",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/game.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    // macOS platform: compile Swift, link against the built game lib
    const macos_step = b.step("macos", "Build macOS app");

    const swift_compile = b.addSystemCommand(&.{
        "swiftc",
        "macos/main.swift",
        "-import-objc-header",
        "include/game.h",
        "-Xlinker",
        "-lgame",
        "-Xlinker",
    });
    swift_compile.addPrefixedDirectoryArg("-L", game_lib.getEmittedBinDirectory());
    swift_compile.addArgs(&.{
        "-framework", "Cocoa",
        "-o",
    });
    const exe = swift_compile.addOutputFileArg("zixport-macos");

    // Install the macOS binary (zig-out/bin/softrend-macos)
    const install_exe = b.addInstallBinFile(exe, "zixport-macos");

    // Run the app after building
    const run_cmd = b.addSystemCommand(&.{"zig-out/bin/zixport-macos"});
    run_cmd.step.dependOn(&install_exe.step);
    macos_step.dependOn(&run_cmd.step);

    // Default build only installs (no auto-run)
    b.getInstallStep().dependOn(&install_exe.step);
}
