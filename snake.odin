package main

import "core:fmt"
import rl "vendor:raylib"

SQUARE_SIZE          :: 40
GRID_HORIZONTAL_SIZE :: 20
GRID_VERTICAL_SIZE   :: 20

SCREEN_WIDTH         :: 800
SCREEN_HEIGHT        :: 800

SNAKE_LENGHT         :: 256

game_over := false
pause := false
counter_tail := 0
frame_counter := 0

allow_move := false

Vector2 :: struct {
    x: f32,
    y: f32,
}

Snake :: struct {
    speed: Vector2,
    position: Vector2,
    size: Vector2,
    color: rl.Color
}

Food :: struct {
    position: Vector2,
    size: Vector2,
    color: rl.Color,
    active: bool
}

snake: [SNAKE_LENGHT]Snake
fruit: Food
snake_position: [SNAKE_LENGHT]Vector2
offset: Vector2

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Snaaaak")
    defer rl.CloseWindow()

    init_game()

    rl.SetTargetFPS(60)

    for !rl.WindowShouldClose() {
        update_game()
        draw_game()
    }
}

init_game :: proc() {
    frame_counter = 0
    game_over = false
    pause = false

    counter_tail = 1
    allow_move = false

    offset.x = SCREEN_WIDTH%SQUARE_SIZE
    offset.y = SCREEN_HEIGHT%SQUARE_SIZE

    for i := 0; i < SNAKE_LENGHT; i += 1 {
        snake[i].position = Vector2{offset.x/2, offset.y/2}
        snake[i].size = Vector2{SQUARE_SIZE, SQUARE_SIZE}
        snake[i].speed = Vector2{SQUARE_SIZE, 0}

        if i == 0 {
            snake[i].color = rl.DARKBLUE
        } else {
            snake[i].color = rl.BLUE
        }
    }

    for i := 0; i < SNAKE_LENGHT; i += 1 {
        snake_position[i] = Vector2{0.0, 0.0}
    }

    fruit.size = Vector2{SQUARE_SIZE, SQUARE_SIZE}
    fruit.color = rl.SKYBLUE
    fruit.active = false
}

update_game :: proc() {
    if !game_over {
        if rl.IsKeyPressed(.P) {
            pause = !pause
        }

        if !pause {
            if rl.IsKeyPressed(.RIGHT) && (snake[0].speed.x == 0) && allow_move {
                snake[0].speed = Vector2{SQUARE_SIZE, 0}
                allow_move = false
            }
            if rl.IsKeyPressed(.LEFT) && (snake[0].speed.x == 0) && allow_move {
                snake[0].speed = Vector2{-SQUARE_SIZE, 0}
                allow_move = false
            }
            if rl.IsKeyPressed(.UP) && (snake[0].speed.y == 0) && allow_move {
                snake[0].speed = Vector2{0, -SQUARE_SIZE}
                allow_move = false
            }
            if rl.IsKeyPressed(.DOWN) && (snake[0].speed.y == 0) && allow_move {
                snake[0].speed = Vector2{0, SQUARE_SIZE}
                allow_move = false
            }

            for i := 0; i < counter_tail; i += 1 {
                snake_position[i] = snake[i].position
            }

            if frame_counter % 5 == 0 {
                for i := 0; i < counter_tail; i += 1 {
                    if i == 0 {
                        snake[0].position.x += snake[0].speed.x
                        snake[0].position.y += snake[0].speed.y
                        allow_move = true
                    } else {
                        snake[i].position = snake_position[i-1]
                    }
                }
            }

            if snake[0].position.x > SCREEN_WIDTH - 1 ||
                snake[0].position.y > SCREEN_HEIGHT - 1 ||
                snake[0].position.x < 0 || snake[0].position.y < 0 {
                    game_over = true
                }

            for i := 1; i < counter_tail; i += 1 {
                if (snake[0].position.x == snake[i].position.x) && (snake[0].position.y == snake[i].position.y) {
                    game_over = true
                }
            }

            if !fruit.active {
                fruit.active = true
                fruit.position = Vector2{ f32(rl.GetRandomValue(0, (SCREEN_WIDTH/SQUARE_SIZE) - 1)*SQUARE_SIZE) + offset.x/2, f32(rl.GetRandomValue(0, (SCREEN_HEIGHT/SQUARE_SIZE) - 1)*SQUARE_SIZE) + offset.y/2 }
                for i := 0; i < counter_tail; i += 1 {
                    if fruit.position.x == snake[i].position.x && fruit.position.y == snake[i].position.y {
                        fruit.position = Vector2{ f32(rl.GetRandomValue(0, (SCREEN_WIDTH/SQUARE_SIZE) - 1)*SQUARE_SIZE) + offset.x/2, f32(rl.GetRandomValue(0, (SCREEN_HEIGHT/SQUARE_SIZE) - 1)*SQUARE_SIZE) + offset.y/2 }
                        i = 0
                    }
                }
            }

            if snake[0].position.x < (fruit.position.x + fruit.size.x) && (snake[0].position.x + snake[0].size.x) > fruit.position.x &&
                snake[0].position.y < (fruit.position.y + fruit.size.y) && (snake[0].position.y + snake[0].size.y) > fruit.position.y
            {
                snake[counter_tail].position = snake_position[counter_tail - 1]
                counter_tail += 1
                fruit.active = false
            }

            frame_counter += 1
        }
    } else {
        if rl.IsKeyPressed(.ENTER) {
            init_game()
            game_over = false
        }
    }
}

