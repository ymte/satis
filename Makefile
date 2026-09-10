linux: parse.so
macos: parse_macos.so

deploy: parse.so web/www/
	scp -r www/* satislang.org:/var/www/

run: linux
	lua service.lua

run_macos: macos
	lua service.lua

parse.so: parse/lex.l parse/lang.y parse/lua.c
	cd parse; make linux
	cp parse/bin/parse.so parse.so

parse_macos.so: parse/lex.l parse/lang.y parse/lua.c
	cd parse; make macos
	cp parse/bin/parse_macos.so parse_macos.so
	cp parse/bin/parse_macos.so parse.so

windows:
	mkdir -p bin
	cd parse; make windows
	cp -r parse/bin/* bin/


#scp -r web/* pi:/var/www/blog/taal-0.1.1

all:
	mkdir -p bin	
	cd parse; make
	cp -r parse/bin/* bin/

malloc.o: bieb/malloc.c
	cc -c -fPIC -DLACKS_STDLIB_H -DNO_MALLOC_STATS bieb/malloc.c -o bieb/malloc.o

clean:
	rm -rf bin/
