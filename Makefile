linux: parse.so
deploy: parse.so web/www/
	scp -r web/www/* metamine.nl:/var/www/html/

socket.so: socket/main.c
	cd socket; make
	cp socket/bin/socket.so .
	
run: linux
	lua web/service.lua

test: linux
	luajit test.lua

parse.so: parse/lex.l parse/lang.y parse/lua.c
	cd parse; make linux
	mkdir -p bin
	cp -r parse/bin/* bin/
	ln -sf ../bin/parse.so web/
	ln -sf bin/parse.so .
	ln -sf ../vt bin/
	ln -sf ../doe bin/
	
windows:
	mkdir -p bin
	cd parse; make windows
	cp -r parse/bin/* bin/
	ln -sf ../vt bin/
	ln -sf ../doe bin/


#scp -r web/* pi:/var/www/blog/taal-0.1.1

all:
	mkdir -p bin	
	cd parse; make
	cp -r parse/bin/* bin/

malloc.o: bieb/malloc.c
	cc -c -fPIC -DLACKS_STDLIB_H -DNO_MALLOC_STATS bieb/malloc.c -o bieb/malloc.o

web:
	cd parse; make web
	mkdir -p bin
	cp -r parse/bin/* bin/
	lua2js lex.lua > bin/lex.js
	lua2js lisp.lua > bin/lisp.js

clean:
	rm -rf bin/
	rm -rf web/www/index.html web/www/en web/www/nl web/www/index.*.html

objects := $(patsubst %.lua,%.o,$(wildcard *.lua))

main.o: main.s
	as main.s -o main.o

sources := $(wildcard *.lua)
