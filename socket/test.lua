require 'socket'

print('current time:', socket.gettime())
local host = socket.bind('127.0.0.1', 10101)
local client,err = socket.connect('127.0.0.1', 10102)
if not client then
	print(err)
	return
end
client:send('hoi\nhallo\n')

print('host:', host)
