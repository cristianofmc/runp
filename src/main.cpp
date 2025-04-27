#include <iostream>
#include <filesystem>
#include <fstream>
#include <sstream>
#include <vector>
#include <cstdlib>
#include "config.hpp"

namespace fs = std::filesystem;

std::vector<std::string> split(const std::string& str, char delimiter) {
    std::vector<std::string> tokens;
    std::stringstream ss(str);
    std::string token;
    while (getline(ss, token, delimiter)) {
        tokens.push_back(token);
    }
    return tokens;
}

Config loadConfig(const std::string& path) {
    Config config;
    std::ifstream file(path);
    if (!file) {
        // Se o arquivo de configuração não for encontrado, retorna um config vazio
        return config;
    }

    std::string line;
    while (getline(file, line)) {
        if (line.rfind("base_dir=", 0) == 0) {
            config.baseDir = line.substr(9);
        } else if (line.rfind("ignore_dirs=", 0) == 0) {
            config.ignoreDirs = split(line.substr(12), ',');
        }
    }
    return config;
}

bool isIgnored(const std::string& name, const std::vector<std::string>& ignoreList) {
    for (const auto& ignore : ignoreList) {
        if (name == ignore) {
            return true;
        }
    }
    return false;
}


// Não defina main quando estiver rodando os testes
int main(int argc, char** argv) {
    std::string configPath = std::string(getenv("HOME")) + "/.runpconfig";
    Config config = loadConfig(configPath);

    // Caso não haja o arquivo de configuração ou o diretório base não esteja definido
    if (config.baseDir.empty()) {
        std::cout << "Base directory not found in the configuration file." << std::endl;
        
        // Se passar o --use, define o diretório atual como o base
        if (argc == 2 && std::string(argv[1]) == "--use") {
            config.baseDir = std::string(getenv("PWD"));
            std::cout << "Using the current directory (" << config.baseDir << ") as the base." << std::endl;

            // Atualiza o arquivo de configuração com o diretório atual
            std::ofstream configFile(configPath);
            if (configFile.is_open()) {
                configFile << "base_dir=" << config.baseDir << std::endl;
                std::cout << "Configuration file updated at " << configPath << std::endl;
            } else {
                std::cerr << "Unable to update the configuration." << std::endl;
                return 1;
            }
            return 0;  // Sai após o --use
        } else {
            // Caso o arquivo de configuração não exista ou não tenha baseDir, pedimos para o usuário definir
            std::cout << "Please provide the base directory to look for files: ";
            std::cin >> config.baseDir;

            // Cria o arquivo de configuração com o diretório fornecido
            std::ofstream configFile(configPath);
            if (configFile.is_open()) {
                configFile << "base_dir=" << config.baseDir << std::endl;
                std::cout << "New base directory saved in " << configPath << std::endl;
            } else {
                std::cerr << "Unable to save the configuration." << std::endl;
                return 1;
            }
        }
    }

    // Lista os diretórios conforme o diretório base configurado
    if (argc == 1) {
        for (const auto& entry : fs::directory_iterator(config.baseDir)) {
            if (entry.is_directory()) {
                std::string name = entry.path().filename();
                if (!isIgnored(name, config.ignoreDirs)) {
                    std::cout << name << std::endl;
                }
            }
        }
    } else if (argc == 2) {
        std::string targetDir = config.baseDir + "/" + argv[1];
        if (fs::exists(targetDir) && fs::is_directory(targetDir)) {
            std::cout << targetDir << std::endl;
        } else {
            std::cerr << "Directory not found: " << argv[1] << std::endl;
            return 1;
        }
    } else {
        std::cerr << "Usage: runp [directory_name]" << std::endl;
        return 1;
    }

    return 0;
}
