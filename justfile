template := 'const std = @import(\"std\");
pub fn main() void {
    std.debug.print(\"Hello, world!\", .{});
}'

# Build and run a specific AOC day
day DAY:
    zig build day {{DAY}}

# Creates the files for a specific day.
# Currently, the build.zig still needs to be updated with the new files.
create DAY:
    mkdir days/{{DAY}}
    @echo "{{template}}" >> days/{{DAY}}/part1.zig
    @echo "{{template}}" >> days/{{DAY}}/part2.zig
