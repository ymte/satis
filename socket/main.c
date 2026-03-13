#define _POSIX_C_SOURCE 199309L
#ifdef _WIN32 //defined(_MSC_VER)
	#define EXPORT __declspec(dllexport)
	#define IMPORT __declspec(dllimport)
#elif defined(__GNUC__)
	#define EXPORT __attribute__((visibility("default")))
	#define IMPORT
#else
	#define EXPORT
	#define IMPORT
	#pragma warning Hoe te exporteren?
#endif


#include <lua.h>
#include <lauxlib.h>

#include <sys/select.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/time.h>
#include <math.h>
#include <unistd.h>
#include <string.h>

#define max(x, y) (((x) > (y)) ? (x) : (y))
#define min(x, y) (((x) < (y)) ? (x) : (y))


// meta
int socket_tostring(lua_State* L) {
	int sock = *(int*) luaL_checkudata(L, 1, "socket");
	lua_pushfstring(L, "socket %d", sock);
	return 1;
}

int socket_gc(lua_State* L) {
	int sock = *(int*) luaL_checkudata(L, 1, "socket");
	close(sock);
	return 0;
}

int socket_accept(lua_State* L) {
	int server = *(int*) luaL_checkudata(L, 1, "socket");
	int client = accept(server, 0, 0);

	int* luaclient = lua_newuserdata(L, sizeof(int));
	*luaclient = client;

	luaL_setmetatable(L, "socket");

	return 1;
}

int socket_send(lua_State* L)
{
	int server = *(int*) luaL_checkudata(L, 1, "socket");
	size_t size;
	const char* data = luaL_checklstring(L, 2, &size);
	int sent = send(server, data, size, 0);
	lua_pushinteger(L, sent);
	return 1;
}

int socket_receive(lua_State* L)
{
	int socket = *(int*) luaL_checkudata(L, 1, "socket");
	if (lua_isinteger(L, 2))
	{
		puts("RECEIVING CERTAIN AMOUNT");
		int length = lua_tointeger(L, 2);
		char buf[length+1];
		int got = recv(socket, buf, length, 0);
		if (got == -1)
			return luaL_error(L, "error: recv");
		if (got == 0)
			return 0;
		buf[got] = 0;
		lua_pushstring(L, buf);
		return 1;
	}
	else if (lua_isstring(L, 2) && !strcmp("*l", lua_tostring(L, 2)))
	{
		char buf[40*1024];
		char* cur = buf;
		while (1)
		{
			int len = recv(socket, cur, 1, 0);
			if (len == 0 || len == -1)
				return 0;
			if (*cur == '\r')
				continue;
			if (*cur == '\n')
				break;
			cur++;
		}
		*cur = 0;
		//printf("received [[%s]]\n", buf);
		lua_pushstring(L, buf);
		return 1;
	}
	else
	{
		return luaL_error(L, "invalid argument to socket:receive");
	}
}

int socket_close(lua_State* L)
{
	int socket = *(int*) luaL_checkudata(L, 1, "socket");
	close(socket);
	return 0;
}

int socket_gettime(lua_State* L)
{
	struct timeval tv;
	gettimeofday(&tv, NULL);
	long long ms = tv.tv_sec * 1000 + tv.tv_usec / 1000;
	lua_pushinteger(L, ms);
	return 1;
}

int socket_connect(lua_State* L)
{
	size_t len;
	const char* host = luaL_checklstring(L, -2, &len);
	int port = luaL_checkinteger(L, -1);

	int sock = socket(AF_INET, SOCK_STREAM, 0);
	struct in_addr inp;
	inet_pton(AF_INET, host, &inp);
	struct sockaddr_in addr;
	addr.sin_family = AF_INET;
	addr.sin_port = port;
	addr.sin_addr = inp;
	int res = connect(sock, (struct sockaddr*) &addr, sizeof addr);
	if (res == -1)
	{
		lua_pushnil(L);
		lua_pushstring(L, "error: connect");
		return 2;
	}

	int* luasock = lua_newuserdata(L, sizeof(int));
	*luasock = sock;

	luaL_getmetatable(L, "socket");
	lua_setmetatable(L, -2);
	return 1;
}

