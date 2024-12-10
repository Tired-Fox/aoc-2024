const std = @import("std");

const days = .{
    .{ "1-1", "days/1/part1.zig" },
    .{ "1-2", "days/1/part2.zig" },
    .{ "2-1", "days/2/part1.zig" },
    .{ "2-2", "days/2/part2.zig" },
    .{ "3-1", "days/3/part1.zig" },
    .{ "3-2", "days/3/part2.zig" },
    .{ "4-1", "days/4/part1.zig" },
    .{ "4-2", "days/4/part2.zig" },
    .{ "5-1", "days/5/part1.zig" },
    .{ "5-2", "days/5/part2.zig" },
    .{ "6-1", "days/6/part1.zig" },
    .{ "6-2", "days/6/part2.zig" },
    .{ "7-1", "days/7/part1.zig" },
    .{ "7-2", "days/7/part2.zig" },
    .{ "8-1", "days/8/part1.zig" },
    .{ "8-2", "days/8/part2.zig" },
    .{ "9-1", "days/9/part1.zig" },
    .{ "9-2", "days/9/part2.zig" },
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const shared = b.addModule("shared", .{ .root_source_file = b.path("src/root.zig") });

    const day_step = b.step("day", "Run an AOC day");

    inline for (days) |day| {
        buildExample(b, day[0], day[1], .{
            .module = .{ "shared", shared },
            .dependsOn = day_step,
            .target = target,
            .optimize = optimize,
        });
    }
}

const Build = struct {
    module: struct { []const u8, *std.Build.Module },
    dependsOn: *std.Build.Step,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
};

fn buildExample(b: *std.Build, comptime name: []const u8, comptime root: []const u8, settings: Build) void {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = b.path(root),
        .target = settings.target,
        .optimize = settings.optimize,
    });

    exe.root_module.addImport(settings.module[0], settings.module[1]);

    const day_cmd = b.addRunArtifact(exe);
    day_cmd.step.dependOn(b.getInstallStep());

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        day_cmd.addArgs(args);
    }

    const day_step = b.step(name, "Run day " ++ name);
    day_step.dependOn(&day_cmd.step);

    exe.step.dependOn(settings.dependsOn);
}
