-----------------
---- WINDOWS ----
-----------------

local suppressMaximizeRule = hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.layer_rule({
    match = { namespace = "quickshell" },
    blur = true,
    ignore_alpha = 0.1
})

hl.layer_rule({
    match = { namespace = "capture-test" },
    blur = true,
    ignore_alpha = 0.4
})

-- TODO: добавить когда будет lockscreen
-- hl.layer_rule({
--     match = { namespace = "ext-session-lock" },
--     blur = true,
--     ignore_alpha = 0.2
-- })