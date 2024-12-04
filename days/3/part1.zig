const std = @import("std");
const shared = @import("shared");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/3/input.txt");
    
    var pos: usize = 0;
    var total: usize = 0;

    while (pos < buffer.len) {
        if (pos + 3 < buffer.len and std.mem.eql(u8, buffer[pos..pos+4], "mul(")) {
            pos += 4;

            var start = pos;
            while (std.ascii.isDigit(buffer[pos])): (pos += 1) {}
            const first = if (pos > start) try std.fmt.parseInt(usize, buffer[start..pos], 10) else continue;

            if (buffer[pos] == ',') pos += 1 else continue;

            start = pos;
            while (std.ascii.isDigit(buffer[pos])): (pos += 1) {}
            const second = if (pos > start) try std.fmt.parseInt(usize, buffer[start..pos], 10) else continue;

            if (buffer[pos] == ')') pos += 1 else continue;

            total += first * second;
        } else {
            pos += 1;
        }
    }

    std.debug.print("Total: {d}", .{total});
}
