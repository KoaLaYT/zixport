# Zixport

The game library manages a pixel buffer and exposes a C API. Each platform wrapper creates a native window, forwards input events, and blits the pixel buffer to the screen. 
Adding a new platform means writing a thin wrapper — the game logic stays the same.

### Build & Run

```sh
make macos         # Build and run macos
```
