# Zixport

The game core logic is managed in zig, exported as a C API.

Each platform wrapper (`macos`, `web`, etc) creates a native window, forwards input events, and blits the pixel buffer to the screen. 

Adding a new platform means writing a thin wrapper — the game logic stays the same.

### Build & Run

```sh
make macos         # Build and run macos
```

### Caution

- The macos swift wrapper is mainly written by llm, so it maybe very wrong!
