.PHONY: clean macos

clean:
	rm -rf .zig-cache zig-out

macos:
	zig build macos
