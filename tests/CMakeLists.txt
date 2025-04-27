cmake_minimum_required(VERSION 3.10)
project(MyTestProject)

# Defina a versão do Google Test ou inclua diretamente o submódulo do Google Test
set(GOOGLETEST_DIR /path/to/googletest)

# Defina a pasta onde seus testes e código estão localizados
add_subdirectory(${GOOGLETEST_DIR} ${CMAKE_BINARY_DIR}/googletest)

# Inclua os diretórios de código fonte
include_directories(${GOOGLETEST_DIR}/googletest/include)

# Adicione os arquivos do seu teste
add_executable(test_executable
    test_config.cpp  # Substitua pelo nome do seu arquivo de teste
)

# Linke o Google Test ao seu código de teste
target_link_libraries(test_executable gtest gtest_main)

# Para rodar os testes, defina o Google Test e o Google Mock como dependências
enable_testing()
add_test(NAME MyTests COMMAND test_executable)
