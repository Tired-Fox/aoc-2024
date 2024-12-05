const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // Make a huge assumpting that each line is equal in size
    // this is only possible because of the pre defined input.

    const buffer = try shared.readFile(allocator, "days/4/input.txt");
    const lines = try shared.splitLines(allocator, buffer);

    const width = lines.items[0].len;
    const height = lines.items.len;

    var count: usize = 0;
    for (lines.items, 0..) |line, y| {
        for (line, 0..) |char, x| {
            if (char == 'X') {
                // Search in 8 directions for match

                // Left
                if (x > 2 and std.mem.eql(u8, line[x-3..x], "SAM")) {
                    count += 1;
                }
                // Left Up 
                if (x > 2 and y > 2 and std.mem.eql(u8, &[_]u8{lines.items[y-1][x-1], lines.items[y-2][x-2], lines.items[y-3][x-3]}, "MAS")) {
                    count += 1;
                }
                // Up
                if (y > 2 and std.mem.eql(u8, &[_]u8{lines.items[y-3][x], lines.items[y-2][x], lines.items[y-1][x]}, "SAM")) {
                    count += 1;
                }
                // Up Right
                if (x < width - 3 and y > 2 and std.mem.eql(u8, &[_]u8{lines.items[y-1][x+1], lines.items[y-2][x+2], lines.items[y-3][x+3]}, "MAS")) {
                    count += 1;
                }
                // Right
                if (x < width - 3 and std.mem.eql(u8, line[x+1..x+4], "MAS")) {
                    count += 1;
                }
                // Right Down
                if (x < width - 3 and y < height - 3 and std.mem.eql(u8, &[_]u8{lines.items[y+1][x+1], lines.items[y+2][x+2], lines.items[y+3][x+3]}, "MAS")) {
                    count += 1;
                }
                // Down
                if (y < height - 3 and std.mem.eql(u8, &[_]u8{lines.items[y+1][x], lines.items[y+2][x], lines.items[y+3][x]}, "MAS")) {
                    count += 1;
                }
                // Down Left
                if (x > 2 and y < height - 3 and std.mem.eql(u8, &[_]u8{lines.items[y+1][x-1], lines.items[y+2][x-2], lines.items[y+3][x-3]}, "MAS")) {
                    count += 1;
                }
            }
        }
    }

    std.debug.print("Total # of 'XMAS': {d}", .{count});
}
