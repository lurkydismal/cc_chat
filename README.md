# cc_chat
A simple chat for my team

# dependencies
Requires conan, cmake and c++ compiler

# compiling
Choose your setup by specifying `BUILD_CLIENT` and/or `BUILD_SERVER`
- When you choose `BUILD_CLIENT`, specify `SERVER_PORT` and `SERVER_HOST`
- When you choose `BUILD_SERVER`, specify `SERVER_PORT`, `MYSQL_PORT`, `MYSQL_HOST`, `MYSQL_DB`, `MYSQL_USER` and `MYSQL_PASSWD`.
```
mkdir build
cd build
cmake .. -DBUILD_CLIENT=YES -DSERVER_PORT=1337 -DSERVER_HOST=localhost
make
make install
```
the binaries will be located at `bin` directory
