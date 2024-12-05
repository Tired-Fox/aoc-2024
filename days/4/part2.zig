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
            // Look for an 'A' that has characters in the four corners surrounding it
            if (char == 'A' and y > 0 and y < height - 1 and x > 0 and x < width - 1) {
                // Check both diagonals to have one `S` and one `M` creating crossing MAS's
                if (
                    // Top Left to Bottom Right
                    (
                        std.mem.eql(u8, &[_]u8{lines.items[y-1][x-1], lines.items[y+1][x+1]}, "MS")
                        or
                        std.mem.eql(u8, &[_]u8{lines.items[y-1][x-1], lines.items[y+1][x+1]}, "SM")
                    )
                    and
                    // Top Right to Bottom Left
                    (
                        std.mem.eql(u8, &[_]u8{lines.items[y-1][x+1], lines.items[y+1][x-1]}, "MS")
                        or
                        std.mem.eql(u8, &[_]u8{lines.items[y-1][x+1], lines.items[y+1][x-1]}, "SM")
                    )
                ) count += 1;
            }
        }
    }

    std.debug.print("Total # of 'XMAS': {d}", .{count});
}
