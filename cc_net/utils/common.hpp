#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <deque>
#include <mutex>
#include <condition_variable>
#include <chrono>
#include <memory>
#include <thread>
#include <exception>
#include <algorithm>

#ifdef _WIN32
    #define _WIN32_WINNT 0x0601 // banana
#endif

#include <asio.hpp>
#include <asio/ts/buffer.hpp>
#include <asio/ts/internet.hpp>
