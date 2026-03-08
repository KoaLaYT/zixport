#ifndef RENDERER_H
#define RENDERER_H

#include <stdbool.h>
#include <stdint.h>

typedef struct {
  uint8_t *display;
  uint32_t display_width;
  uint32_t display_height;
} Game;

Game game_init(void);
bool game_update(void);
void game_key_up(uint16_t keycode);
void game_key_down(uint16_t keycode);

#endif