draw_game :: proc() {
    rl.BeginDrawing()
    defer rl.EndDrawing()

    rl.ClearBackground(rl.RAYWHITE)

    if !game_over {
        offset := [2]i32{
            SCREEN_WIDTH/2 - (GRID_HORIZONTAL_SIZE*SQUARE_SIZE/2),
            SCREEN_HEIGHT/2 - (GRID_VERTICAL_SIZE*SQUARE_SIZE/2),
        }

        controller := offset.x

        for i in 0..<GRID_VERTICAL_SIZE {
            for j in 0..<GRID_HORIZONTAL_SIZE{
                rl.DrawLine(offset.x, offset.y, offset.x + SQUARE_SIZE, offset.y, rl.LIGHTGRAY)
                rl.DrawLine(offset.x, offset.y, offset.x, offset.y + SQUARE_SIZE, rl.LIGHTGRAY)
                rl.DrawLine(offset.x + SQUARE_SIZE, offset.y, offset.x + SQUARE_SIZE, offset.y + SQUARE_SIZE, rl.LIGHTGRAY)
                rl.DrawLine(offset.x, offset.y + SQUARE_SIZE, offset.x + SQUARE_SIZE, offset.y + SQUARE_SIZE, rl.LIGHTGRAY)
                offset.x += SQUARE_SIZE
            }
            offset.x = controller
            offset.y += SQUARE_SIZE
        }

        controller = offset.x

        for i := 0; i < counter_tail; i += 1 {
            rl.DrawRectangleV({snake[i].position.x, snake[i].position.y}, {snake[i].size.x, snake[i].size.y}, snake[i].color)
        }

        rl.DrawRectangleV({fruit.position.x, fruit.position.y}, {fruit.size.x, fruit.size.y}, fruit.color)

        if pause {
            text :: "GAME PAUSED"
            rl.DrawText(text, rl.GetScreenWidth()/2 - rl.MeasureText(text, 20)/2, rl.GetScreenHeight()/2 - 50, 20, rl.GRAY)
        }
    } else {
        text :: "PRESS [ENTER] TO PLAY"
        rl.DrawText(text, rl.GetScreenWidth()/2 - rl.MeasureText(text, 20)/2, rl.GetScreenHeight()/2 - 50, 20, rl.GRAY)
    }
}

