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
    const game_lib_install = b.addInstallArtifact(game_lib, .{});

    // macOS platform: compile Swift, link against the built game lib
    const macos_build_step = b.step("macos", "Build macos app");
    const macos_build_ouput = b.pathJoin(&.{ b.install_prefix, "zixport-macos" });
    const swiftc_cmd = b.addSystemCommand(&.{
        "swiftc",
        "macos/main.swift",
        "-import-objc-header",
        "include/game.h",
        "-L",
        b.pathJoin(&.{ b.install_prefix, "lib" }),
        "-lgame",
        "-o",
        macos_build_ouput,
    });
    swiftc_cmd.addFileInput(b.path("macos/main.swift"));
    swiftc_cmd.addFileInput(b.path("include/game.h"));

    swiftc_cmd.step.dependOn(&game_lib_install.step);
    macos_build_step.dependOn(&swiftc_cmd.step);

    // Run the app after building
    const macos_run_step = b.step("run-macos", "Run macos app");
    const macos_run_cmd = b.addSystemCommand(&.{macos_build_ouput});
    macos_run_cmd.step.dependOn(macos_build_step);
    macos_run_step.dependOn(&macos_run_cmd.step);
}
