const std = @import("std");
const builtin = @import("builtin");

const min_zig_version = "0.12.0";

const Build = blk: {
    const current_zig = builtin.zig_version;
    const min_zig = std.SemanticVersion.parse(min_zig_version) catch unreachable;
    if (current_zig.order(min_zig) == .lt) {
        @compileError(std.fmt.comptimePrint("Your Zig version {} does not meet the minimum build requirement of {}", .{ current_zig, min_zig }));
    }
    break :blk std.Build;
};

pub fn build(b: *Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "monkey_lang",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const monkey_lang = b.addModule("monkey_lang", .{
        .root_source_file = b.path("src/monkey_lang.zig"),
    });

    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("test/tests.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe_unit_tests.root_module.addImport("monkey_lang", monkey_lang);

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
