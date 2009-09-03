-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- CTAF
require("ctafconf")
require("teardrop")
require("dbg")
-- ECTAF

-- {{{ Variable definitions
-- This is used later as the default terminal and editor to run.
terminal = "xterm"
-- CTAF
terminal = "gnome-terminal"

-- Zenburn theme
beautiful.init("/usr/share/awesome/themes/zenburn/theme.lua")

-- ECTAF

editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier,
    awful.layout.suit.floating
}
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}


-- CTAF
tags.settings = {
    { name = "1:www",  layout = awful.layout.suit.max  },
    { name = "2:term", layout = awful.layout.suit.fair  },
    { name = "3:term", layout = awful.layout.suit.fair  },
    { name = "4:prog", layout = awful.layout.suit.max  },
    { name = "5:im",   layout = awful.layout.floating, mwfact = 0.13 },
    { name = "6:misc", layout = awful.layout.suit.max, hide = false },
}

-- Initialize tags
for s = 1, screen.count() do
    tags[s] = {}
    for i, v in ipairs(tags.settings) do
        tags[s][i] = tag({ name = v.name })
        tags[s][i].screen = s
        awful.tag.setproperty(tags[s][i], "layout", v.layout)
        awful.tag.setproperty(tags[s][i], "mwfact", v.mwfact)
        awful.tag.setproperty(tags[s][i], "hide",   v.hide)
    end
    tags[s][1].selected = true
end
-- }}}

