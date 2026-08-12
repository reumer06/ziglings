const print = @import("std").debug.print;

const Ingredient = enum {
    chili,
    macaroni,
    tomato_sauce,
    cheese,
};

const Food = struct {
    name: []const u8,
    requires: []const Ingredient,
};

const menu = [_]Food{
    .{
        .name = "Mac & Cheese",
        .requires = &.{ .macaroni, .cheese },
    },
    .{
        .name = "Chili Mac",
        .requires = &.{ .chili, .macaroni },
    },
    .{
        .name = "Pasta",
        .requires = &.{ .macaroni, .tomato_sauce },
    },
    .{
        .name = "Cheesy Chili",
        .requires = &.{ .chili, .cheese },
    },
};
pub fn main() void {
    const wanted_ingredients = [_]Ingredient{ .chili, .cheese };

    const meal = food_loop: for (menu) |food| {
        for (food.requires) |req| {
            for (wanted_ingredients) |want| {
                if (req == want) break;
            } else {
                continue :food_loop;
            }
        }
        break :food_loop food;
    } else menu[0];

    print("Enjoy your {s}!\n", .{meal.name});
}
