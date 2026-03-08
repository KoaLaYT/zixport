const std = @import("std");
const Vec3 = @import("Vec3.zig");
// const cube = @import("cube.zig");
const penger = @import("penger.zig");

const WIDTH: u32 = 800;
const HEIGHT: u32 = 800;
const FPS: f32 = 60.0;

var framebuffer: [WIDTH * HEIGHT * 4]u8 = undefined;
var running: bool = true;

const Game = extern struct {
    display: [*]u8,
    display_width: u32,
    display_height: u32,
};

export fn game_init() Game {
    return .{
        .display = &framebuffer,
        .display_width = WIDTH,
        .display_height = HEIGHT,
    };
}

var g_angle: f32 = 0;

export fn game_update() bool {
    if (!running) return false;

    clear();

    const dt: f32 = 1 / FPS;
    g_angle += std.math.pi * dt;
    g_angle = @mod(g_angle, 2 * std.math.pi);

    for (penger.fs) |f| {
        const i, const j, const k = f;

        const x0, const y0 = penger.vs[i]
            .rotate_xz(g_angle)
            .translate_z(1.0)
            .project()
            .screen(WIDTH, HEIGHT);

        const x1, const y1 = penger.vs[j]
            .rotate_xz(g_angle)
            .translate_z(1.0)
            .project()
            .screen(WIDTH, HEIGHT);

        const x2, const y2 = penger.vs[k]
            .rotate_xz(g_angle)
            .translate_z(1.0)
            .project()
            .screen(WIDTH, HEIGHT);

        draw_line(x0, y0, x1, y1);
        draw_line(x1, y1, x2, y2);
        draw_line(x2, y2, x0, y0);
    }

    return true;
}

export fn game_key_down(keycode: u16) void {
    _ = keycode;
}

export fn game_key_up(keycode: u16) void {
    if (keycode == 0x0C) { // 'q' key
        running = false;
    }
}

const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,

    const background: Color = .{
        .r = 0,
        .g = 0,
        .b = 0,
        .a = 0xFF,
    };

    const foreground: Color = .{
        .r = 0x50,
        .g = 0xFF,
        .b = 0x50,
        .a = 0xFF,
    };
};

fn draw_line(x1: i64, y1: i64, x2: i64, y2: i64) void {
    const dx: i64 = @intCast(@abs(x1 - x2));
    var dy: i64 = @intCast(@abs(y1 - y2));
    dy = dy * -1;

    const sx: i64 = if (x1 < x2) 1 else -1;
    const sy: i64 = if (y1 < y2) 1 else -1;

    var err = dx + dy;
    var x0 = x1;
    var y0 = y1;
    while (true) {
        pixel(x0, y0);
        if (x0 == x2 and y0 == y2) break;

        const e2 = 2 * err;
        if (e2 >= dy) {
            err += dy;
            x0 += sx;
        }
        if (e2 <= dx) {
            err += dx;
            y0 += sy;
        }
    }
}

fn pixel(x: i64, y: i64) void {
    if (0 <= x and x < WIDTH and 0 <= y and y < HEIGHT) {
        const c = Color.foreground;
        const ux: usize = @intCast(x);
        const uy: usize = @intCast(y);
        const idx = (uy * WIDTH + ux) * 4;
        framebuffer[idx + 0] = c.b;
        framebuffer[idx + 1] = c.g;
        framebuffer[idx + 2] = c.r;
        framebuffer[idx + 3] = c.a;
    }
}

fn clear() void {
    const c = Color.background;
    var i: usize = 0;
    while (i < WIDTH * HEIGHT) : (i += 1) {
        const base = i * 4;
        framebuffer[base + 0] = c.b;
        framebuffer[base + 1] = c.g;
        framebuffer[base + 2] = c.r;
        framebuffer[base + 3] = c.a;
    }
}
