const print = @import("std").debug.print;

pub fn main() void {
    // The approximate weight of the Space Shuttle upon liftoff
    // (including boosters and fuel tank) was 4,480,000 lb.
    //
    // We'll convert this weight from pounds to metric units at a
    // conversion of 0.453592 kg to the pound.
    const shuttle_weight: f64 = 0.453592 * 4480e3;

    // By default, float values are formatted in standard decimal
    // notation. Experiment with '{d}' and '{d:.3}' to see how
    // decimal formatting works, or try '{e}' and '{e:.3}' for
    // scientific notation.
    // NOTE: The weight of the shuttle is a huge number, a scientific notation
    // may be more appropriate.
    print("Shuttle liftoff weight: {e:.3} metric tons\n", .{shuttle_weight / 1e3});
}