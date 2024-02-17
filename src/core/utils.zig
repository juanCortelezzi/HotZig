const std = @import("std");

fn LoadedLibrary(comptime Symbols: type) type {
    return struct {
        lib: std.DynLib,
        symbols: Symbols,

        pub fn deinit(self: *@This()) void {
            return self.lib.close();
        }
    };
}

pub fn loadLibrary(comptime Symbols: type, name: []const u8) !LoadedLibrary(Symbols) {
    var dynlib: std.DynLib = try std.DynLib.open(name);

    var symbols: Symbols = undefined;
    inline for (@typeInfo(Symbols).Struct.fields) |field| {
        var field_name: [field.name.len + 1:0]u8 = undefined;
        for (0..field_name.len - 1) |i| {
            field_name[i] = field.name[i];
        }
        field_name[field_name.len - 1] = 0;

        const value = dynlib.lookup(field.type, &field_name) orelse {
            std.debug.print("Error: Could not find symbol '{s}'\n", .{field.name});
            return error.MissingField;
        };
        @field(symbols, field.name) = value;
    }

    return .{ .lib = dynlib, .symbols = symbols };
}
