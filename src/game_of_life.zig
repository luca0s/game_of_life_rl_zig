const std = @import("std");

pub const Point = struct { x: i32, y: i32 };

pub const GameOfLife = struct {
    cells: std.AutoHashMap(Point, bool),
    bounds: ?u32 = null,

    pub fn init(bounds: ?u32) !GameOfLife {
        const allocator = std.heap.page_allocator;
        return .{
            .cells = std.AutoHashMap(Point, bool).init(allocator),
            .bounds = bounds,
        };
    }

    pub fn update(self: *GameOfLife) !void {
        const allocator = std.heap.page_allocator;
        var new_cells = std.AutoHashMap(Point, bool).init(allocator);
        var iter = self.cells.iterator();

        while (iter.next()) |entry| {
            const point = Point{
                .x = entry.key_ptr.x,
                .y = entry.key_ptr.y,
            };

            const cell_state = entry.value_ptr.*;

            if (self.bounds) |bounds| {
                if (@abs(point.x) > bounds or @abs(point.y) > bounds) {
                    continue;
                }
            }

            const num_neighbours = get_num_of_neighbours(self.cells, point);

            if (cell_state) {
                const alive = switch (num_neighbours) {
                    0...1 => false,
                    2...3 => true,
                    else => false,
                };

                if (alive or num_neighbours > 0) {
                    try new_cells.put(Point{ .x = point.x, .y = point.y }, alive);
                    try add_neighbours(&new_cells, point);
                }
            } else {
                const alive = switch (num_neighbours) {
                    3 => true,
                    else => false,
                };

                if (alive or num_neighbours > 3) {
                    try new_cells.put(Point{ .x = point.x, .y = point.y }, alive);
                    try add_neighbours(&new_cells, point);
                }
            }
        }

        self.cells.deinit();
        self.cells = new_cells;
    }

    pub fn set_cells(self: *GameOfLife, points: []const Point) !void {
        for (points) |point| {
            if (self.cells.getEntry(point)) |entry| {
                if (entry.value_ptr.*) {
                    continue;
                }
            }
            try self.cells.put(point, true);
            try add_neighbours(&self.cells, point);
        }
    }

    pub fn print(self: GameOfLife) void {
        var iter = self.cells.iterator();
        while (iter.next()) |entry| {
            const point = entry.key_ptr.*;
            const alive = entry.value_ptr.*;
            std.debug.print("Cell: x={} y={} alive={}\n", .{ point.x, point.y, alive });
        }
    }
};

fn add_neighbours(cells: *std.AutoHashMap(Point, bool), point: Point) !void {
    const dirs = [8][2]i32{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };

    for (dirs) |dir| {
        const new_neighbour = Point{ .x = point.x + dir[0], .y = point.y + dir[1] };
        if (!cells.contains(new_neighbour)) {
            try cells.put(new_neighbour, false);
        }
    }
}

fn get_num_of_neighbours(cells: std.AutoHashMap(Point, bool), point: Point) u8 {
    const dirs = [8][2]i32{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };
    var sum: u8 = 0;

    for (dirs) |dir| {
        if (cells.get(Point{ .x = point.x + dir[0], .y = point.y + dir[1] })) |alive| {
            if (alive) {
                sum += 1;
            }
        }
    }

    return sum;
}
