local ssl = require "lluv.ssl"
local socket = require "lluv.ssl.luasocket"

print("------------------------------------")
print("Module    name: " .. ssl._NAME);
print("Module version: " .. ssl._VERSION);
print("Lua    version: " .. (_G.jit and _G.jit.version or _G._VERSION))
print("------------------------------------")
print("")
