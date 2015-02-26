# lua-lluv-ssl
SSL/TLS sockets for lluv library

###Create SSL context
```Lua
local ctx = ssl.context{ -- LuaSec compatiable table
  protocol = "tlsv1_2", -- ... and other options
  key      =  ...
  cafile   =  ...
  verify   =  ...
  options  =  ...
}
```

###Client
```Lua
local client = ctx:client()

-- Client side do SSL handshake automatically
client:connect("127.0.0.1", 8881, function(cli, err)
  if err then return cli:close() end
  -- work with connection
  ...
end)
```

###Server
```Lua
local server = ctx:server() 

server:bind("127.0.0.1", 8881):listen(function(srv, err)
  if err then return print("Listen error", err) end
  local cli = srv:accept()

  -- call SSL/TLS handshake
  cli:handshake(function(cli, err)
    if err then return cli:close() end
    -- work with connection
    ...
  end)
end)
```

###LuaSocket client
```Lua
ut.corun(function()
  local cli = socket.ssl(ctx)
  cli:connect("127.0.0.1", 8881)
  -- work with connection
  ...
end)
```

###LuaSocket server
```Lua
ut.corun(function()
  local srv = socket.ssl(ctx, true)
  srv:bind("127.0.0.1", 8881)
  while true do
    local cli, err = srv:accept()
    if cli then
      -- work with connection
      ...
    end
  end
end)
```
