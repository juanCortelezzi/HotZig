const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
});

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 450;
const GRAVITY: f32 = 9.81;
const INITIAL_JUMP_VELOCITY: f32 = 50;

const Player = struct {
    position: c.Vector2,
    velocity: c.Vector2,
    size: c.Vector2,
    jumping: bool,
};

pub fn main() !void {
    c.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Dino Game");
    defer c.CloseWindow();
    c.SetTargetFPS(60);

    var player = Player{
        .position = .{
            .x = 50,
            .y = SCREEN_HEIGHT - 100,
        },
        .velocity = .{
            .x = 0,
            .y = 0,
        },
        .size = .{
            .x = 20,
            .y = 20,
        },
        .jumping = false,
    };

    var jump_time: f32 = 0;
    var jumping_locked = false;

    while (!c.WindowShouldClose()) {
        // UPDATE
        if (c.IsKeyDown(c.KEY_SPACE) and !player.jumping and !jumping_locked) {
            player.jumping = true;
            player.velocity.y = INITIAL_JUMP_VELOCITY;
            jumping_locked = true;
            jump_time = 0;
        }

        if (c.IsKeyDown(c.KEY_R)) {
            jumping_locked = false;
            player.position.y = SCREEN_HEIGHT - 100;
            player.velocity.y = 0;
        }

        if (player.jumping) {
            jump_time += c.GetFrameTime();
            const asdf = jump_time / 6;

            // y = v0 * t - 0.5 * g * t^2
            // v = v0 - g * t

            const delta_y = player.velocity.y * asdf - 0.5 * GRAVITY * std.math.pow(f32, asdf, 2);
            const delta_v = GRAVITY * asdf;

            player.position.y -= delta_y;
            player.velocity.y -= delta_v;

            if (player.position.y > SCREEN_HEIGHT - 100) {
                player.position.y = SCREEN_HEIGHT - 100;
                player.jumping = false;
            } else if (player.position.y < 0) {
                player.position.y = 0;
            }
        }

        // RENDER
        c.BeginDrawing();
        defer c.EndDrawing();
        c.ClearBackground(c.BLACK);

        var offset: c_int = 10;
        var buffer: [32]u8 = undefined;
        var msg: [:0]u8 = undefined;

        c.DrawText("Dino", 10, 10, 20, c.DARKGRAY);
        offset += 20;

        msg = try std.fmt.bufPrintZ(&buffer, comptime "isJumping: {}", .{player.jumping});
        c.DrawText(msg, 10, offset, 20, c.DARKGRAY);
        offset += 20;

        msg = try std.fmt.bufPrintZ(&buffer, comptime "position: {}", .{@as(i32, @intFromFloat(player.position.y))});
        c.DrawText(msg, 10, offset, 20, c.DARKGRAY);
        offset += 20;

        msg = try std.fmt.bufPrintZ(&buffer, comptime "jump_time: {}", .{@as(i32, @intFromFloat(jump_time))});
        c.DrawText(msg, 10, offset, 20, c.DARKGRAY);
        offset += 20;

        c.DrawRectangleV(player.position, player.size, c.RED);
    }
}
