const std = @import("std");
const shared = @import("shared");

const Position = struct {
    x: isize,
    y: isize,

    pub fn new(x: usize, y: usize) @This() {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn antinode(self: @This(), other: @This()) @This() {
        return self.move(self.direction(other));
    }

    pub fn move(self: @This(), dir: struct { isize, isize }) @This() {
        return .{ .x = self.x + dir[0], .y = self.y + dir[1] };
    }

    pub fn direction(self: @This(), other: @This()) struct { isize, isize } {
        return .{ (self.x - other.x), (self.y - other.y) };
    }

    pub fn inBounds(self: @This(), width: usize, height: usize) bool {
        return self.x >= 0 and self.x < @as(isize, @intCast(width)) and self.y >= 0 and self.y < @as(isize, @intCast(height));
    }

    pub fn eql(self: @This(), other: @This()) bool {
        return self.x == other.x and self.y == other.y;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/8/input.txt");
    const lines = try shared.splitLines(allocator, buffer);

    const width = lines.items[0].len;
    const height = lines.items.len;

    var signals = std.AutoHashMap(u8, std.ArrayList(Position)).init(allocator);
    var unique = std.AutoHashMap(Position, void).init(allocator);

    for (lines.items, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char != '.') {
                const entry = try signals.getOrPut(char);
                if (entry.found_existing) {
                    try entry.value_ptr.append(Position.new(x, y));
                } else {
                    var list = std.ArrayList(Position).init(allocator);
                    try list.append(Position.new(x, y));
                    entry.value_ptr.* = list;
                }
            }
        }
    }

    var sit = signals.iterator();
    while (sit.next()) |entry| {
        for (entry.value_ptr.*.items) |current| {
            for (entry.value_ptr.*.items) |pos| {
                if (current.eql(pos)) continue;

                if (!unique.contains(current)) {
                    try unique.put(current, {});
                }
                if (!unique.contains(pos)) {
                    try unique.put(pos, {});
                }

                const dir = current.direction(pos);
                var antinode = current.move(dir);

                while (antinode.inBounds(width, height)) {
                    if (!unique.contains(antinode)) {
                        try unique.put(antinode, {});
                    }

                    antinode = antinode.move(dir);
                }
            }
        }
    }

    std.debug.print("Total unique antinodes: {d}\n", .{unique.count()});
}
