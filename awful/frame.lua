---------------------------------------------------------------------------
-- @author Cedric Gestes &lt;ctaf42@gmail.com&gt;
-- @copyright 2008 Cedric Gestes
-- @release @AWESOME_VERSION@
---------------------------------------------------------------------------

---contains a sublayout with clients
module("awful.frame")
local setmetatable = setmetatable

local data = {}
--- list of frame
data.frames = setmetatable({}, { __mode = 'k' })

--- index: data.clients[client] = frame
data.clients = setmetatable({}, { __mode = 'k' })


--- a frame containing many client arranged by a layout is seen as only one client
--- a frame is a wibox with a possible taskbar or other widgets
--- clients could be reparenting to the wibox they are arranged by a layout


--- must the frame forward focus?
--- a frame is visible seems like only one client to the rest of awesome as frame are reparented

---should be arrange on focus, on tagged etc.. same as awful.layout.init?


--- a wibox should be seen like a normal client:

--- setup a frame, register signals
function setup(self, args)

    local beautiful    = bt.get()
    local font         = args.font or beautiful.font      or capi.awesome.font
    local fg           = args.fg   or beautiful.fg_normal or '#ffffff'
    local bg           = args.bg   or beautiful.bg_normal or '#535d6c'
    local border_color = args.border_color  or beautiful.bg_focus or '#535d6c'

    -- create container wibox
    self.box = capi.wibox({ fg = fg,
                            bg = bg,
                            border_color = border_color,
                            border_width = border_width })
    -- add a custom set of layout (better as param)
    self.widgets = {}

    self.widgets = {
        --tasklist
        --a reparenting client arranging clients given a layout
    }

    -- the client handling reparenting
    self.client = {}

    --allow client to be reparented to a wibox

end

--- Create a frame
-- @param name of the frame
-- @param layout used to manage a set of client
function new(name, layout)
    local frame = {}

    frame.name   = name
    frame.layout = layout

    frame:setup()

    return tags
end

--- Start managing a client
-- @param self is a frame
-- @param c is a client
function add_client(self, c)
    --do we already manage the client?
    if data.clients[c] == c then
        return
    end

    --insert table
    --self.clients

    --reparent the parent to the wibox
    c:reparent(wibox)
    --data.clients[c] =
end


function remove_client(self, c)
end

--- Set the geometry of a frame
-- @param self is a frame
-- @param geo is the geometry to set on the frame, if geo is nil nothing is done
-- @return the current geometry
function geometry(self, geo)
    local geo = nil
    return geo
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })
