#include "raylib.h"

int main(void) {
  InitWindow(800, 450, "Hello, World!");

  while (!WindowShouldClose()) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Hello, World!", 10, 10, 20, DARKGRAY);
    EndDrawing();
  }

  CloseWindow();

  return 0;
}
