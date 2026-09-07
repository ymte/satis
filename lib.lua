require 'exp'
require 'util'

local niets = {}

function lib()
	local inn = {}
	local vars = {}

	-- host, poort → socket
	local sockets = {}
	-- socket → set(socket)
	local clients = {}
	-- socket → int
	local written = {}
	-- read
	local read = {}

	local lib = {

	['html.requestAnimationFrame'] = function(f) requestAnimationFrame(f) end,
	['eval'] = true,
	['icode'] = true,
	['append'] = function(lijst,item) lijst[#lijst] = item; return lijst; end;
	['prepend'] = function(lijst,item) table.insert(lijst, 1, item); return lijst; end;

	['+f1'] = function(args)
		local afunc = args[1]
		local b = args[2]
		return function (x)
			return afunc(x) + b
		end
	end,

	['+v1'] = function(alijst, b)
		local c = {}
		for i,v in ipairs(alijst) do
			c[i] = v + b
		end
		return c
	end,

	['grab'] = function (lijst) return lijst[math.random(1, #lijst)] end,
	-- canvas
	['pad.begin'] = true,
	--['context2d'] = true,
	['canvas.context'] = true,
	['canvas.fillRect'] = true,
	['canvas.clear'] = true,
	['canvas.fontsize'] = true,
	['canvas.linewidth'] = true,
	['canvas.drawImage'] = true,
	['flatten'] = true,
	['jsonencode'] = true,
	['jsondecode'] = true,

	-- webgl
	['alert'] = true,
	['split'] = true,
	['cube'] = true,
	['superrender'] = true,
	['gl.drawArrays'] = true,
	['gl.drawTriangles'] = true,
	['gl.clearColor'] = true,
	['gl.Triangles'] = true,
	['gl.createShader'] = true,
	['gl.attachShader'] = true,
	['gl.linkProgram'] = true,
	['gl.useProgram'] = true,

	['loadimage'] = true,
	['download'] = true,
	['cubemap'] = true,
	['texture'] = true,
	['vertexbuffer'] = true,
	['vertexshader'] = true,
	['fragmentshader'] = true,
	['shaderprogram'] = true,
	['shaderbind'] = true,
	['uniformbind'] = true,
	['matrixbind'] = true,
	['texturebind'] = true,
	['cubemapbind'] = true,

	-- functioneel
	['fn.add'] = function(x) return function(y) return x + y end end; -- fn.plus(3) = x -> x + 3
	['fn.inc'] = function(x) return x + 1 end;
	['fn.dec'] = function(x) return x - 1 end;
	['l.first'] = function(x) return x[1] end;
	['l.second'] = function(x) return x[2] end;
	['l.third'] = function(x) return x[3] end;
	['l.fourth'] = function(x) return x[4] end;
	['fn.merge'] = function(fns)
		return function(x)
			local r = {}
			for i,fn in ipairs(fns) do
				if type(fn) == 'function' then
					r[i] = fn(x)
				else
					r[i] = fn[x+1]
				end
			end
			return r
		end
	end;

	['fn.dup'] = function(x)
		return {x, x}
	end;
	['fn.constant'] = function(x)
		return function()
			return x
		end
	end;
	['fn.curry'] = function(args)
		local fn,x = args[1], args[2]
		return function(y)
			return fn(x,y)
		end
	end;
	['fn.curryL'] = function(args)
		local fn,y = args[1], args[2]
		return function(x)
			return fn(x,y)
		end
	end;

	-- net

	-- host, poort → socket
	['tcp.connect'] = function (args)
		local host,poort = args[1],args[2]
		if not sockets[host] or not sockets[host][poort] then
			local sock = socket.connect(host, poort)
			sock:settimeout(0)
			sockets[host] = socket[host] or {}
			sockets[host][poort] = sock
			written[sock] = 0
			read[sock] = ''
		end
		return sockets[host][poort]
	end;

	-- host, poort → socket
	['tcp.bind'] = function (args)
		local host,poort = args[1],args[2]
		if not sockets[host] or not sockets[host][poort] then
			local sock = socket.bind(host, poort)
			sock:settimeout(0)
			sockets[host] = socket[host] or {}
			sockets[host][poort] = sock
			clients[host] = {}
		end
		return sockets[host][poort]
	end;

	-- socket → set(socket)
	['tcp.accept'] = function(sock)
		clients[sock] = clients[sock] or {}
		while true do
			local client = sock:accept()
			if client then
				client:settimeout(0)
				table.insert(clients[sock], client)
			else
				break
			end
		end
		return clients[sock]
	end;
			
	-- socket, data → socket
	['tcp.write'] = function(args)
		local sock, data = args[1], args[2]
		local n = written[sock] or 0
		if type(data) == 'table' then
			data = string.char(table.unpack(data))
		end
		if #data > n then
			local w = sock:send(data, n+1)
			if not tonumber(w) then
				return
			end
			written[sock] = w
		end
		return written[sock]
	end;

	-- socket → data
	['tcp.read'] = function(sock)
		read[sock] = read[sock] or ''
		local data = sock:receive()
		if data then
			read[sock] = read[sock] .. data
		end
		return read[sock]
	end;
		
	['⊤'] = true,
	['sort'] = function (a) return table.sort(a[0], a[1]) end,
	['⊥'] = false,
	['log2'] = function (a) return math.log(a, 2) end,
	['log10'] = math.log10,
	['τ'] = math.pi*2,
	['∅'] = {},
	['π'] = math.pi,
	['error'] = true,
	['paint'] = true,

	rgb = true,

	polygon = function() return('polygoon') end;
	square = function() return('vierkant') end;
	arc = function() return('boog') end;
	label = function() return('label') end;
	rectangle = function() return('rechthoek') end;
	image = function() return('rechthoek') end;
	circle = function() return('cirkel') end;
	ellipse = function() return('ovaal') end;
	line = function() return('lijn') end;

	['_'] = function(a, b)
		if type(a) == 'string' then
			return a:byte(b+1)
		elseif type(a) == 'table' then
			return a[b+1]
		elseif type(a) == 'function' then
			return a(b)
		else
			return a
		end
	end;

	['index'] = function(a, b)
		return a[b+1]
	end;
	['index0'] = function(a)
		return a[0]
	end;

	['_t'] = function(a, b)
		return a:byte(b)
	end;

	['call'] = function(a, b) return a(b) end;
	['call2'] = function(f, a, b) return f(a, b) end;
	['call3'] = function(f, a, b, c) return f(a, b, c) end;

	-- io
	['stdout.write'] = function(a)
		do
			io.write(deparse(w2exp(a)))
			io.flush()
			return true
		end
		if type(a) == 'table' and #a > 1 then
			local txt = true
			for i,v in ipairs(a) do
				if type(v) == 'number' and v % 1 == 0 and v > 0 then
					-- goed
				else
					txt = false
					break
				end
			end
			if txt then
				io.write(string.char(table.unpack(a)))
				return 0
			end
		end
			
		if opt and opt.L then print() end;
		io.write(deparse(w2exp(a)))
		return 0
	end,

	syscall = function(a) error 'SYSCALL' end, 
	xcb_connect = true,

	-- wiskunde
	atom = function(id) return setmetatable({id=id}, {__tostring=function()return 'atom'..id end}) end,
	['call1'] = function(a, b) return a(b) end;
	['min'] = math.min,
	['max'] = math.max,
	maxindexXXX = function(args)
		if #args == 0 then
			return nil
		end
		local maxi = 1
		local max = args[1]
		for i = 1, #args do
			if args[i] > max then
				maxi = i
			end
		end
		return maxi
	end;
		
	int = math.floor,
	abs = math.abs,
	absd = math.abs,
	absi = math.abs,
	ceil = math.ceil,
	['newindex'] = function(args)
		local t,k,v = args[1], args[2], args[3]
		t[k] = v
		return v
	end,
	['newindex2'] = function(args)
		local t,k,v = args[1], args[2], args[3]
		t[k] = v
		-- TODO copy
		return v
	end,
	['invert'] = true; -- sure
	['sqrt'] = math.sqrt;
	['nothing'] = false;
	['min'] = math.min;
	['mod'] = function(a, b) return a % b end;

	['¬'] = function(b)
		return not b
	end;

	['!'] = function(n)
		local a = 1
		for i=1,n do
			a = a * i
		end
		return a
	end;

	['^l'] = function(f, n)
		local r = {}
		local k = 1
		for i = 1, n do
			for j = 1, #f do
				r[k] = f[j]
				k = k + 1
			end
		end
		return r
	end;

	['^f'] = function(f, n)
		return function(x)
			local r = x
			for i = 1, n do
				r = f(r)
			end
			return r
		end
	end;

	['!'] = function(n)
		local a = 1
		for i=1,n do
			a = a * i
		end
		return a
	end;
	-- linksassociatief
	-- cartesisch product
	['×'] = function(a)
		local a,b = a[1],a[2]
		local t = {}
		for i,aa in ipairs(a) do
			for i,bb in ipairs(b) do
				t[#t+1] = setmetatable({aa, bb}, getmetatable(a))
			end
		end
		setmetatable(t, listmeta)
		return t
	end;
			
	['+'] = function(a,b) return a + b end;
	['-'] = function(a) return -a end;
	['·'] = function(a,b) return a * b end;
	['/'] = function(a,b) return a / b end;
	['√'] = function(a) return math.sqrt(a) end;
	['²'] = function(a) return a * a end;
	['%'] = function(a) return a / 100 end;

	['^'] = function(a, b)
		if type(a) == 'function' then
			return function (x)
				for i=1,b do
					x = a(x)
				end
				return x
			end
		else
			return a ^ b
		end
	end;

	['parse'] = function(a)
		--local code = string.char(table.unpack(a))
		local code = a
		local data = parse(code)
		return data
	end;

	['solve'] = function(exp)
		local obj = solve(exp)
		return function(k)
			return obj[string.char(table.unpack(k))]
		end
	end;

	['do'] = function(exp)
		return doe0(exp)
	end;

	-- compose
	['compose'] = function(fns)
		return function(x)
			for i, fn in ipairs(fns) do
				--print('TUSSENRESULTAAT', lenc(x))
				x = fn(x)
			end
			return x
		end
	end;
	['∘'] = function(a, b)
		return function(x)
			return b(a(x))
		end
	end;

	['|'] = function(a)
		for i,v in ipairs(a) do
			print('alt', v)
			if v ~= false then
				return v
			end
		end
		assert(false, 'geen geldige optie uit '..lenc(a))
	end;

	['→'] = function(param, f)
		return function(a)
			return doe(substitute(f, param, a))
		end
	end;

	['coproduct'] = function(f,g)
		return function(...)
			return f(...) or g(...)
		end
	end;

	['#'] = function(a) return #a end;
	['='] = function(a, b)
		if tonumber(a) and tonumber(b) then
			return a == b
		end
		return lenc(a) == lenc(b)
	end;
	['=g'] = function(a, b)
		return a == b
	end;
	['>'] = function(a, b) return a > b end;
	['<'] = function(a, b) return a < b end;
	['≠'] = function(a, b) return a ~= b end;
	['≈'] = function(a, b) return math.abs(a-b) < 1e-7 end;

	['..'] = function(a, b)
		local r = {}
		if a > b then
			for i=a-1,b,-1 do
				r[#r+1] = i
			end
		elseif a == b then
			return {}
		else
			for i=a,b-1 do
				r[#r+1] = i
			end
		end
		setmetatable(r, listmeta)
		return r
	end;

	-- concatenate
	['‖'] = function(a, b)
		if type(a) == 'string' or type(b) == 'string' then
			if type(b) == 'table' then
				return a .. string.char(table.unpack(b))
			elseif type(a) == 'table' then
				return string.char(table.unpack(a)) .. b
			else
				return tostring(a) .. b
			end
		end
		local j = 1
		local t = {f='[]'}
		--if isatom(a) then a = {a} end
		--if isatom(b) then b = {b} end
		for i,v in ipairs(a) do t[j] = v; j=j+1 end
		for i,v in ipairs(b) do t[j] = v; j=j+1 end
		setmetatable(t, listmeta)
		return t
	end;

	['‖u'] = function(a)
		local a,b = a[1], a[2]
		return a .. b
	end;

	['catu'] = function(t)
		return table.concat(t)
	end;

	-- lib
	['cat'] = function(a,b)
		local r = {f='[]'}
		for i,v in ipairs(a) do
			for i,v in ipairs(v) do
				r[#r+1] = v
			end
			if b and i ~= #a then
				for i,b in ipairs(b) do
					r[#r+1] = b
				end
			end
		end
		setmetatable(r, listmeta)
		return r
	end;

	['clock'] = function(f)
		local voor = socket.gettime()
		f()
		local na = socket.gettime()
		local dt = math.floor((na - voor) * 1000)
		return dt
	end;

	['for'] = function(a)
		local max,start,filter1,map,filter2,reduce = a[1],a[2],a[3],a[4],a[5],a[6]
		local val = start

		if type(max) == 'table' then
			if #max == 2 then
				for i=0,max[1]-1 do
					for j=0,max[2]-1 do
						if filter1{i,j} then
							val = reduce{val, map{i,j}}
						end
					end
				end
			elseif #max == 3 then
				for i=0,max[1]-1 do
					for j=0,max[2]-1 do
						for k=0,max[3]-1 do
							if filter1{i,j,k} then
								val = reduce{val,map{i,j,k}}
							end
						end
					end
				end
			end
		else
			for i=0,max-1 do
				if filter1(i) then
					val = reduce{val,map(i)}
				end
			end
		end
		return val
	end;

	['lfor'] = function(a)
		local max,filter1,map,filter2 = a[1],a[2],a[3],a[4]
		local val = {}
		if type(max) == 'table' then
			local index = 0
			if #max == 2 then
				for i=0,max[1]-1 do
					for j=0,max[2]-1 do
						if filter1{i,j} then
							val[k] = map{i,j}
							if not filter2{i, j} then
								val[index] = nil
							end
						end
						index = index + 1
					end
				end
			elseif #max == 3 then
				for i=0,max[1]-1 do
					for j=0,max[2]-1 do
						for k=0,max[3]-1 do
							if filter1{i,j,k} then
								val[index] = map{i,j,k}
								index = index + 1
							end
						end
					end
				end
			else
				error'NEE'
			end
		else
			for i=0,max-1 do
				val[i] = map(i)
			end
		end
		return val
	end;

	['reverse'] = function(a)
		local r = {}
		for i=#a,1,-1 do
			r[#r+1] = a[i]
		end
		return r
	end;

	['zip'] = function(a, b)
		local v = {}
		for i=#a,1,-1 do
			v[i] = {a[i], b[i]}
		end
		return v
	end;

	['zip1'] = function(a, b)
		local v = {}
		for i=#a,1,-1 do
			v[i] = {a[i], b}
		end
		return v
	end;

	['rzip1'] = function(a, b)
		local v = {}
		for i=#b,1,-1 do
			v[i] = {a, b[i]}
		end
		return v
	end;

	['map4'] = function(a, b)
		local r = {}
		for i=1,#a do
			r[i] = b(table.unpack(a[i]))
		end
		return r
	end;


	['map'] = function(a, b)
		local r = {}
		for i=1,#a do
			r[i] = b(a[i])
		end
		return r
	end;

	['lmap'] = function(a, b)
		local r = {}
		for i=1,#a do
			r[i] = b[a[i]+1]
		end
		return r
	end;

	['filter4'] = true,
	['filter'] = function(l, fn)
		local r = {}
		for i,v in ipairs(l) do
			if fn(v) then
				r[#r+1] = v
			end
		end
		return r
	end;

	['fold'] = function(lijst, func)
		local r = lijst[1]
		local k = 1
		for i=2,#lijst do
			r = func(r, lijst[i])
		end
		return r
	end;

	['reduce'] = function(init, lijst, func)
		local k = 1
		for i=1,#lijst do
			init = func(init, lijst[i])
		end
		return init
	end;

	-- trig
	['sin'] = math.sin;
	['asin'] = math.asin;
	['cos'] = math.cos;
	['acos'] = math.acos;
	['tan'] = math.tan;
	['atan'] = function(a)
		if type(a) == 'table'  then return math.atan2(a[1], a[2])
			else return math.atan(a)
		end
	end;
	['sincos'] = function (a)
		return {f=',', math.sin(a), math.cos(a)}
	end;
	['cossin'] = function (a)
		return {f=',', math.cos(a), math.sin(a)}
	end;

	['∨'] = function(a,b) return a or b end;
	['∧'] = function(a,b) return a and b end;
	['⋁'] = function(a,b) return a or b end;
	['⋀'] = function(a,b) return a and b end;

	['Σ'] = function(a)
		local r = 0
		for i,v in ipairs(a) do
			r = r + v
		end
		return r
	end;

	-- herhaal functie totdat geen resultaat
	['repeat'] = function(f)
		return function(a)
			local r = a
			while a do
				r = a
				a = f(a)
			end
			return r
		end
	end;

	-- while loop
	['while'] = function(a)
		local init,cond,update = a[1],a[2],a[3]
		local x = init
		while cond(x) do
			x = update(x)
		end
		return x
	end;

	['write'] = function(a) io.write(ansi.wisregel, ansi.regelbegin) ; io.write(a, '  '); io.flush() ; return a ; end;

	['text'] = lenc,

	['number'] = function(a)
		return tonumber(string.char(table.unpack(a)))
	end;

	['floor'] = math.floor;
	['ceil'] = math.ceil;
	['round'] = function(a) return math.floor(a+0.5) end;

	['int'] = function(a)
		if tonumber(a) then
			return math.floor(a)
		end
		local getal = tonumber(string.char(table.unpack(a)))
		if not getal then return false end
		return math.floor(getal)
	end;

	['digit0'] = function(a)
		--return not not (tonumber(a) and #tostring(a) == 1)
		a = tonumber(a)
		return 48 <= a and a <= 57
	end;

	['split'] = function(a,b)
		local r = {}
		local t = {}
		for i,v in ipairs(a) do
			if v == b then
				r[#r+1] = t
				t = {}
			else
				t[#t+1] = v
			end
		end
		return r
	end;

	-- intersectie
	['∩'] = function(ab)
		local a,b = ab[1],ab[2]
		local s = {}
		for v in pairs(a) do if b[v] then s[v] = true end end
		return s
	end;

	-- unie
	['∪'] = function(a, b)
		local s = {}
		for v in pairs(a) do s[v] = true end
		for v in pairs(b) do s[v] = true end
		return s
	end;

	-- lidmaatschap
	['∈'] = function(a)
		return not not a[2][a[1]]
	end;

	-- set verschil
	['\\'] = function(ab)
		local a,b = ab[1],ab[2]
		local r = {}
		for k in pairs(a) do
			if not b[k] then
				r[k] = true
			end
		end
		return r
	end;

	-- aux
	['net-adress'] = function(a)
		local socket = require 'socket'
		local ip = string.char(table.unpack(a))
		return table.pack(ip:match('([^:]*):(.*)'))
  end;
	['file-in'] = function(name)
		local name = string.char(table.unpack(name))
		local bestand = io.open(name, 'r')
		_G.print('OPEN '..name)
		return {fd = bestand, buf = false}
	end;
	['file'] = function(name)
		return file(name)
	end;
	['can-read'] = function(b)
		if not b.buf then b.buf = b.fd:read(1024) end
		return b.buf
	end;

	['⇒'] = function(x)
		if x[1] then
			return x[2]
		else
			return false
		end
	end;

	-- text
	['find'] = function(a,b)
		for i=1,#a-#b+1 do
			local gevonden = true
			for j=i,i+#b-1 do
				if a[j] ~= b[j-i+1] then
					gevonden = false
					break
				end
			end
			if gevonden then
				return i-1
			end
		end
		return false
	end;

	['find2'] = function(a,b)
		for i=1,#a-#b+1 do
			local gevonden = true
			for j=i,i+#b-1 do
				if a[j] ~= b[j-i+1] then
					gevonden = false
					break
				end
			end
			if gevonden then
				return i-1
			end
		end
		return false
	end;

	['from'] = function(a,van)
		local t = {f='[]'}
		for i=van+1,#a do
			t[#t+1] = a[i]
		end
		return t
	end;

	['"'] = function(a)
		local t = string.char(table.unpack(a))
		return t
	end;

	['until'] = function(args)
		local t, tot = args[1], args[2]
		local t = {f='[]'}
		for i=1,tot do
			t[#t+1] = a[i]
		end
		return t
	end;

	['until2'] = function(args)
		local t = {f='[]'}
		for i=1,tot do
			t[#t+1] = a[i]
		end
		return t
	end;

	['slice'] = function(a,b,c)
		local van,tot = b, c
		local t = {f='[]'}
		for i=van+1,tot do
			t[#t+1] = a[i]
		end
		return t
	end;

	['random'] = function(a, b)
		return math.random(a, b-1)
	end;

	['recursive'] = function(rec)
		-- rec: zelf → (w → zelf(w))

		-- recf: volledig recursieve functie
		local recf = rec(rec)
		return recf

		--return function(waarde)
			--return doe(substitute(rec, param, a))
	end;
	}

	return lib

end
