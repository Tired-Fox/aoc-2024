const std = @import("std");
const shared = @import("shared");

const Position = struct {
    x: isize,
    y: isize,

    pub fn new(x: usize, y: usize) @This() {
        return .{ .x = @intCast(x), .y = @intCast(y) };
    }

    pub fn antinode(self: @This(), other: @This()) @This() {
        return .{ .x = self.x + (self.x - other.x), .y = self.y + (self.y - other.y) };
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
        if (entry.key_ptr.* == '#') continue;

        for (entry.value_ptr.*.items) |current| {
            for (entry.value_ptr.*.items) |pos| {
                if (current.eql(pos)) continue;
                const antinode = current.antinode(pos);
                if (antinode.inBounds(width, height)) {
                    try unique.put(antinode, {});
                }
            }
        }
    }

    std.debug.print("Total unique antinodes: {d}\n", .{unique.count()});
}
