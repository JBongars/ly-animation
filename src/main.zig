const std = @import("std");
// const build_options = @import("build_options");
// const builtin = @import("builtin");
// const clap = @import("clap");
// const ini = @import("zigini");
// const auth = @import("auth.zig");
// const bigclock = @import("bigclock.zig");
const enums = @import("enums.zig");
// const Environment = @import("Environment.zig");
// const 
const ColorMix = @import("animations/ColorMix.zig");
const Doom = @import("animations/Doom.zig");
const Dummy = @import("animations/Dummy.zig");
const Matrix = @import("animations/Matrix.zig");
const Animation = @import("tui/Animation.zig");
const TerminalBuffer = @import("tui/TerminalBuffer.zig");
const Session = @import("tui/components/Session.zig");
// const Text = @import("tui/components/Text.zig");
// const InfoLine = @import("tui/components/InfoLine.zig");
const Config = @import("config/Config.zig");
// const Lang = @import("config/Lang.zig");
// const Save = @import("config/Save.zig");
// const migrator = @import("config/migrator.zig");
// const SharedError = @import("SharedError.zig");
const interop = @import("interop.zig");

// const Ini = ini.Ini;
// const DisplayServer = enums.DisplayServer;
// const Entry = Environment.Entry;
// const termbox = interop.termbox;
// const unistd = interop.unistd;
// const temporary_allocator = std.heap.page_allocator;
// const ly_top_str = "Ly version " ++ build_options.version;

const termbox = @import("termbox2");  // Add this import

fn get_buffer(config : Config) TerminalBuffer {
    const buffer_options = TerminalBuffer.InitOptions{
        .fg = config.fg,
        .bg = config.bg,
        .border_fg = config.border_fg,
        .margin_box_h = config.margin_box_h,
        .margin_box_v = config.margin_box_v,
        .input_len = config.input_len,
    };
    const labels_max_length = 0;

    // Get a random seed for the PRNG (used by animations)
    var seed: u64 = undefined;
    std.crypto.random.bytes(std.mem.asBytes(&seed)); 

    var prng = std.Random.DefaultPrng.init(seed);
    const random = prng.random();
    return TerminalBuffer.init(buffer_options, labels_max_length, random);
}

pub fn main() !void {
    const config = Config{
        .animation = enums.Animation.doom,
    };

    _ = termbox.tb_init();
    defer _ = termbox.tb_shutdown();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    var buffer = get_buffer(config);

    // var info_line = InfoLine.init(allocator, &buffer);
    // var session = Session.init(allocator, &buffer);
    const allocator = gpa.allocator();

    var animation: Animation = undefined;

    switch (config.animation) {
        .none => {
            var dummy = Dummy{};
            animation = dummy.animation();
        },
        .doom => {
            var doom = try Doom.init(allocator, &buffer, config.doom_top_color, config.doom_middle_color, config.doom_bottom_color);
            animation = doom.animation();
        },
        .matrix => {
            var matrix = try Matrix.init(allocator, &buffer, config.cmatrix_fg, config.cmatrix_min_codepoint, config.cmatrix_max_codepoint);
            animation = matrix.animation();
        },
        .colormix => {
            var color_mix = ColorMix.init(&buffer, config.colormix_col1, config.colormix_col2, config.colormix_col3);
            animation = color_mix.animation();
        },
    }

    defer animation.deinit();

    // draw animation
    while(true) {
        //resize buffer
        const width: usize = @intCast(termbox.tb_width());
        const height: usize = @intCast(termbox.tb_height());

        if (width != buffer.width or height != buffer.height) {
            buffer.width = width;
            buffer.height = height;
        }

        _ = termbox.tb_clear();
        animation.draw();
        _ = termbox.tb_present();
        std.time.sleep(std.time.ns_per_ms * 50); // ~20 FPS
    }
}
