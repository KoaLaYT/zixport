x: f32,
y: f32,
z: f32,

const Vec3 = @This();

pub fn translate_z(v: Vec3, d: f32) Vec3 {
    return .{
        .x = v.x,
        .y = v.y,
        .z = v.z + d,
    };
}

pub fn rotate_xz(v: Vec3, angle: f32) Vec3 {
    const c = @cos(angle);
    const s = @sin(angle);

    return .{
        .x = v.x * c - v.z * s,
        .y = v.y,
        .z = v.x * s + v.z * c,
    };
}

pub fn project(v: Vec3) Vec3 {
    return .{
        .x = v.x / v.z,
        .y = v.y / v.z,
        .z = 1,
    };
}

pub fn screen(v: Vec3, width: u32, height: u32) struct { i64, i64 } {
    const x = (v.x + 1) / 2.0 * @as(f32, @floatFromInt(width));
    const y = (v.y + 1) / 2.0 * @as(f32, @floatFromInt(height));

    return .{
        @intFromFloat(@trunc(x)),
        @intFromFloat(@trunc(y)),
    };
}
