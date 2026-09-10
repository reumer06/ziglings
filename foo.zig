const std = @import("std");
const print = std.debug.print;

const SensorType = enum { thermometer, hygrometer, aneomometer };

const Reading = struct {
    sensor_type: SensorType,
    value: i32,
};

const GardenWeather = struct {
    temperature: i32 = 0,
    humidity: i32 = 0,
    wind: i32 = 0,
    reading_count: u32 = 0,
    mutex: std.Io.Mutex = .init,

    fn addReading(self: *GardenWeather, io: std.Io, reading: Reading) void {
        self.mutex.lock(io) catch return;
        defer self.mutex.unlock(io);

        switch (reading.sensor_type) {
            .thermometer => self.temperature = reading.value,
            .hygrometer => self.humidity = reading.value,
            .aneomometer => self.wind = reading.value,
        }

        self.reading_count += 1;
    }
};

fn sensor(io: std.Io, queue: *std.Io.Queue(Reading), sensor_type: SensorType, base_value: i32) void {
    for (1..4) |i| {
        io.sleep(std.Io.Duration.fromMilliseconds(100), .awake) catch return;

        const reading = Reading{ .sensor_type = sensor_type, .value = base_value + @as(i32, @intCast(i)) };

        queue.putOne(io, reading) catch return;
    }
}

fn collector(io: std.Io, queue: *std.Io.Queue(Reading), weather: *GardenWeather) void {
    while (true) {
        const reading = queue.getOne(io) catch |err| switch (err) {
            error.Closed => break,
            error.Canceled => return,
        };

        weather.addReading(io, reading);
    }
}

fn printGardenReport(weather: *GardenWeather) void {
    print("=== Doctor Zoraptera's Garden Report ===\n", .{});
    print("Temperature : {}C\n", .{weather.temperature});
    print("Humidity    : {}%\n", .{weather.humidity});
    print("Wind        : {} km/h\n", .{weather.wind});
    print("Readings    : {}\n", .{weather.reading_count});

    if (weather.temperature > 20 and weather.wind < 15) {
        print("Bee-friendly conditions! Expect high pollination.\n", .{});
    } else {
        print("Grasshoppers will be grumpy today.\n", .{});
    }
}

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    var weather = GardenWeather{};

    var reading_buf: [8]Reading = undefined;
    var queue: std.Io.Queue(Reading) = .init(&reading_buf);

    var collector_future = try io.concurrent(collector, .{ io, &queue, &weather });
    defer _ = collector_future.cancel(io);

    var sensors: std.Io.Group = .init;

    sensors.async(io, sensor, .{ io, &queue, .thermometer, 20 });
    sensors.async(io, sensor, .{ io, &queue, .hygrometer, 80 });
    sensors.async(io, sensor, .{ io, &queue, .aneomometer, 23 });

    try sensors.await(io);

    queue.close(io);

    _ = collector_future.await(io);

    const old_protection = io.swapCancelProtection(.blocked);
    defer _ = io.swapCancelProtection(old_protection);

    printGardenReport(&weather);
}
