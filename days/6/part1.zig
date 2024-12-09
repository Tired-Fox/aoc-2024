const std = @import("std");
const shared = @import("shared");


const Pair = struct { isize, isize };
const Direction = union(enum) {
    const Self = @This();

    down: Pair,
    left: Pair,
    up: Pair,
    right: Pair,

    pub fn l() @This() {
        return .{ .left = .{ -1, 0 } };
    }
    pub fn r() @This() {
        return .{ .right = .{ 1, 0 } };
    }
    pub fn u() @This() {
        return .{ .up = .{ 0, -1 } };
    }
    pub fn d() @This() {
        return .{ .down = .{ 0, 1 } };
    }
    pub fn x(self: @This()) isize {
        switch (self) {
            .down => |pair| return pair[0],
            .up => |pair| return pair[0],
            .left => |pair| return pair[0],
            .right => |pair| return pair[0],
        }
    }
    pub fn y(self: @This()) isize {
        switch (self) {
            .down => |pair| return pair[1],
            .up => |pair| return pair[1],
            .left => |pair| return pair[1],
            .right => |pair| return pair[1],
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/6/input.txt");
    var grid = try shared.splitLines(allocator, buffer);

    const height: isize = @intCast(grid.items.len);
    const width: isize =  @intCast(grid.items[0].len);

    // Find starting position and direction
    var x: usize, var y: usize = .{ 0, 0 };
    var direction: Direction = undefined;

    for (grid.items, 0..) |row, i| {
        for (row, 0..) |col, j| {
            if (col == '<') {
                y = i;
                x = j; 
                direction = Direction.l();
            }
            else if (col == '^') {
                y = i;
                x = j; 
                direction = Direction.u();
            }
            else if (col == '>') {
                y = i;
                x = j; 
                direction = Direction.r();
            }
            else if (col == 'v') {
                y = i;
                x = j; 
                direction = Direction.d();
            }
        }
    }

    // traverse the grid. replacing visited spots with x and totaling the unique spaces
    var count: usize = 0;
    while (true) {
        if (grid.items[y][x] != 'x') {
            count += 1;
            grid.items[y][x] = 'x';
        }

        const nx: isize = direction.x() + @as(isize, @intCast(x));
        const ny: isize = direction.y() + @as(isize, @intCast(y));
        if (nx < 0 or ny < 0 or nx >= width or ny >= height) break;

        if (grid.items[@intCast(ny)][@intCast(nx)] == '#') {
            switch (direction) {
                .down => direction = Direction.l(),
                .left => direction = Direction.u(),
                .up => direction = Direction.r(),
                .right => direction = Direction.d(),
            }
        } else {
            x = @intCast(nx);
            y = @intCast(ny);
        }
    }

    std.debug.print("Total distinct positions: {d}", .{ count });
}
