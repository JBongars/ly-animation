const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    const exe = b.addExecutable(.{
        .name = "ly_animations",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    
    // exe.linkLibC();
    // exe.addIncludePath(b.path("termbox2/"));
    // exe.addObjectFile(b.path("termbox2/libtermbox2.a"));

    const translate_c = b.addTranslateC(.{
        .root_source_file = b.path("include/termbox2.h"),
        .target = target,
        .optimize = optimize,
    });
    translate_c.defineCMacroRaw("TB_IMPL");
    translate_c.defineCMacro("TB_OPT_ATTR_W", "32"); // Enable 24-bit color support + styling (32-bit)
    const termbox2 = translate_c.addModule("termbox2");
    exe.root_module.addImport("termbox2", termbox2);
    
    b.installArtifact(exe);
    
    const run_cmd = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
