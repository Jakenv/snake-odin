package main

import "core:fmt"
import rl "vendor:raylib"

SCREEN_WIDTH :: 800
SCREEN_HIGHT :: 800

game_over := false
pause := false

begin_play := true

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HIGHT, "Snaaaak")
    defer rl.CloseWindow()

    init_game()

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        update_game()
        draw_game()
    }
}

init_game :: proc() {
    pause = false

    begin_play = true
    game_over = true

}

update_game :: proc() {
    if game_over {
        if rl.IsKeyPressed(.ENTER) {
            init_game()
            game_over = false
        }
        return
    }

    if rl.IsKeyPressed(.P) {
        pause = !pause
    }

    if pause {
        return
    }
}

draw_game :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    if game_over {
        text :: "PRESS [ENTER] TO PLAY"
        rl.DrawText(text, rl.GetScreenWidth()/2 - rl.MeasureText(text, 20)/2, rl.GetScreenHeight()/2 - 50, 20, rl.GRAY)
        return
    }

    if pause {
        text :: "GAME PAUSED"
        rl.DrawText(text, rl.GetScreenWidth()/2 - rl.MeasureText(text, 20)/2, rl.GetScreenHeight()/2 - 50, 20, rl.GRAY)
    }
}
