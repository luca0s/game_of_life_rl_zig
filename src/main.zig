const std = @import("std");
const rl = @import("raylib");
const gameOfLife = @import("game_of_life.zig").GameOfLife;
const Point = @import("game_of_life.zig").Point;

const InteractionState = enum {
    DrawNewCells,
    RunnigSim,
};

const GameState = struct {
    cellsize: i32,
    grid_w: i32,
    grid_h: i32,
    game: gameOfLife,
    interaction_state: InteractionState,
    fps: i32,
    bounds: u32,
};

var state: GameState = GameState{
    .cellsize = 5,
    .grid_w = 200,
    .grid_h = 200,
    .game = undefined,
    .interaction_state = InteractionState.RunnigSim,
    .fps = 60,
    .bounds = 80,
};

pub fn main() !void {
    const window_w: i32 = state.cellsize * state.grid_w;
    const window_h: i32 = state.cellsize * state.grid_h;

    rl.initWindow(window_w, window_h, "Game of Life");
    rl.setTargetFPS(state.fps);

    state.game = try gameOfLife.init(state.bounds);
    // const starting_cells = [_]Point{
    //     Point{ .x = 20, .y = 20 },
    //     Point{ .x = 21, .y = 21 },
    //     Point{ .x = 21, .y = 22 },
    //     Point{ .x = 20, .y = 22 },
    //     Point{ .x = 19, .y = 22 },
    // };

    // try state.game.set_cells(starting_cells[0..]);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        if (rl.isKeyPressed(rl.KeyboardKey.space)) {
            state.interaction_state = InteractionState.DrawNewCells;
        } else if (rl.isKeyPressed(.enter)) {
            state.interaction_state = InteractionState.RunnigSim;
        }

        var iter = state.game.cells.iterator();
        while (iter.next()) |entry| {
            if (entry.value_ptr.*) {
                const x = entry.key_ptr.x;
                const y = entry.key_ptr.y;
                rl.drawRectangle(
                    (@divTrunc(state.grid_w, 2) + x) * state.cellsize,
                    (@divTrunc(state.grid_h, 2) + y) * state.cellsize,
                    state.cellsize,
                    state.cellsize,
                    .gray,
                );
            }
        }

        switch (state.interaction_state) {
            InteractionState.DrawNewCells => try draw_cells(),
            InteractionState.RunnigSim => try state.game.update(),
        }

        rl.drawFPS(10, 10);

        rl.drawText("Pause with SPACE and resume with ENTER\n MOUSE1 to draw cells when paused", 10, 30, 20, .black);
        rl.clearBackground(.white);
    }
}

fn draw_cells() !void {
    if (rl.isMouseButtonDown(.left)) {
        const mouse_pos = rl.getMousePosition();

        const mouse_x = mouse_pos.x / @as(f32, @floatFromInt(state.cellsize));
        const mouse_y = mouse_pos.y / @as(f32, @floatFromInt(state.cellsize));

        try state.game.set_cells(&[_]Point{Point{
            .x = @as(i32, @intFromFloat(mouse_x)) - @divTrunc(state.grid_w, 2),
            .y = @as(i32, @intFromFloat(mouse_y)) - @divTrunc(state.grid_h, 2),
        }});
    }
}
