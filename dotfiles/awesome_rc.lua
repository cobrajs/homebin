-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Vicious widgets
local vicious = require("vicious")

local rodentbane = require("rodentbane")
local scratchpad = require("scratchpad")

local sizing = 24

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
--[[
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
--]]
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
-- beautiful.init(awful.util.getdir("config") .. "/themes/default/theme.lua")
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt"
terminal_big = terminal .. ' -fn "xft:Profont-11"'
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts = {
  awful.layout.suit.max,
  awful.layout.suit.tile,
  awful.layout.suit.tile.left,
  awful.layout.suit.tile.bottom,
  awful.layout.suit.tile.top,
  --awful.layout.suit.floating,
  awful.layout.suit.fair,
  awful.layout.suit.fair.horizontal,
  awful.layout.suit.spiral,
  --awful.layout.suit.spiral.dwindle,
  awful.layout.suit.max.fullscreen,
  --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
  -- Each screen has its own tag table.
  tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
  { "manual", terminal .. " -e man awesome" },
  { "edit config", editor_cmd .. " " .. awesome.conffile },
  { "restart", awesome.restart },
  { "quit", awesome.quit }
}

myrotationmenu = {}
for i, r in ipairs{"normal", "inverted", "left", "right"} do
	table.insert(myrotationmenu, {r, "xrandr -o " .. r})
end

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
																		{ "rotate", myrotationmenu },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
--mytextclock = awful.widget.textclock({ align = "right" }, "  %a %b %d, %I:%M%p")
mytextclock = wibox.widget.textbox()
vicious.register(mytextclock, vicious.widgets.date, "%b %d, %R", 60)
mytextclock:buttons(awful.util.table.join(
  awful.button({ }, 1, function () 
    naughty.notify({ 
      title = " Calendar ",
      text = awful.util.pread("cal"),
      font = "profont",
      timeout = 10
    })
  end)
))
-- Memory tracking widget
mymemlabel = wibox.widget.imagebox()
mymemlabel:set_image("/home/cobra/.config/awesome/icons/trans/mem.png")
mymemwidget = awful.widget.progressbar()
mymemwidget:set_width(sizing)
mymemwidget:set_height(sizing)
mymemwidget:set_vertical(true)
mymemwidget:set_background_color(beautiful.bg_normal)
mymemwidget:set_border_color(beautiful.border_normal)
mymemwidget:set_color(beautiful.fg_normal)
--mymemwidget:set_gradient_colors({ beautiful.fg_normal, "#AA9999", "#66CC66" })
vicious.register(mymemwidget, vicious.widgets.mem, "$1", 20)

-- CPU widget
mycpulabel = wibox.widget.imagebox()
mycpulabel:set_image("/home/cobra/.config/awesome/icons/trans/cpu.png")
mycpuwidget = awful.widget.graph()
mycpuwidget:set_width(30)
mycpuwidget:set_height(sizing)
mycpuwidget:set_background_color(beautiful.bg_normal)
mycpuwidget:set_color(beautiful.fg_normal)
--mycpuwidget:set_gradient_colors({ "#FFCCCC", "#AA9999", "#66CC66" })
vicious.register(mycpuwidget, vicious.widgets.cpu, "$1", 2)

