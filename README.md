# Zixport

The game core logic is managed in zig, exported as a C API.

Each platform wrapper (`macos`, `web`, etc) creates a native window, forwards input events, and blits the pixel buffer to the screen. 

Adding a new platform means writing a thin wrapper — the game logic stays the same.


### Build & Run

```sh
make macos         # Build and run macos
```


### Software Render

https://github.com/user-attachments/assets/81cbd048-8fb7-4574-ae9c-439d6a507f49

The penger is rendered by [formula](https://github.com/tsoding/formula). 

This implementation is not solid, it will
- panic when z <=0.
- the cast from `f32` to `i32` will panic when `f32` is too large.


### Caution

- The macos swift wrapper is mainly written by llm, so it maybe very wrong!
