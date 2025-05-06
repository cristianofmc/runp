#pragma once

#include <string>
#include <vector>
#include <map>
#include <fstream>
#include <sstream>

//-----------------------------------------------------------------------------
// Configuration keys (match these to entries in the config file)
//----------------------------------------------------------------------------- 
namespace ConfigKeys {
    constexpr char base_dir[]    = "base_dir";
    constexpr char ignore_dirs[] = "ignore_dirs";
    constexpr char version_key[] = "version";
    // Add new keys here as needed
}

//-----------------------------------------------------------------------------
// Utility: split a comma-separated string into a vector
//----------------------------------------------------------------------------- 
inline std::vector<std::string> split(const std::string& s, char delim = ',') {
    std::vector<std::string> parts;
    std::stringstream ss(s);
    std::string item;
    while (std::getline(ss, item, delim)) {
        parts.push_back(item);
    }
    return parts;
}

//-----------------------------------------------------------------------------
// Config: holds all loaded settings
//----------------------------------------------------------------------------- 
struct Config {
    std::string             baseDir;
    std::vector<std::string> ignoreDirs;
    std::string             version;

    // Apply a map of raw settings into this struct
    void apply(const std::map<std::string, std::string>& m) {
        for (const auto& kv : m) {
            const auto& key = kv.first;
            const auto& val = kv.second;

            if (key == ConfigKeys::base_dir) {
                baseDir = val;
            }
            else if (key == ConfigKeys::ignore_dirs) {
                ignoreDirs = split(val);
            }
            else if (key == ConfigKeys::version_key) {
                version = val;
            }
            // add more keys here in the same pattern
        }
    }
};

//-----------------------------------------------------------------------------
// Load a simple key=value config file into a map
//----------------------------------------------------------------------------- 
inline std::map<std::string, std::string> loadConfig(const std::string& path) {
    std::map<std::string, std::string> result;
    std::ifstream file(path);
    if (!file) return result;
    std::string line;
    while (std::getline(file, line)) {
        auto pos = line.find('=');
        if (pos == std::string::npos) continue;
        auto key = line.substr(0, pos);
        auto val = line.substr(pos + 1);
        result[key] = val;
    }
    return result;
}