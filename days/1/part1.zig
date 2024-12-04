const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/1/input.txt");
    const lines = try shared.splitLines(allocator, buffer);

    const left = try allocator.alloc(usize, lines.items.len);
    const right = try allocator.alloc(usize, lines.items.len);

    for (lines.items, 0..) |line, i| {
        var it = std.mem.split(u8, line, "   ");
        left[i] = try std.fmt.parseInt(usize, it.next().?, 10);
        right[i] = try std.fmt.parseInt(usize, it.next().?, 10);
    }

    std.mem.sort(usize, left, {}, comptime std.sort.asc(usize));
    std.mem.sort(usize, right, {}, comptime std.sort.asc(usize));

    var total: usize = 0;
    for (left, right) |l, r| {
        total += if (l > r) l - r else r - l;
    }

    std.debug.print("Total Distance: {d}\n", .{total});
}
