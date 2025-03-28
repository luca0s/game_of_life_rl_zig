const std = @import("std");

pub const GameOfLife = struct {
    cells: [][]bool,

    pub fn init(height: usize, width: usize) !GameOfLife {
        const allocator = std.heap.page_allocator;
        const new_cells = try allocator.alloc([]bool, height);

        for (0..new_cells.len) |i| {
            new_cells[i] = try allocator.alloc(bool, width);
        }

        return .{
            .cells = new_cells,
        };
    }

    pub fn update(self: *GameOfLife) !void {
        const allocator = std.heap.page_allocator;
        var new_cells = try allocator.alloc([]bool, self.cells.len);

        for (0..new_cells.len) |i| {
            new_cells[i] = try allocator.alloc(bool, self.cells[i].len);
        }

        for (0..self.cells.len) |i| {
            for (0..self.cells[i].len) |j| {
                const num_of_neighbours = self.get_num_of_neighbours(i, j);

                if (self.cells[i][j]) {
                    new_cells[i][j] = switch (num_of_neighbours) {
                        0...1 => false,
                        2...3 => true,
                        else => false,
                    };
                } else {
                    if (num_of_neighbours == 3) {
                        new_cells[i][j] = true;
                    }
                }
            }
        }

        for (self.cells) |row| {
            allocator.free(row);
        }
        allocator.free(self.cells);

        self.cells = new_cells;
    }

    pub fn set_cells(self: GameOfLife, positions: []const [2]usize) void {
        for (positions) |pos| {
            if (pos.len != 2) {
                return;
            }

            if (!(pos[0] < self.cells.len and pos[1] < self.cells[pos[0]].len)) {
                return;
            }

            self.cells[pos[0]][pos[1]] = true;
        }
    }

    pub fn print(self: GameOfLife) void {
        for (self.cells) |row| {
            for (row) |cell| {
                if (cell) {
                    std.debug.print("1", .{});
                } else {
                    std.debug.print("0", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }

    pub fn get_num_of_neighbours(self: GameOfLife, i: usize, j: usize) u8 {
        const dirs = [8][2]i8{ .{ -1, -1 }, .{ -1, 0 }, .{ -1, 1 }, .{ 0, -1 }, .{ 0, 1 }, .{ 1, -1 }, .{ 1, 0 }, .{ 1, 1 } };
        var sum: u8 = 0;

        for (dirs) |dir| {
            //perform bounds check
            if ((i == 0 and dir[0] == -1) or (j == 0 and dir[1] == -1) or (i == self.cells.len - 1 and dir[0] == 1) or (j == self.cells[j].len - 1 and dir[1] == 1)) {
                continue;
            }

            const off_i: usize = switch (dir[0]) {
                -1 => i - 1,
                0 => i,
                1 => i + 1,
                else => 0,
            };

            const off_j: usize = switch (dir[1]) {
                -1 => j - 1,
                0 => j,
                1 => j + 1,
                else => 0,
            };

            if (self.cells[off_i][off_j]) {
                sum += 1;
            }
        }

        return sum;
    }
};
