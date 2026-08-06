const std = @import("std");

// const Type = enum { water, fire, land, magic };

const Element = union(enum) {
    water: u32,
    fire: u8,
    land: bool,
    magic: void,
};
pub fn main() void {
    const flood = Element{ .water = 500 };
    const inferno = Element{ .fire = 120 };
    const mountain = Element{ .land = true };
    const magic = Element{ .magic = {} };

    printElement(flood);
    printElement(inferno);
    printElement(mountain);
    printElement(magic);
}

fn printElement(element: Element) void {
    switch (element) {
        .water => |liters| std.debug.print("There are {} liters of water.\n", .{liters}),
        .fire => |ash| std.debug.print("The rate of fire is {}.\n", .{ash}),
        .land => |amount| std.debug.print("The amount of land is {}.\n", .{amount}),
        .magic => {
            std.debug.print("Value of magic is pure energy!\n", .{});
        },
    }
}
