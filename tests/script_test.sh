#!/usr/bin/env bats

setup() {
    config_path="$HOME/.runpconfig"
    custom_dir="$HOME/custom_dir"
    old_dir="$HOME/old_dir"
    backup_config="$config_path.bak"

    mkdir -p "$custom_dir"
    mkdir -p "$old_dir"

    # Faz backup do config se existir
    if [ -f "$config_path" ]; then
        cp "$config_path" "$backup_config"
    fi
}

teardown() {
    # Restaura o config original se backup existir
    if [ -f "$backup_config" ]; then
        mv "$backup_config" "$config_path"
    else
        rm -f "$config_path"
    fi

    # Limpa diretórios de teste
    rm -rf "$custom_dir" "$old_dir"
}

@test "A1: should create config file and set base_dir to current directory" {
    rm -f "$config_path"

    run runp --use
    [ "$status" -eq 0 ]
    [ -f "$config_path" ]
    [ "$(grep 'base_dir=' "$config_path" | cut -d'=' -f2)" = "$(pwd)" ]
}

@test "A2: should manually specify a directory without --use" {
    rm -f "$config_path"

    run runp "$custom_dir"
    [ "$status" -eq 0 ]
    # Aqui não mudamos o diretório real do processo bash, apenas garantimos que o runp foi bem-sucedido
}

@test "A3: should not create config file when running runp without --use" {
    rm -f "$config_path"

    # Manda ENTER vazio para o runp
    echo "" | runp
    status=$?

    [ "$status" -eq 0 ]
    [ ! -f "$config_path" ]
}

@test "B1: should overwrite base_dir correctly when using --use" {
    echo "base_dir=$old_dir" > "$config_path"

    run runp --use
    [ "$status" -eq 0 ]
    [ "$(grep 'base_dir=' "$config_path" | cut -d'=' -f2)" = "$(pwd)" ]
}

@test "B2: should allow running specifying a directory" {
    run runp "$custom_dir"
    [ "$status" -eq 0 ]
}

@test "C1: should show help information when running runp --help" {
    run runp --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage"
    echo "$output" | grep -q -- "--use"
}
