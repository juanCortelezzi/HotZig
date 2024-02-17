const std = @import("std");
const utils = @import("utils.zig");
const plug = @import("../plug/plug.zig");
const c = @cImport({
    @cInclude("raylib.h");
});

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 450;

const GameState = struct {
    age: u32,
};

const Gamelib = struct {
    init: *const fn (*GameState) void,
    update: *const fn (*GameState) void,
};

pub fn main() !void {
    c.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Dino Game");
    defer c.CloseWindow();
    c.SetTargetFPS(60);

    var dynlib = try utils.loadLibrary(Gamelib, "./zig-out/lib/libplug.so");

    std.debug.print("dynlib: '{}'\n", .{dynlib});

    var game_state: *GameState = undefined;
    dynlib.symbols.init(game_state);

    while (!c.WindowShouldClose()) {
        if (c.IsKeyDown(c.KEY_R)) {
            dynlib.deinit();
            dynlib = try utils.loadLibrary(Gamelib, "./zig-out/lib/libplug.so");
        }

        dynlib.symbols.update(game_state);
    }

    dynlib.deinit();
}
