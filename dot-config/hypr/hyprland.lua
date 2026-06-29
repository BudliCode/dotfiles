-- Hyprland 0.55+ Lua config
-- Migrated from hyprlang format

-- ── Environment ──────────────────────────────────────────────
hl.env("SHELL", "tmux")
hl.env("PIPEWIRE_LATENCY", "32/48000")
hl.env("XCURSOR_SIZE", "32")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("GDK_BACKEND", "wayland,x11,*")
hl.env("QT_QPA_PLATFORM", "wayland")
hl.env("SDL_VIDEODRIVER", "wayland")
hl.env("CLUTTER_BACKEND", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("HYPRSHOT_DIR", os.getenv("HOME") .. "/Pictures/Screenshots/")

-- ── Variables ────────────────────────────────────────────────
local terminal = "alacritty"
local fileManager = "dolphin"
local menu = "wofi --show drun"
local browser = "zen-browser"
local mainMod = "SUPER"

-- ── Monitor setup (auto-detect by hostname) ──────────────────
local hostname = io.popen("uname -n"):read("*l"):gsub("%s+", "")
local monitorConfig = os.getenv("HOME") .. "/.config/hypr/monitorSetups/" .. hostname .. ".lua"
local f = io.open(monitorConfig, "r")
if f then
    f:close()
    dofile(monitorConfig)
else
    hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
end

-- ── Autostart ────────────────────────────────────────────────
hl.on("hyprland.start", function()
    hl.exec_cmd("hyprpaper -n")
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")
    hl.exec_cmd("dunst")
    hl.exec_cmd("udiskie")
end)

-- ── XWayland ─────────────────────────────────────────────────
hl.config({
    xwayland = {
        force_zero_scaling = true
    }
})

-- ── General ──────────────────────────────────────────────────
hl.config({
    general = {
        border_size = 2,
        gaps_in = 3,
        gaps_out = 9,
        ["col.active_border"] = {
            colors = { "rgba(33ccffee)", "rgba(00ff99ee)" },
            angle = 135
        },
        ["col.inactive_border"] = "rgba(595959aa)",
        layout = "dwindle",
        allow_tearing = true
    }
})

-- ── Decoration ───────────────────────────────────────────────
hl.config({
    decoration = {
        rounding = 8,
        active_opacity = 0.92,
        inactive_opacity = 0.88,
        dim_inactive = false,
        blur = {
            enabled = true,
            size = 5,
            passes = 1
        }
    }
})

-- ── Animations ───────────────────────────────────────────────
hl.curve("myBezier", {
    type = "bezier",
    points = { { 0.05, 0.9 }, { 0.1, 1.05 } }
})

hl.config({ animations = { enabled = true } })

hl.animation({ leaf = "windows",    enabled = true, speed = 7,  bezier = "myBezier" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7,  bezier = "default", style = "popin 80%" })
hl.animation({ leaf = "border",     enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "borderangle",enabled = true, speed = 8,  bezier = "default" })
hl.animation({ leaf = "fade",       enabled = true, speed = 7,  bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6,  bezier = "default" })

-- ── Input ────────────────────────────────────────────────────
hl.config({
    input = {
        kb_layout = "de",
        kb_options = "caps:escape",
        numlock_by_default = true,
        repeat_rate = 40,
        repeat_delay = 300,
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",
        touchpad = {
            natural_scroll = true,
            scroll_factor = 0.2,
            disable_while_typing = true
        }
    }
})

-- ── Layouts ──────────────────────────────────────────────────
hl.config({
    dwindle = {
        preserve_split = true
    }
})

-- ── Per-device config ────────────────────────────────────────
hl.device({
    name = "elan06fa:00-04f3:32b2-touchpad",
    accel_profile = "adaptive",
    sensitivity = 0.3
})

-- ═══════════════════════════════════════════════════════════════
-- KEYBINDS
-- ═══════════════════════════════════════════════════════════════

-- Screenshots
hl.bind("SUPER + Print",           hl.dsp.exec_cmd("hyprshot -m window"))
hl.bind("Print",                   hl.dsp.exec_cmd("hyprshot -m output"))
hl.bind("SHIFT + Print",           hl.dsp.exec_cmd("hyprshot -m region"))

-- Apps
hl.bind("SUPER + T",               hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + E",               hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + B",               hl.dsp.exec_cmd(browser))
hl.bind("SUPER + space",           hl.dsp.exec_cmd(menu))
hl.bind("SUPER + escape",          hl.dsp.exec_cmd("hyprlock"))

-- Window management
hl.bind("SUPER + C",               hl.dsp.window.kill())
hl.bind("SUPER + V",               hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + F",               hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + P",               hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind("SUPER + S",               hl.dsp.layout("togglesplit"))

-- Focus movement (vi-style)
hl.bind("SUPER + H",               hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + L",               hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + K",               hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + J",               hl.dsp.focus({ direction = "d" }))

-- Window movement (vi-style)
hl.bind("SUPER + SHIFT + H",       hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + L",       hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + K",       hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + J",       hl.dsp.window.move({ direction = "d" }))

-- Workspaces
for i = 1, 10 do
    hl.bind("SUPER + " .. i,             hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i,     hl.dsp.window.move({ workspace = i }))
end

-- Scroll workspaces
hl.bind("SUPER + mouse_down",       hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up",         hl.dsp.focus({ workspace = "e-1" }))

-- Mouse binds (drag/resize)
hl.bind("SUPER + mouse:272",        hl.dsp.window.drag(),   { mouse = true })
hl.bind("SUPER + mouse:273",        hl.dsp.window.resize(), { mouse = true })

-- ── Resize submap ────────────────────────────────────────────
hl.bind("SUPER + R", hl.dsp.submap("resize"))

hl.define_submap("resize", function()
    hl.bind("catchall", hl.dsp.no_op())

    hl.bind("L", hl.dsp.window.resize({ x = 10,  y = 0,  relative = true }), { repeating = true })
    hl.bind("H", hl.dsp.window.resize({ x = -10, y = 0,  relative = true }), { repeating = true })
    hl.bind("K", hl.dsp.window.resize({ x = 0,   y = -10, relative = true }), { repeating = true })
    hl.bind("J", hl.dsp.window.resize({ x = 0,   y = 10,  relative = true }), { repeating = true })

    hl.bind("SHIFT + L", hl.dsp.window.resize({ x = 2,  y = 0,  relative = true }), { repeating = true })
    hl.bind("SHIFT + H", hl.dsp.window.resize({ x = -2, y = 0,  relative = true }), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.window.resize({ x = 0,  y = -2, relative = true }), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.window.resize({ x = 0,  y = 2,  relative = true }), { repeating = true })

    hl.bind("CTRL + L", hl.dsp.window.resize({ x = 40,  y = 0,  relative = true }), { repeating = true })
    hl.bind("CTRL + H", hl.dsp.window.resize({ x = -40, y = 0,  relative = true }), { repeating = true })
    hl.bind("CTRL + K", hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
    hl.bind("CTRL + J", hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)

-- ── Media keys ───────────────────────────────────────────────
-- System volume (Shift + media keys)
hl.bind("SHIFT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+"), { locked = true, repeating = true })
hl.bind("SHIFT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-"), { locked = true, repeating = true })

-- Player volume (media keys)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("playerctl volume 0.01+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("playerctl volume 0.01-"), { locked = true, repeating = true })

-- Mute
hl.bind("SUPER + M",          hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })
hl.bind("XF86AudioMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })

-- Playback
hl.bind("XF86AudioPlay",      hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",      hl.dsp.exec_cmd("playerctl next"),       { locked = true })

-- Brightness
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl s 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 5%-"), { locked = true, repeating = true })

-- ── Audio submap ─────────────────────────────────────────────
hl.bind("SUPER + A", hl.dsp.submap("audio"))

hl.define_submap("audio", function()
    hl.bind("catchall", hl.dsp.no_op())

    hl.bind("K", hl.dsp.exec_cmd("playerctl volume 0.05+"), { repeating = true })
    hl.bind("J", hl.dsp.exec_cmd("playerctl volume 0.05-"), { repeating = true })
    hl.bind("L", hl.dsp.exec_cmd("playerctl next"))
    hl.bind("H", hl.dsp.exec_cmd("playerctl previous"))
    hl.bind("S", hl.dsp.exec_cmd("playerctl shuffle toggle"))
    hl.bind("O", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/togglePlayerLoop.sh"))
    hl.bind("C", hl.dsp.exec_cmd("playerctl stop"))
    hl.bind("P", hl.dsp.exec_cmd("playerctl play-pause"))
    hl.bind("M", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_SOURCE@ toggle"), { locked = true })

    hl.bind("SHIFT + L", hl.dsp.exec_cmd("playerctl position 30+"), { repeating = true })
    hl.bind("SHIFT + H", hl.dsp.exec_cmd("playerctl position 30-"), { repeating = true })
    hl.bind("SHIFT + K", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
    hl.bind("SHIFT + J", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })

    hl.bind("escape", hl.dsp.submap("reset"))
end)
