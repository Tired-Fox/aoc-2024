const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![]const u8 {
    var file = try std.fs.cwd().openFile(path, .{});

    const size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, size);


    const read = try file.readAll(buffer);
    std.debug.assert(read == size);

    file.close();

    return std.mem.trim(u8, buffer, "\n");
}

pub fn splitLines(allocator: std.mem.Allocator, src: []const u8) !std.ArrayList([]const u8) {
    var lines = std.ArrayList([]const u8).init(allocator);
    var it = std.mem.split(u8, std.mem.trim(u8, src, "\r\n"), "\r\n");
    while (it.next()) |line| {
        try lines.append(std.mem.trim(u8, line, "\r\n"));
    }
    return lines;
}
