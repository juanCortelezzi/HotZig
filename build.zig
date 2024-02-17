const std = @import("std");
const raylib = @import("raylib-5.0/src/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const raylib_path = "./raylib-5.0/src";
    const ray = raylib.addRaylib(b, target, optimize, .{
        .raudio = true,
        .rmodels = true,
        .rshapes = true,
        .rtext = true,
        .rtextures = true,
        .raygui = false,
        .platform_drm = false,
    });

    const plug = b.addSharedLibrary(.{
        .name = "plug",
        .root_source_file = .{ .path = "src/plug/plug.zig" },
        .target = target,
        .optimize = optimize,
    });

    plug.linkLibrary(ray);
    plug.addIncludePath(.{ .path = raylib_path });
    b.installArtifact(plug);

    const exe = b.addExecutable(.{
        .name = "core",
        .root_source_file = .{ .path = "src/core/core.zig" },
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    exe.linkLibrary(ray);
    exe.addIncludePath(.{ .path = raylib_path });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_cmd.step);
}
