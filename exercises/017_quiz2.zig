//
// Quiz time again! Let's see if you can solve the famous "Fizz Buzz"!
//
//     "Players take turns to count incrementally, replacing
//      any number divisible by three with the word "fizz",
//      and any number divisible by five with the word "buzz".
//          - From https://en.wikipedia.org/wiki/Fizz_buzz
//
// Let's go from 1 to 16. This has been started for you, but there
// are some problems. :-(
//
const std = @import("std");

pub fn main() void {
    var it: u8 = 1;
    const stop_at: u8 = 16;

    // What kind of loop is this? A 'for' or a 'while'?
    while (stop_at >= it) : (it += 1) {
        if (it % 3 == 0) std.debug.print("Fizz", .{});
        if (it % 5 == 0) std.debug.print("Buzz", .{});
        if (!(it % 3 == 0) and !(it % 5 == 0)) {
            std.debug.print("{}", .{it});
        }
        std.debug.print(", ", .{});
    }
    std.debug.print("\n", .{});
}
