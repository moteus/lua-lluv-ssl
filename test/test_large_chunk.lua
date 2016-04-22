local uv   = require"lluv"
local ssl  = require"lluv.ssl"

local server_ctx = assert(ssl.context{
  protocol    = "TLSv1_2",
  key         = "./cert/clientAkey.pem",
  certificate = "./cert/clientA.pem",
  verify      = "none",
  options     = {"all", "no_sslv2", "no_sslv3"},
})

local client_ctx = assert(ssl.context{
  protocol    = "TLSv1_2",
  cafile      = "./cert/rootA.pem",
  verify      = {"peer", "fail_if_no_peer_cert"},
  options     = {"all", "no_sslv2", "no_sslv3"},
})

local size = tonumber(arg[1]) or 65535

local HOST, PORT = "127.0.0.1", 8881
local str = ('*'):rep(size)

local server_recived = 0

local done
local server = server_ctx:server()
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

    local function read_cb(cli, err, data)
      if err then
        if err:name() ~= 'EOF' then
          print("Client read error:", err)
        end
        return cli:close()
      end
      cli:stop_read():start_read(read_cb)

      server_recived = server_recived + #data
      assert(('*'):rep(#data) == data)
      
      assert(server_recived <= #str)
      if server_recived == #str then
        uv.timer():start(1000, function()
          print('DONE')
          uv.stop()
        end)
      end
    end
    
    cli:start_read(read_cb)
  end)
end)

uv.timer():start(500, function()
  local client = client_ctx:client()
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
