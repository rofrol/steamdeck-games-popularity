const std = @import("std");
const csv = @import("csv");
//
// pub fn main() !void {
//     const allocator = std.heap.page_allocator;
//
//     const size_limit = std.math.maxInt(u32); // or any other suitable limit
//     const file_path = "steamdeck-games-popularity.csv";
//     const file = try std.fs.cwd().openFile(file_path, .{ .mode = .read_only });
//     defer file.close();
//     const csvFile = try file.readToEndAlloc(allocator, size_limit);
//
// const csv = @import("csv");

pub fn main() anyerror!void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const buffer = try allocator.alloc(u8, 4096);

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len != 2) {
        std.log.warn("Single arg is expected", .{});
        std.process.exit(1);
    }

    const file = try std.fs.cwd().openFile(args[1], .{});
    defer file.close();

    var csv_tokenizer = &try csv.CsvTokenizer(std.fs.File.Reader).init(file.reader(), buffer, .{});
    const stdout = std.io.getStdOut().writer();

    while (try csv_tokenizer.next()) |token| {
        switch (token) {
            .field => |val| {
                try stdout.writeAll(val);
                try stdout.writeAll("\t");
            },
            .row_end => {
                try stdout.writeAll("\n");
            },
        }
    }
}
