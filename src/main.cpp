// src/main.cpp
#include <iostream>
#include <filesystem>
#include <fstream>
#include <cstdlib>
#include <map>
#include <functional>
#include <algorithm>
#include "config.hpp"

namespace fs = std::filesystem;

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------
void ensureConfigFile(const std::string& path) {
    if (!fs::exists(path)) {
        std::ofstream(path).close();
    }
}

void saveSettings(const std::string& path, const Config& s) {
    std::ofstream f(path, std::ios::trunc);
    if (!f) {
        std::cerr << "Erro ao abrir config para escrita: " << path << "\n";
        return;
    }
    if (!s.baseDir.empty())
        f << ConfigKeys::base_dir << '=' << s.baseDir << '\n';

    if (!s.ignoreDirs.empty()) {
        f << ConfigKeys::ignore_dirs << '=';
        for (size_t i = 0; i < s.ignoreDirs.size(); ++i) {
            f << s.ignoreDirs[i]
              << (i + 1 < s.ignoreDirs.size() ? "," : "\n");
        }
    }

    if (!s.version.empty())
        f << ConfigKeys::version_key << '=' << s.version << '\n';
}

void displayHelp() {
    std::cout
        << "Usage: runp [options] [directory]\n"
        << "Options:\n"
        << "  --use [path]       Set base_dir to [path] (or PWD if none)\n"
        << "  --exclude <dir>    Add <dir> to ignore_dirs in config\n"
        << "  --help             Show this help\n\n"
        << "Without options:\n"
        << "  runp               List subdirectories in base_dir\n"
        << "  runp <subdir>      Print path to <subdir>\n";
}

void promptBaseDir(Config& s) {
    std::cout << "Base directory not set. Enter base directory: ";
    std::cin >> s.baseDir;
}

void listSubdirs(const Config& s) {
    for (auto& e : fs::directory_iterator(s.baseDir)) {
        if (!e.is_directory()) continue;
        std::string name = e.path().filename().string();
        bool skip = false;
        for (auto& ig : s.ignoreDirs) {
            if (name == ig) { skip = true; break; }
        }
        if (!skip) std::cout << name << "\n";
    }
}

void showSubdirPath(const std::string& name, const Config& s) {
    fs::path p = fs::path(s.baseDir) / name;
    if (fs::is_directory(p)) {
        std::cout << p.string() << "\n";
    } else {
        std::cerr << "Not found: " << name << "\n";
    }
}

//-----------------------------------------------------------------------------
// Comando -> Handler
//-----------------------------------------------------------------------------

using Handler = std::function<int(int,char**,Config&,const std::string&)>;

// --help
int handleHelp(int, char**, Config&, const std::string&) {
    displayHelp();
    return 0;
}

// --use [path]
int handleUse(int argc, char** argv, Config& s, const std::string& cfgPath) {
    if (argc == 3) {
        s.baseDir = argv[2];
    } else {
        s.baseDir = std::getenv("PWD");
    }
    std::cout << "Setting base_dir to " << s.baseDir << "\n";
    saveSettings(cfgPath, s);
    return 0;
}

int handleExclude(int argc, char** argv, Config& s, const std::string& cfgPath) {
    if (argc != 3) {
        std::cerr << "Usage: runp --exclude <directory>\n";
        return 1;
    }
    std::string dirToIgnore = argv[2];
    if (std::find(s.ignoreDirs.begin(), s.ignoreDirs.end(), dirToIgnore) == s.ignoreDirs.end()) {
        s.ignoreDirs.push_back(dirToIgnore);
        std::cout << "Ignoring directory: " << dirToIgnore << "\n";
        saveSettings(cfgPath, s);
    } else {
        std::cout << "Directory already in ignore list: " << dirToIgnore << "\n";
    }
    return 0;
}

//-----------------------------------------------------------------------------
// main
//-----------------------------------------------------------------------------

int main(int argc, char** argv) {
    std::string cfgPath = std::string(std::getenv("HOME")) + "/.runpconfig";

    ensureConfigFile(cfgPath);

    auto raw = loadConfig(cfgPath);
    Config settings;
    settings.apply(raw);

    std::map<std::string,Handler> handlers = {
        {"--help", handleHelp},
        {"--use",  handleUse},
        {"--exclude", handleExclude}
    };

    if (argc > 1) {
        auto it = handlers.find(argv[1]);
        if (it != handlers.end()) {
            return it->second(argc, argv, settings, cfgPath);
        }
    }

    if (settings.baseDir.empty()) {
        promptBaseDir(settings);
        saveSettings(cfgPath, settings);
    }

    if (argc == 1) {
        listSubdirs(settings);
    }
    else if (argc == 2) {
        showSubdirPath(argv[1], settings);
    }
    else {
        std::cerr << "Usage: runp [options] [directory]\n";
        return 1;
    }

    return 0;
}
