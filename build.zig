const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "animation_demo",
        .root_source_file = .{ .path = "./src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Add termbox2 C source directly
    exe.addCSourceFile(.{ 
        .file = .{ .path = "termbox2/src/termbox.c" },
        .flags = &[_][]const u8{"-std=c99"}
    });
    
    // Add include directory
    exe.addIncludePath(.{ .path = "termbox2/include" });
    exe.linkLibC();

    b.installArtifact(exe);
}
