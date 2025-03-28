const std = @import("std");
const rl = @import("raylib");
const gameOfLife = @import("game_of_life.zig").GameOfLife;

pub fn main() !void {
    const cellsize: i32 = 2;
    const grid_w: i32 = 500;
    const grid_h: i32 = 500;

    const window_w: i32 = cellsize * grid_w;
    const window_h: i32 = cellsize * grid_h;

    rl.initWindow(window_w, window_h, "Game of Life");
    rl.setTargetFPS(200);

    //init game of life
    var game = try gameOfLife.init(window_h, window_w);
    const starting_cells = [_][2]usize{ [2]usize{ 20, 20 }, [2]usize{ 21, 21 }, [2]usize{ 21, 22 }, [2]usize{ 20, 22 }, [2]usize{ 19, 22 } };

    game.set_cells(starting_cells[0..]);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        for (0..game.cells.len) |i| {
            for (0..game.cells[i].len) |j| {
                if (game.cells[i][j]) {
                    const i_cast: i32 = @intCast(i);
                    const j_cast: i32 = @intCast(j);
                    rl.drawRectangle(i_cast * cellsize, j_cast * cellsize, cellsize, cellsize, .gray);
                }
            }
        }

        try game.update();
        rl.clearBackground(.white);
    }
}