int socket_bind(lua_State* L) {
	const char* ip = luaL_checkstring(L, 1);
	int port = luaL_checkinteger(L, 2);

	int sock = socket(AF_INET, SOCK_STREAM, 0);

	struct sockaddr_in address;
	address.sin_family = AF_INET;
	address.sin_port = htons(port);
	inet_pton(AF_INET, ip, &address.sin_addr);

	int error = bind(sock, (struct sockaddr*) &address, sizeof address);

	if (error)
	{
		close(sock);
		return luaL_error(L, "bind to port %d failed", port);
	}

	int* luasock = lua_newuserdata(L, sizeof(int));
	*luasock = sock;

	listen(sock, 99);

	luaL_getmetatable(L, "socket");
	lua_setmetatable(L, -2);

	return 1;
}

int socket_select(lua_State* L) {
	int nfds = 0;
	fd_set read;
	fd_set write;
	struct timeval time;

	FD_ZERO(&read);
	FD_ZERO(&write);
	struct timeval* ptime = 0;

	int reading[1024];
	int numreading = 0;
	int writing[1024];
	int numwriting = 0;

	// read
	if (!lua_isnil(L, 1))
	{
		luaL_checktype(L, 1, LUA_TTABLE);

		lua_len(L, 1);
		int len = lua_tointeger(L, -1);
		lua_pop(L, 1);

		for (int i = 0; i < len; i++)
		{
			lua_geti(L, 1, i+1);
			if (luaL_testudata(L, -1, "socket"))
			{
				int sock = *(int*) lua_touserdata(L, -1);
				FD_SET(sock, &read);
				reading[numreading++] = sock;
				nfds = max(sock+1, nfds);
			}
			else
			{
				return luaL_error(L, "non-socket (%s) in read table", lua_tostring(L, 2));
			}
		}
		lua_pop(L, 1);
	}

	// write
	if (!lua_isnil(L, 2))
	{
		luaL_checktype(L, 2, LUA_TTABLE);

		lua_len(L, 2);
		int len = lua_tointeger(L, -1);
		lua_pop(L, 1);

		for (int i = 0; i < len; i++)
		{
			lua_geti(L, 2, i+1);
			if (luaL_testudata(L, -1, "socket"))
			{
				int sock = *(int*) lua_touserdata(L, -1);
				FD_SET(sock, &read);
				writing[numwriting++] = sock;
				nfds = max(sock+1, nfds);
			}
			else
			{
				return luaL_error(L, "non-socket (%s) in write table", lua_tostring(L, 2));
			}
		}
		lua_pop(L, 1);
	}

	// time
	if (!lua_isnil(L, 3)) {
		ptime = &time;
		time.tv_sec = luaL_checknumber(L, 3);
		time.tv_usec = fmod(luaL_checknumber(L, 3), 1.0) / 1e6;
	}

	// daar is ie dan
	select(nfds, &read, &write, 0, ptime);

	// deel 2: extract
	lua_newtable(L);
	int index = 1;
	for (int i = 0; i < numreading; i++)
		if (FD_ISSET(reading[i], &read))
		{
			// stack: [r w t R]
			lua_pushinteger(L, i+1); // stack: [r w t R i]
			lua_gettable(L, 1); // stack: [r w t R s]
			lua_rawseti(L, -2, index++);
		}

	lua_newtable(L);
	index = 1;
	for (int i = 0; i < numwriting; i++)
		if (FD_ISSET(writing[i], &write))
		{
			lua_pushinteger(L, i+1);
			lua_gettable(L, 2);
			lua_rawseti(L, -2, index++);
		}

	return 2;
}

EXPORT int luaopen_socket(lua_State* L) {
	// static socket funcs
	luaL_Reg funcs[] = {
		{"bind",   socket_bind },
		{"select", socket_select },
		{"gettime", socket_gettime },
		{"connect", socket_connect },
		{ 0, 0 },
	};
	luaL_newlib(L, funcs);
	lua_setglobal(L, "socket");

	// socket index
	luaL_Reg index[] = {
		{"accept", socket_accept},
		{"receive", socket_receive},
		{"send", socket_send},
		{"close", socket_close},
		{0, 0},
	};

	// socket meta
	luaL_Reg meta[] = {
		{"__gc", socket_gc },
		{"__tostring", socket_tostring },
		{0, 0},
	};
	luaL_newmetatable(L, "socket");
	luaL_setfuncs(L, meta, 0);
	
	luaL_newlib(L, index);
	lua_setfield(L, -2, "__index");

	return 0;
}
