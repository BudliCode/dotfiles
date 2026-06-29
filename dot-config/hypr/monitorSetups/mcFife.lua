-- Monitor setup for mcFife (laptop)
-- eDP-1 (built-in): 2880x1800 @ 90Hz, scale 1.5

hl.monitor({ output = "desc:Samsung Display Corp. 0x4152", mode = "2880x1800@90", position = "auto", scale = 1.5 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.workspace_rule({ workspace = "1", monitor = "eDP-1", default = true })

hl.on("hyprland.start", function()
    hl.exec_cmd("xrandr --output eDP-1 --primary")
end)

hl.env("GDK_SCALE", "1.5")
