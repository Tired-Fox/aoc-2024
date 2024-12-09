const std = @import("std");
const shared = @import("shared");

// This is wrong and doesn't get the correct solution. Was just playing around with some ideas

const Dir = struct { isize, isize, u8 };
const Direction = union(enum) {
    const Self = @This();

    down: Dir,
    left: Dir,
    up: Dir,
    right: Dir,

    pub fn l() @This() {
        return .{ .left = .{ -1, 0, '-' } };
    }
    pub fn r() @This() {
        return .{ .right = .{ 1, 0, '-' } };
    }
    pub fn u() @This() {
        return .{ .up = .{ 0, -1, '|' } };
    }
    pub fn d() @This() {
        return .{ .down = .{ 0, 1, '|' } };
    }

    pub fn turn(self: @This()) @This() {
        return switch (self) {
            .down => @This().l(),
            .up => @This().r(),
            .left => @This().u(),
            .right => @This().d(),
        };
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
    pub fn char(self: @This()) u8 {
        switch (self) {
            .down => |pair| return pair[2],
            .up => |pair| return pair[2],
            .left => |pair| return pair[2],
            .right => |pair| return pair[2],
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try shared.readFile(allocator, "days/6/input2.txt");
    const grid = try shared.splitLines(allocator, buffer);

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
        var nx: isize = direction.x() + @as(isize, @intCast(x));
        var ny: isize = direction.y() + @as(isize, @intCast(y));
        if (nx < 0 or ny < 0 or nx >= width or ny >= height) break;

        if (grid.items[@intCast(ny)][@intCast(nx)] == '#') {
            direction = direction.turn();
            nx = direction.x() + @as(isize, @intCast(x));
            ny = direction.y() + @as(isize, @intCast(y));

            // check position to the right
            x = @intCast(nx);
            y = @intCast(ny);
            continue;
        }

        const cw = direction.turn();
        const cx: isize = cw.x() + nx;
        const cy: isize = cw.y() + ny;
        if (cx > 0 and cy > 0 and cx < width and cy < height) {
            if (try drawLoop(allocator, grid.items, nx, ny, width, height, cw)) {
                std.debug.print("({d}, {d}) for ({d} {d})\n", .{nx + direction.x(), ny + direction.y(), x, y});
                count += 1;
            }
        }

        // check position to the right
        x = @intCast(nx);
        y = @intCast(ny);
    }

    std.debug.print("Total distinct obstruction positions: {d}", .{ count });
}

fn drawLoop(allocator: std.mem.Allocator, grid: [][]u8, x: isize, y: isize, width: isize, height: isize, direction: Direction) !bool {
    var checked_turn = std.AutoHashMap(struct{ isize, isize, Direction }, void).init(allocator);
    defer checked_turn.deinit();

    var i: isize, var j: isize = .{ x, y };
    var dir = direction;
    while (true) {
        i += dir.x();
        j += dir.y();

        if (i < 0 or i >= width or j < 0 or j >= height) return false;
        if (i == x and j == y) return true;
        if (grid[@intCast(j)][@intCast(i)] == '#') {
            if (checked_turn.get(.{i, j, dir})) |_| return false; 
            try checked_turn.put(.{ i, j, dir }, {});

            i += dir.x() * -1;
            j += dir.y() * -1;
            dir = dir.turn();
        }
    }
}