-- Battery widget
mybatterylabel = wibox.widget.imagebox()
mybatterylabel:set_image("/home/cobra/.config/awesome/icons/trans/power-bat.png")
mybatterylabel:buttons(awful.util.table.join(
  awful.button({ }, 1, function()
    naughty.notify({ 
      title = " Battery ",
      text = awful.util.pread("acpi"),
      font = "profont",
      timeout = 10
    })
  end)
))
mybatterywidget = awful.widget.progressbar()
mybatterywidget:set_width(sizing)
mybatterywidget:set_height(sizing)
mybatterywidget:set_vertical(true)
mybatterywidget:set_background_color(beautiful.bg_normal)
mybatterywidget:set_border_color(beautiful.border_normal)
mybatterywidget:set_color(beautiful.fg_normal)
--mybatterywidget:set_gradient_colors({ "#FFCCCC", "#AA9999", "#66CC66" })
vicious.register(mybatterywidget, vicious.widgets.bat, "$2", 70, "BAT0")

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
  -- Create a promptbox for each screen
  mypromptbox[s] = awful.widget.prompt()
  -- Create an imagebox widget which will contains an icon indicating which layout we're using.
  -- We need one layoutbox per screen.
  mylayoutbox[s] = awful.widget.layoutbox(s)
  mylayoutbox[s]:buttons(awful.util.table.join(
                         awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                         awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                         awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                         awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
  -- Create a taglist widget
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

  -- Create a tasklist widget
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

  -- Create the wibox
  mywibox[s] = awful.wibox({ position = "top", screen = s, height = sizing})

  -- Widgets that are aligned to the left
  local left_layout = wibox.layout.fixed.horizontal()
  left_layout:add(mylauncher)
  left_layout:add(mytaglist[s])
  left_layout:add(mypromptbox[s])

  -- Widgets that are aligned to the right
  local right_layout = wibox.layout.fixed.horizontal()
  right_layout:add(mymemlabel)
  right_layout:add(mymemwidget)
  right_layout:add(mybatterylabel)
  right_layout:add(mybatterywidget)
  right_layout:add(mycpulabel)
  right_layout:add(mycpuwidget)
  if s == 1 then right_layout:add(wibox.widget.systray()) end
  right_layout:add(mytextclock)
  right_layout:add(mylayoutbox[s])

  -- Now bring it all together (with the tasklist in the middle)
  local layout = wibox.layout.align.horizontal()
  layout:set_left(left_layout)
  layout:set_middle(mytasklist[s])
  layout:set_right(right_layout)

  mywibox[s]:set_widget(layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal_big) end),
    awful.key({ modkey, "Shift" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "p",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Audio Control
    awful.key({ modkey, "Control"}, "r",    function () awful.util.spawn("amixer sset Master 5%+") end),
    awful.key({ modkey, "Control"}, "f",    function () awful.util.spawn("amixer sset Master 5%-") end),
    awful.key({ modkey, "Control"}, "c",    function () awful.util.spawn("cmus-remote -u")         end),
    awful.key({ modkey, "Control"}, "b",    function () awful.util.spawn("cmus-remote -n")         end),
    awful.key({ modkey, "Control"}, "z",    function () awful.util.spawn("cmus-remote -r")         end),
    awful.key({ modkey, "Control"}, "v",    function () awful.util.spawn("cmus-remote -s")         end),
    awful.key({ modkey, "Control"}, "x",    function () awful.util.spawn("cmus-remote -p")         end),
    awful.key({}, "XF86AudioRaiseVolume",   function () awful.util.spawn("amixer sset Master 5%+") end),
    awful.key({}, "XF86AudioLowerVolume",   function () awful.util.spawn("amixer sset Master 5%-") end),
    awful.key({}, "XF86AudioMute",          function () awful.util.spawn("amixer sset Master toggle") end),

    --awful.key({}, "Super_L",                function () awful.util.spawn_with_shell("if [ $(cat /sys/devices/platform/thinkpad_acpi/hotkey_tablet_mode) -eq 1 ]; then /home/cobra/bin/dzen_buttons.sh; fi") end),
    awful.key({}, "Super_L",                function () awful.util.spawn("/home/cobra/bin/dzen_buttons.sh") end),

    -- Show the current scratchpad
    awful.key({modkey}, "`", function() scratchpad.toggle() end ),
    -- Turn on Rodentbane
    awful.key({modkey}, "g", function() rodentbane.start() end),

    -- Take a screenshot
    awful.key({}, "Print", function() awful.util.spawn("scrot -s -e 'mv $n ~/screenshots/'") end),
    awful.key({ modkey, "Shift"   }, "s", function() awful.util.spawn("scrot -s -e 'mv $n ~/screenshots/'") end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    -- Setup the scratchpad on the current client
    awful.key({modkey, "Shift"}, "`", function(c) scratchpad.set(c, 0.5, 0.5) end )
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    { rule = { class = "Firefox" },
      properties = { tag = tags[1][2], floating = false } },
    -- Setup Default stuff to run in the first desktop
    { rule = { class = "URxvt", name = "htop" },
      properties = { tag = tags[1][1] } },
    { rule = { class = "URxvt", name = "wicd" },
      properties = { tag = tags[1][1] } },
    { rule = { class = "URxvt", name = "cmus" },
      properties = { tag = tags[1][1] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Stuff to run on startup
--
function run_once(comm)
  awful.util.spawn_with_shell("prep -x " .. comm .. " || " .. comm )
end

local commands = {
  {"normal", "urxvt -title 'wicd' -e 'wicd-curses'"},
  {"normal", "urxvt -title 'cmus' -e 'cmus'"},
  {"normal", "urxvt -title 'htop' -e 'htop'"},
  {"once", "onboard"},
  {"once", "firefox"}
}

for _, i in ipairs(commands) do
  if i[1] == "normal" then
    --awful.util.spawn(i[2])
  else
    --run_once(i[2])
  end
end
-- }}}

