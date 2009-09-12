---------------------------------------------------------------------------
-- Drop down (quake-like) applications for the awesome window manager
--   * Updated on: Aug 27, 15:09:15 CEST 2009
---------------------------------------------------------------------------
-- Original by: Lucas de Vries <lucas_glacicle_com>
--   * http://awesome.naquadah.org/wiki/Drop-down_terminal
--
-- Modified by: Adrian C. <anrxc_sysphere_org>
--   * Original code turned into a module
--   * Startup notification disabled
--   * Slides in from the bottom of the screen by default
--   * Ported to awesome 3.4 (signals, new properties...)
--
-- Modified by: Cedric GESTES <ctaf42_gmail_com>
--   * refactoring, object oriented
--   * use rules to setup the windows
--
-- Old module (for awesome < v3.4) is available here:
--   * http://sysphere.org/~anrxc/local/scr/sources/teardrop-old.lua
--
-- Licensed under the WTFPL version 2
--   * http://sam.zoy.org/wtfpl/COPYING
---------------------------------------------------------------------------
-- To use this module add:
--     require("teardrop")
-- to the top of your rc.lua and call:
--     teardrop.toggle(prog, edge, height, screen)
-- from a keybinding.
--
-- Parameters:
--   prog     - Program to run, for example: "urxvt" or "gmrun"
--   edge     - Screen edge (optional), 1 to drop down from the top of the
--              screen, by default it slides in from the bottom
--   height   - Height (optional), in absolute pixels when > 1 or a height
--              percentage when < 1, 0.25 (25% of the screen) by default
--   screen   - Screen (optional)
---------------------------------------------------------------------------

-- Grab environment
local pairs = pairs
local awful = require("awful")
local setmetatable = setmetatable
local capi = {
    mouse = mouse,
    client = client,
    screen = screen
}
local data    = {}
data.dropdown = setmetatable({}, { __mode = 'k' })

local Teardrop = {}
Teardrop.__index = Teardrop


local properties    = {}
properties.default = {
    ontop       = true,
    above       = true,
    sticky      = true,
    floating    = true,
    skip_taskbar= true,
--     height      = 500,
    width       = "100%",
    height      = "50%",
    placement   = "centered",
}



-- Teardrop: Drop down (quake-like) applications for the awesome window manager
module("teardrop")


function Teardrop:show()
    --if not self.active then
    self.client.hidden = false
    self.client:raise()
    capi.client.focus = self.client
    self.active = true
end

function Teardrop:hide()
    self.client.hidden = true
    self.active = false
end


local function spawn(self)
    spawnw = function(c)
        capi.client.remove_signal("manage", spawnw)
        self.client = c
        data.dropdown[c] = self
        --geometry.set(c, self.geometry)

        -- Remove signal
        awful.rules.properties.set(c, properties.default)
        self:show()
    end

    -- Add signal
    capi.client.add_signal("manage", spawnw)
    -- Spawn program
    awful.util.spawn(self.prog, false)
end

-- Drop down (quake-like) application toggle
--
-- Create a new window for the drop-down application when it doesn't
-- exist, or toggle between hidden and visible states if one does
-- exist.
function Teardrop:toggle()
    if not self then
        return
    end

    if not self.client then
        spawn(self)
        return
    end

    -- Focus and raise if not hidden
    if not self.active or self.client.hidden then
        self:show()
    else
        self:hide()
    end
end


function new(prog, screen, edge, properties, geo)
    if edge == nil             then edge     = "top"            end
    if screen == nil           then screen = capi.mouse.screen  end

    local teardrop      = {}
    --teardrop is a class
    setmetatable(teardrop, Teardrop)

    teardrop.client     = nil
    teardrop.active     = false
    teardrop.geometry   = geo
    teardrop.prog       = prog
    teardrop.edge       = edge
    teardrop.screen     = screen
    teardrop.properties = properties

--     data.dropdown[prog] = {}
--     data.dropdown[prog][screen] = teardrop
    return teardrop
end

--- remove a teardrop associated to a client
function unmanage(c)
    if data.dropdown[c] then
        data.dropdown[c].client = nil
        data.dropdown[c].active = false
    end
end

-- Add unmanage signal to remove associated teardrop when a client is killed
capi.client.add_signal("unmanage", unmanage)

setmetatable(_M, { __call = function (_, ...) return new(...) end })
