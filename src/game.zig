const std = @import("std");

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

    for (0..fs.len) |i| {
        const a, const b = fs[i];

        const p1 = vs[a].rotate_xz(g_angle).translate_z(2.0).project().screen();
        const p2 = vs[b].rotate_xz(g_angle).translate_z(2.0).project().screen();

        draw_line(p1, p2);
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

const vs = [_]Vec3{
    .{ .x = 0.5, .y = 0.5, .z = 0.5 },
    .{ .x = 0.5, .y = -0.5, .z = 0.5 },
    .{ .x = -0.5, .y = -0.5, .z = 0.5 },
    .{ .x = -0.5, .y = 0.5, .z = 0.5 },

    .{ .x = 0.5, .y = 0.5, .z = -0.5 },
    .{ .x = 0.5, .y = -0.5, .z = -0.5 },
    .{ .x = -0.5, .y = -0.5, .z = -0.5 },
    .{ .x = -0.5, .y = 0.5, .z = -0.5 },
};

const fs = [_][2]usize{
    .{ 0, 1 },
    .{ 1, 2 },
    .{ 2, 3 },
    .{ 3, 0 },

    .{ 4, 5 },
    .{ 5, 6 },
    .{ 6, 7 },
    .{ 7, 4 },

    .{ 0, 4 },
    .{ 1, 5 },
    .{ 2, 6 },
    .{ 3, 7 },
};

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

const Vec3 = struct {
    x: f32,
    y: f32,
    z: f32,

    fn translate_z(v: Vec3, d: f32) Vec3 {
        return .{
            .x = v.x,
            .y = v.y,
            .z = v.z + d,
        };
    }

    fn rotate_xz(v: Vec3, angle: f32) Vec3 {
        const c = @cos(angle);
        const s = @sin(angle);

        return .{
            .x = v.x * c - v.z * s,
            .y = v.y,
            .z = v.x * s + v.z * c,
        };
    }

    fn project(v: Vec3) Vec3 {
        return .{
            .x = v.x / v.z,
            .y = v.y / v.z,
            .z = 1,
        };
    }

    fn screen(v: Vec3) Point {
        const x = (v.x + 1) / 2.0 * @as(f32, @floatFromInt(WIDTH));
        const y = (v.y + 1) / 2.0 * @as(f32, @floatFromInt(HEIGHT));

        return .{
            .x = @intFromFloat(@trunc(x)),
            .y = @intFromFloat(@trunc(y)),
        };
    }
};

const Point = struct {
    x: i32,
    y: i32,
};

fn draw_line(p1: Point, p2: Point) void {
    const dx: i32 = @intCast(@abs(p1.x - p2.x));
    var dy: i32 = @intCast(@abs(p1.y - p2.y));
    dy = dy * -1;

    const sx: i32 = if (p1.x < p2.x) 1 else -1;
    const sy: i32 = if (p1.y < p2.y) 1 else -1;

    var err = dx + dy;
    var x0 = p1.x;
    var y0 = p1.y;
    while (true) {
        pixel(x0, y0);
        if (x0 == p2.x and y0 == p2.y) break;

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

fn pixel(x: i32, y: i32) void {
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
