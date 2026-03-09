.PHONY: clean run/macos

clean:
	rm -rf .zig-cache zig-out

run/macos:
	zig build run-macos