-- for s = 1, screen.count() do
--     -- Each screen has its own tag table.
--     tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s)
-- end
-- ECTAF
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = {
                              { "menu", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" })


-- Create a systray
mysystray = widget({ type = "systray" })

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
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              -- CTAF
                              	              -- return awful.widget.tasklist.label.currenttags(c, s)
                                              return awful.widget.tasklist.label.currenttags(c, s, { display_tab = true })
                                              -- ECTAF
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        mytextclock,
        s == 1 and mysystray or nil,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    -- CTAF
    -- awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    -- awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    -- ECTAF
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
    awful.key({ modkey,           }, "w", function () mymainmenu:show(true)        end),

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
    -- CTAF
    --awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    -- ECTAF
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    -- CTAF
    -- awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Mod1"    }, "space", function () awful.layout.inc(layouts,  1) end),
    -- ECTAF
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- CTAF
    -- Prompt
    awful.key({ modkey }, "F1", function ()
                                    awful.prompt.run({ prompt = "Run: " },
                                                     mypromptbox[mouse.screen],
                                                     awful.util.spawn, awful.completion.shell,
                                                     awful.util.getdir("cache") .. "/history")
                                end),

    awful.key({ modkey }, "F2", function() awful.util.spawn(terminal, true, get_screen().index)                 end),
    awful.key({ modkey }, "F3", function() teardrop.toggle("gmrun", 1, 0.10) end),

    awful.key({ modkey }, "F4", function ()
                                    awful.prompt.run({ prompt = "Run Lua code: " },
                                                     mypromptbox[mouse.screen],
                                                     awful.util.eval, nil,
                                                     awful.util.getdir("cache") .. "/history_eval")
                                end),

    awful.key({ modkey }, "F5", function() awful.util.spawn("nautilus --no-desktop", true, get_screen().index)  end),
    awful.key({ modkey }, "F6", function() awful.util.spawn("epiphany", true, get_screen().index)               end),
    awful.key({ modkey }, "F8", function() awful.util.spawn("totem", true, get_screen().index)                  end),

    awful.key({ modkey }, "Up",   function () no_mouse_focus_screen(1) end),
    awful.key({ modkey }, "Down", function () no_mouse_focus_screen(2) end),

    awful.key({ modkey,         }, "Left", function ()
           awful.client.focus.byidx(-1);
           if client.focus then
              client.focus:raise()
           end
        end),
    awful.key({ modkey,         }, "Right", function ()
           awful.client.focus.byidx(1);
           if client.focus then
              client.focus:raise()
           end
        end),

    awful.key({ modkey, "Shift"   }, "Left",
              function ()
                  awful.tag.viewidx(-1, get_screen())
              end),

    awful.key({ modkey, "Shift"   }, "Right",
              function ()
                  awful.tag.viewidx(1, get_screen())
              end),

--scratchpad replacement
-- simply toggle a tag on/off
    awful.key({ modkey, }, "space",
              function ()
                  local tscreen    = 1
                  local ttag       = 1
                  toggle_scratchpad(ttag, tscreen)
              end),

    -- toggle im on and off
    awful.key({ modkey,           }, "Return", function () awful.tag.viewtoggle(tags[1][5]) end),

    awful.key({ modkey            }, 't',           tag_info, nil, "tag info"),

    --- tab manipulation
    -- remove a client from a tag
    awful.key({ modkey, "Shift"   }, "y", awful.tab.remove),
    -- cycle through tab
    awful.key({ modkey,           }, "y", awful.tab.cycle),
    awful.key({ modkey, "Control" }, "y", awful.tab.add_next_client),
    -- create a tab from all marked client
    awful.key({ modkey, 'Shift'   }, "t", awful.tab.create_from_marked),

    -- ECTAF

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end),
    -- CTAF
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "i",      client_info),
    awful.key({ modkey,           }, "e",      function (c)
                                                   naughty.notify{text="client " .. c.name .. " marked."}
                                                   awful.client.mark(c)
                                               end)
    -- ECTAF
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, i,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, i,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, i,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, i,
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
    { rule = { class = "Gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },

    -- CTAF
    -- Tag 1:www
    { rule = { class = "Epiphany-browser" },
      properties = { tag = tags[1][1], switchtotag = true } },
    { rule = { class = "Epiphany-browser", role = "epiphany-extension-manager" },
      properties = { floating = true } },

    { rule = { class = "Firefox" },
      properties = { tag = tags[1][1], switchtotag = true } },
    { rule = { class = "Firefox", role = "Manager" },
      properties = { floating = true } },


    -- Tag 4:prog
    { rule = { class = "Emacs" },
      properties = { tag = tags[1][4], switchtotag = true } },
    { rule = { class = "Gitk" },
      properties = { tag = tags[1][4], switchtotag = true } },
    { rule = { class = "Git-gui" },
      properties = { tag = tags[1][4], switchtotag = true } },


    -- Tag 5:im
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][5], floating = true, ontop = true } },
    { rule = { name = "Buddy List" },
      properties = { tag = tags[1][5], floating = true, ontop = true } },

    -- Tag 6:misc
    { rule = { class = "Evince" },
      properties = { tag = tags[1][6], switchtotag = true } },
    { rule = { class = "Totem" },
      properties = { tag = tags[1][6], switchtotag = true } },


    -- ECTAF
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- If we are not managing this application at startup,
    -- move it to the screen where the mouse is.
    -- We only do it for filtered windows (i.e. no dock, etc).
    if not startup and awful.client.focus.filter(c) then
        c.screen = mouse.screen
    end

    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })
    -- CTAF
    local mytab = awful.widget.tablist(function(c)
                                           return awful.widget.tablist.label.currenttab(c, s)
                          end, mytasklist.buttons, c)

    awful.titlebar.add(c, { modkey = modkey, widget = {mytab} })
--   -- Add a titlebar to each client if enabled globaly
--     if use_titlebar then
--         awful.titlebar.add(c, { modkey = modkey })
--     -- Floating clients always have titlebars
--     elseif awful.client.floating.get(c)
--         or awful.layout.get(c.screen) == awful.layout.suit.floating then
--             if not c.fullscreen then
--                 if not c.titlebar and c.class ~= "Xmessage" then
--                     awful.titlebar.add(c, { modkey = modkey })
--                 end
--                 -- Floating clients are always on top
--                 c.above = true
--             end
--     end

    -- ECTAF

    -- Enable sloppy focus
--     c:add_signal("mouse::enter", function(c)
--         if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
--             and awful.client.focus.filter(c) then
--             client.focus = c
--         end
--     end)

    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- CTAF
    awful.client.setslave(c)

    -- New floating windows:
    awful.placement.no_offscreen(c)
    -- ECTAF
end)

-- CTAF
-- force client on tag 5 to be floating and ontop
--client.add_signal("manage", function (c, startup)
client.add_signal("new", function (c)
    c:add_signal("tagged", function(c, t)
        if t == tags[1][5] then
            c.ontop = true
            --yeah crappy but need to be set before floating
            --awful.client.property.set(c, "floating_geometry", c:geometry())
            awful.client.floating.set(c, true)
        end
    end)
end)

autotab_start()

-- ECTAF

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
