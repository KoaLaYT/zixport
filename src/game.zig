const std = @import("std");

const WIDTH: u32 = 800;
const HEIGHT: u32 = 600;

var framebuffer: [WIDTH * HEIGHT * 4]u8 = undefined;

const Game = extern struct {
    display: [*]u8,
    display_width: u32,
    display_height: u32,
};

const Rect = struct {
    x: i32,
    y: i32,
    w: i32,
    h: i32,
    vx: i32,
    vy: i32,
    r: u8,
    g: u8,
    b: u8,
};

var rects = [_]Rect{
    .{ .x = 200, .y = 150, .w = 120, .h = 120, .vx = 3, .vy = 2, .r = 0xF3, .g = 0x8B, .b = 0xA8 },
    .{ .x = 350, .y = 250, .w = 100, .h = 100, .vx = -2, .vy = 3, .r = 0xA6, .g = 0xE3, .b = 0xA1 },
    .{ .x = 400, .y = 180, .w = 80, .h = 140, .vx = 4, .vy = -2, .r = 0x89, .g = 0xB4, .b = 0xFA },
};

export fn game_init() Game {
    clear(0x1E, 0x1E, 0x2E);
    drawScene();
    return .{
        .display = &framebuffer,
        .display_width = WIDTH,
        .display_height = HEIGHT,
    };
}

var running: bool = true;

export fn game_update() bool {
    if (!running) return false;
    for (&rects) |*rect| {
        rect.x += rect.vx;
        rect.y += rect.vy;

        if (rect.x <= 0) {
            rect.x = 0;
            rect.vx = -rect.vx;
        } else if (rect.x + rect.w >= @as(i32, WIDTH)) {
            rect.x = @as(i32, WIDTH) - rect.w;
            rect.vx = -rect.vx;
        }

        if (rect.y <= 0) {
            rect.y = 0;
            rect.vy = -rect.vy;
        } else if (rect.y + rect.h >= @as(i32, HEIGHT)) {
            rect.y = @as(i32, HEIGHT) - rect.h;
            rect.vy = -rect.vy;
        }
    }

    clear(0x1E, 0x1E, 0x2E);
    drawScene();
    return true;
}

export fn game_key_down(keycode: u16) void {
    const dx: i32 = switch (keycode) {
        0x7B => -20,
        0x7C => 20,
        else => 0,
    };
    const dy: i32 = switch (keycode) {
        0x7E => -20,
        0x7D => 20,
        else => 0,
    };
    for (&rects) |*rect| {
        rect.x += dx;
        rect.y += dy;
    }
}

export fn game_key_up(keycode: u16) void {
    if (keycode == 0x0C) { // 'q' key
        running = false;
    }
}

fn clear(r: u8, g: u8, b: u8) void {
    var i: usize = 0;
    while (i < WIDTH * HEIGHT) : (i += 1) {
        const base = i * 4;
        framebuffer[base + 0] = b;
        framebuffer[base + 1] = g;
        framebuffer[base + 2] = r;
        framebuffer[base + 3] = 0xFF;
    }
}

fn drawScene() void {
    for (rects) |rect| {
        drawRect(rect.x, rect.y, rect.w, rect.h, rect.r, rect.g, rect.b);
    }
}

fn drawRect(x0: i32, y0: i32, w: i32, h: i32, r: u8, g: u8, b: u8) void {
    var y = y0;
    while (y < y0 + h) : (y += 1) {
        var x = x0;
        while (x < x0 + w) : (x += 1) {
            putPixel(x, y, r, g, b);
        }
    }
}

fn putPixel(x: i32, y: i32, r: u8, g: u8, b: u8) void {
    if (x < 0 or y < 0 or x >= WIDTH or y >= HEIGHT) return;
    const ux: usize = @intCast(x);
    const uy: usize = @intCast(y);
    const idx = (uy * WIDTH + ux) * 4;
    framebuffer[idx + 0] = b;
    framebuffer[idx + 1] = g;
    framebuffer[idx + 2] = r;
    framebuffer[idx + 3] = 0xFF;
}
