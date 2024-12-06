const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/5/input.txt");
    var parts = std.mem.split(u8, buffer, "\r\n\r\n");
    const rules = try shared.splitLines(allocator, parts.next().?);
    const updates = try shared.splitLines(allocator, parts.next().?);

    var rule_map = std.AutoHashMap(u8, std.ArrayList(u8)).init(allocator);
    for (rules.items) |rule| {
        var it = std.mem.split(u8, rule, "|");
        const before = try std.fmt.parseInt(u8, it.next().?, 10);
        const after = try std.fmt.parseInt(u8, it.next().?, 10);


        var entry = try rule_map.getOrPut(before);
        if (entry.found_existing) {
            try entry.value_ptr.append(after);
        }
        else {
            entry.value_ptr.* = std.ArrayList(u8).init(allocator);
            try entry.value_ptr.append(after);
        }
    }

    var total: usize = 0;
    for (updates.items) |update| {
        var it = std.mem.split(u8, update, ",");
        var nums = std.ArrayList(u8).init(allocator);
        defer nums.deinit();
        while (it.next()) |next| {
            try nums.append(try std.fmt.parseInt(u8, next, 10));
        }

        for (0..nums.items.len) |i| {
            const current = nums.items[i];
            if (i == 0) continue;
            if (rule_map.get(current)) |before| {
                if (!none_included(nums.items[0..i], before.items)) break;
            }
        } else {
            total += nums.items[@divFloor(nums.items.len-2, 2) + 1];
        }
    }

    std.debug.print("Middle update total: {d}", .{total});
}

fn none_included(value: []const u8, haystack: []const u8) bool {
    for (value) |v| {
        for (haystack) |h| {
            if (h == v) return false;
        }
    }
    return true;
}
