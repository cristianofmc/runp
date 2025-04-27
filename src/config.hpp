// config.hpp
#pragma once
#include <string>
#include <vector>

struct Config {
    std::string baseDir;
    std::vector<std::string> ignoreDirs;
};

Config loadConfig(const std::string& path);
