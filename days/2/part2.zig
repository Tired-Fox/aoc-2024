const std = @import("std");
const shared = @import("shared");

pub fn increasing(nums: []u8) bool {
    var previous: u8 = nums[0];
    var freebee: bool = false;

    for (nums[1..]) |n| {
        if (n < previous or n - previous > 3 or n - previous < 1) {
            if (freebee) {
                return false;
            } else {
                freebee = true;
            }
        }
        previous = n;
    }

    return true;
}

pub fn decreasing(nums: []u8) bool {
    var previous: u8 = nums[0];
    var freebee: bool = false;

    for (nums[1..]) |n| {
        if (n == previous or n > previous or previous - n > 3 or previous - n < 1) {
            if (freebee) {
                return false;
            } else {
                freebee = true;
            }
        }
        previous = n;
    }

    return true;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/2/input.txt");
    const lines = try shared.splitLines(allocator, buffer);

    var safe: usize = 0;
    for (lines.items) |line| {
        var nums = std.ArrayList(u8).init(allocator);
        defer nums.deinit();

        var it = std.mem.split(u8, line, " ");
        while (it.next()) |num| {
            try nums.append(try std.fmt.parseInt(u8, num, 10));
        }

        const valid = if (nums.items[0] > nums.items[1])
            decreasing(nums.items[0..nums.items.len])
        else
            increasing(nums.items[0..nums.items.len]);

        if (valid) {
            safe += 1;
        }
    }

    std.debug.print("Safe reports: {d}\n", .{safe});
}
