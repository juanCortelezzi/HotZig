const std = @import("std");
const raylib = @import("raylib-5.0/src/build.zig");

// This has been tested to work with zig 0.11.0
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libraylib = raylib.addRaylib(b, target, optimize, .{
        .raudio = true,
        .rmodels = true,
        .rshapes = true,
        .rtext = true,
        .rtextures = true,
        .raygui = false,
        .platform_drm = false,
    });

    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = .{
            .path = "src/main.zig",
        },
        .target = target,
        .optimize = optimize,
    });

    exe.linkLibrary(libraylib);
    exe.addIncludePath(.{ .path = "./raylib-5.0/src" });
    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}
