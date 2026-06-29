-- Monitor setup for hootsman
-- DP-2: 2560x1440 @ 164Hz (primary, center)
-- HDMI-A-2: 1920x1080 @ 60Hz (left)
-- HDMI-A-1: 1920x1080 @ 60Hz (right)

hl.monitor({ output = "DP-2",     mode = "2560x1440@164", position = "1920x0",  scale = 1 })
hl.monitor({ output = "HDMI-A-2", mode = "1920x1080@60",  position = "0x0",     scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@60",  position = "4480x0",  scale = 1 })

hl.workspace_rule({ workspace = "1", monitor = "HDMI-A-2" })
hl.workspace_rule({ workspace = "2", monitor = "DP-1", default = true })
hl.workspace_rule({ workspace = "3", monitor = "HDMI-A-1" })

hl.on("hyprland.start", function()
    hl.exec_cmd("xrandr --output DP-1 --primary")
    hl.exec_cmd("hyprctl dispatch workspace 2")
end)

hl.config({ cursor = { no_hardware_cursors = true } })
