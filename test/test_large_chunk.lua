local uv   = require"lluv"
local ssl  = require"lluv.ssl"

local ctx = assert(ssl.context{
  protocol    = "tlsv1",
  key         = "./cert/server.key",
  certificate = "./cert/server.crt",
})

local size = tonumber(arg[1]) or 65535

local HOST, PORT = "127.0.0.1", 8881
local str = ('*'):rep(size)

local server_recived = 0

local done
local server = ctx:server()
server:bind(HOST, PORT):listen(function(srv, err)
  if err then return print("Listen error", err) end
  local cli = srv:accept()
  print("New client connection", cli)

  cli:handshake(function(cli, err)
    if err then
      print("Server handshake error:", err)
      return cli:close()
    end
    print(cli, "Server handshake done")

    cli:start_read(function(cli, err, data)
      if err then
        if err:name() ~= 'EOF' then
          print("Client read error:", err)
        end
        return cli:close()
      end
      server_recived = server_recived + #data
      assert(('*'):rep(#data) == data)
      assert(server_recived <= #str)
      if server_recived == #str then
        uv.timer():start(1000, function()
          print('DONE')
          uv.stop()
        end)
      end
    end)
  end)
end)

uv.timer():start(500, function()
  local client = ctx:client()
  client:connect(HOST, PORT, function(cli, err)
    if err then
      print("Client handshake error:", err)
      return cli:close()
    end
    print(cli, "Client handshake done")

    cli:write(str)
  end)
end)

uv.run()
