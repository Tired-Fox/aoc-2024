const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/9/input.txt");
    var disk_map = std.ArrayList(usize).init(allocator);

    var id: usize = 0;
    for (buffer, 0..) |item, i| {
        const count = try std.fmt.parseInt(u8, &[_]u8{item}, 10);
        if (i % 2 == 1) {
            id += 1;
            for (0..count) |_| {
                try disk_map.append('.');
            }
        } else {
            for (0..count) |_| {
                try disk_map.append(id);
            }
        }
    }

    var checksum: usize = 0;
    var left: usize = 0;
    var right: usize = disk_map.items.len - 1;
    while (left <= right) {
        if (disk_map.items[left] == '.') {
            while (left <= right and disk_map.items[right] == '.') {
                right -= 1;
            }
            disk_map.items[left] = disk_map.items[right];
            disk_map.items[right] = '.';
            right -= 1;
        }

        checksum = checksum + (left * disk_map.items[left]);

        left += 1;
    }

    std.debug.print("Checksum: {d}\n", .{checksum});
}
