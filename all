const std = @import("std");
const stdout = std.io.getStdOut().writer();
const stdin = std.io.getStdIn().reader();

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try stdout.print("Enter anything:\n> ", .{});
    const input = try stdin.readUntilDelimiterAlloc(allocator, '\n', 1024);
    defer allocator.free(input);

    errdefer std.debug.print("YOU SUCK", .{});

    try stdout.print("You inputed:\n> {s}\n", .{input});
}
