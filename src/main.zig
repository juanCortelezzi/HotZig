const std = @import("std");
const c = @cImport({
    @cInclude("raylib.h");
});

const SCREEN_WIDTH = 800;
const SCREEN_HEIGHT = 450;
const GRAVITY: f32 = 0.9;

const Player = struct {
    position: c.Vector2,
    size: c.Vector2,
    velocity: c.Vector2,
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
        .size = .{
            .x = 20,
            .y = 20,
        },
        .velocity = .{
            .x = 0,
            .y = 0,
        },
        .jumping = false,
    };

    var jump_time: f32 = 0;
    var jumping_locked = false;
    const initial_jump_velocity = 100;

    while (!c.WindowShouldClose()) {
        // UPDATE
        if (c.IsKeyDown(c.KEY_SPACE) and !player.jumping and !jumping_locked) {
            player.velocity.y = initial_jump_velocity;
            player.jumping = true;
            jumping_locked = true;
            jump_time = 0;
        }

        if (c.IsKeyDown(c.KEY_R)) {
            jumping_locked = false;
            player.velocity.y = 0;
            player.position.y = SCREEN_HEIGHT - 100;
        }

        if (player.jumping) {
            jump_time += c.GetFrameTime();

            // y = v0 * t - 0.5 * g * t^2
            // v = v0 - g * t

            const delta_y = initial_jump_velocity * jump_time - 0.5 * GRAVITY * std.math.pow(f32, jump_time, 2);
            if (player.velocity.y < 0) {
                player.position.y += delta_y;
            } else {
                player.position.y -= delta_y;
            }

            var vel_is_pos = player.velocity.y > 0;
            player.velocity.y -= (initial_jump_velocity / 10) - GRAVITY * jump_time;
            if (vel_is_pos and !(player.velocity.y > 0)) {
                jump_time = 0;
            }

            if (player.position.y > SCREEN_HEIGHT - 100) {
                player.position.y = SCREEN_HEIGHT - 100;
                player.jumping = false;
            } else if (player.position.y < 0) {
                player.position.y = 0;
                player.jumping = false;
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

        msg = try std.fmt.bufPrintZ(&buffer, comptime "velocity: {}", .{@as(i32, @intFromFloat(player.velocity.y))});
        c.DrawText(msg, 10, offset, 20, c.DARKGRAY);
        offset += 20;
        c.DrawRectangleV(player.position, player.size, c.RED);
    }
}
