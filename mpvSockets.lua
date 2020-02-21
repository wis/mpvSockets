-- mpvSockets, one socket per instance, removes socket on exit

local utils = require 'mp.utils'
tempDir = "/tmp"

function join_paths(...)
    local arg={...}
    path = ""
    for i,v in ipairs(arg) do
        path = utils.join_path(path, tostring(v))
    end
    return path;
end

ppid = utils.getpid()
os.execute("mkdir " .. join_paths(tempDir, "mpvSockets") .. " 2>/dev/null")
mp.set_property("options/input-ipc-server", join_paths(tempDir, "mpvSockets", ppid))

function shutdown_handler()
        os.remove(join_paths(tempDir, "mpvSockets", ppid))
end
mp.register_event("shutdown", shutdown_handler)
