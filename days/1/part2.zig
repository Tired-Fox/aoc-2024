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

    var occurances = std.AutoHashMap(usize, usize).init(allocator);
    var total: usize = 0;
    for (left, right) |l, r| {
        total += if (l > r) l - r else r - l;

        const entry = try occurances.getOrPut(r);
        if (entry.found_existing) {
            entry.value_ptr.* += 1;
        } else {
            entry.value_ptr.* = 1;
        }
    }

    var sim_score: usize = 0;
    for (left) |l| {
        if (occurances.get(l)) |o| {
            sim_score += l * o; 
        }
    }

    std.debug.print("Total Distance: {d}\n", .{total});
    std.debug.print("Total Similarity Score: {d}\n", .{sim_score});
}
