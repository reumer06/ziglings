const std = @import("std");

// ============================================================================
// 1. ENUM (with explicit backing integer type u8)
// Giving the enum an explicit integer type guarantees its byte size, 
// which is essential for packed structs and C interoperability.
// ============================================================================
pub const Agent = enum(u8) {
    jett = 0,
    reyna = 1,
    gecko = 2,
};

// ============================================================================
// 2. REGULAR STRUCT
// A standard Zig struct. The compiler can reorder fields for optimal memory alignment.
// ============================================================================
pub const AgentStats = struct {
    hp: u16,
    shield: u16,
};

// ============================================================================
// 3. EXTERN STRUCT (C-ABI Compatible)
// Memory layout strictly follows C language alignment rules.
// Use this when communicating with C libraries or OS APIs.
// ============================================================================
pub const ExternAgentHeader = extern struct {
    magic_byte: u8 = 0xAA,
    agent_type: Agent,
};

// ============================================================================
// 4. PACKED STRUCT (Packet / Binary Wire Layout)
// Guarantees exact bit placement without compiler padding. 
// Perfect for network packets, binary file formats, or hardware protocols.
// ============================================================================
pub const Packet = packed struct {
    packet_id: u16, // 2 bytes
    agent: Agent, // 1 byte (u8)
    is_alive: bool, // 1 byte (or bit-field depending on pack configuration)
};

// ============================================================================
// 5. TAGGED UNION (union(enum))
// A union where memory is shared across all fields, but tagged by the Agent enum.
// The tag tracks which field is currently active safely at runtime.
// ============================================================================
pub const AgentPayload = union(Agent) {
    jett: struct { dash_cooldown: f32 },
    reyna: struct { soul_orbs: u8 },
    gecko: AgentStats, // Uses our regular struct inside
};

// ============================================================================
// MAIN FUNCTION & USAGE
// ============================================================================
pub fn main() void {
    // Basic Enum Usage
    const current_agent = Agent.jett;
    print(current_agent);
    print(Agent.gecko);

    std.debug.print("\n--- Structural & Packet Usage ---\n", .{});

    // Creating a Network Packet (packed struct)
    const pkt = Packet{
        .packet_id = 1001,
        .agent = Agent.reyna,
        .is_alive = true,
    };
    std.debug.print("Packed Packet Size: {d} bytes\n", .{@sizeOf(Packet)});
    print(pkt.agent);

    // Creating an Extern Struct (C-ABI layout)
    const extern_hdr = ExternAgentHeader{
        .agent_type = Agent.jett,
    };
    std.debug.print("Extern Header Magic: 0x{X}\n", .{extern_hdr.magic_byte});

    // Tagged Union Usage (Pattern Matching via Switch)
    const jett_payload = AgentPayload{ .jett = .{ .dash_cooldown = 12.5 } };
    const gecko_payload = AgentPayload{ .gecko = .{ .hp = 100, .shield = 50 } };

    processPayload(jett_payload);
    processPayload(gecko_payload);
}

// Simple switch on the standalone enum
fn print(who_is_there: Agent) void {
    switch (who_is_there) {
        .jett => std.debug.print("JETT HERE\n", .{}),
        .reyna => std.debug.print("REYNA HERE\n", .{}),
        else => std.debug.print("DONT KNOW WHO\n", .{}),
    }
}

// Switching on a Tagged Union to extract payload data safely
fn processPayload(payload: AgentPayload) void {
    switch (payload) {
        // Capture inner struct value into `jett_data`
        .jett => |jett_data| std.debug.print("Jett dash cooldown: {d:.1}s\n", .{jett_data.dash_cooldown}),
        .reyna => |reyna_data| std.debug.print("Reyna soul orbs: {d}\n", .{reyna_data.soul_orbs}),
        .gecko => |stats| std.debug.print("Gecko HP: {d}, Shield: {d}\n", .{ stats.hp, stats.shield }),
    }
}