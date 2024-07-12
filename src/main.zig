const std = @import("std");

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Welcome to the Monkey programming language!\n", .{});
}
