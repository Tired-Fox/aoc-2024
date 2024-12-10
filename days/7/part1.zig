const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/7/input.txt");
    const lines = try shared.splitLines(allocator, buffer);
    var count: usize = 0;

    var productCache = std.AutoHashMap(usize, std.ArrayList(std.ArrayList([]const u8))).init(allocator);

    for (lines.items) |line| {
        var parts = std.mem.split(u8, line, ":");
        const total = try std.fmt.parseInt(usize, parts.next().?, 10);

        var nit = std.mem.split(u8, std.mem.trim(u8, parts.next().?, " "), " ");
        var nums = std.ArrayList(usize).init(allocator);
        while (nit.next()) |num| {
            try nums.append(try std.fmt.parseInt(usize, num, 10));
        }

        const entry = try productCache.getOrPut(nums.items.len);
        if (!entry.found_existing) {
            const seq = try createSequence(allocator, []const u8, nums.items.len, .{ "*", "+" });
            defer {
                for (seq.items) |set| {
                    set.deinit();
                }
                seq.deinit();
            }

            const product = try cartesian([]const u8, allocator, seq);
            entry.value_ptr.* = product;
        }

        for (entry.value_ptr.*.items) |set| {
            var product: usize = nums.items[0];
            for (nums.items[1..], 0..) |num, i| {
                const op = set.items[i];
                if (std.mem.eql(u8, op, "*")) {
                    product *= num;
                } else if (std.mem.eql(u8, op, "+")) {
                    product += num;
                }
            }
            if (product == total) {
                count += total;
                break;
            }
        }
    }

    std.debug.print("Total calibration result: {d}", .{count});
}

fn createSequence(
    allocator: std.mem.Allocator,
    T: type,
    size: usize,
    init: anytype,
) !std.ArrayList(std.ArrayList(T)) {
    var seq = try std.ArrayList(std.ArrayList(T)).initCapacity(allocator, size);
    for (0..size) |_| {
        var new = try std.ArrayList(T).initCapacity(allocator, init.len);
        inline for (init) |item| {
            try new.append(item);
        }
        try seq.append(new);
    }
    return seq;
}

fn cartesian(
    T: type,
    allocator: std.mem.Allocator,
    sets: std.ArrayList(std.ArrayList(T)),
) !std.ArrayList(std.ArrayList(T)) {
    if (sets.items.len == 0) return error.Empty;

    var result = std.ArrayList(std.ArrayList(T)).init(allocator);
    for (sets.items[0].items) |item| {
        var new = std.ArrayList(T).init(allocator);
        try new.append(item);
        try result.append(new);
    }

    for (sets.items[1..]) |set| {
        result = try cartesianProduct(T, allocator, result, set);
    }

    return result;
}

fn cartesianProduct(
    T: type,
    allocator: std.mem.Allocator,
    sets: std.ArrayList(std.ArrayList(T)),
    seq: std.ArrayList(T),
) !std.ArrayList(std.ArrayList(T)) {
    var result = std.ArrayList(std.ArrayList(T)).init(allocator);
    for (sets.items) |set| {
        for (seq.items) |item| {
            var new = std.ArrayList(T).init(allocator);
            const slice = try new.addManyAsSlice(set.items.len);
            @memcpy(slice, set.items);
            try new.append(item);
            try result.append(new);
        }
        set.deinit();
    }
    sets.deinit();
    return result;
}
