-- mpvSockets, one socket per instance, removes socket on exit

local utils = require 'mp.utils'

local function getTempPath()
    local directorySeperator = package.config:match("([^\n]*)\n?")
    local exampleTempFilePath = os.tmpname()

    -- remove generated temp file
    pcall(os.remove, exampleTempFilePath)

    local seperatorIdx = exampleTempFilePath:reverse():find(directorySeperator)
    local tempPathStringLength = #exampleTempFilePath - seperatorIdx

    return exampleTempFilePath:sub(1, tempPathStringLength)
end

tempDir = getTempPath()

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
