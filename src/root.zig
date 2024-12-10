const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});

    const size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, size);

    const read = try file.readAll(buffer);
    std.debug.assert(read == size);

    file.close();

    return std.mem.trim(u8, std.mem.trim(u8, buffer, "\n"), "\r");
}

pub fn splitLines(allocator: std.mem.Allocator, src: []const u8) !std.ArrayList([]u8) {
    var lines = std.ArrayList([]u8).init(allocator);
    var it = std.mem.split(u8, std.mem.trim(u8, src, "\n"), "\n");
    while (it.next()) |line| {
        const trimmed = std.mem.trim(u8, line, "\r");
        const buff: []u8 = try allocator.alloc(u8, trimmed.len);
        @memcpy(buff, trimmed);
        try lines.append(buff);
    }
    return lines;
}
