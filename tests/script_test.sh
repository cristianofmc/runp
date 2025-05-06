#!/usr/bin/env bats

setup() {
    config_path="$HOME/.runpconfig"
    custom_dir="$HOME/test_runp_dir"
    old_dir="$HOME/old_dir"
    backup_config="$config_path.bak"

    mkdir -p "$custom_dir/subdir1"
    mkdir -p "$custom_dir/subdir2"
    mkdir -p "$old_dir"


    echo "base_dir=$custom_dir" > "$config_path"


    if [ -f "$config_path" ]; then
        cp "$config_path" "$backup_config"
    fi
}

teardown() {
    if [ -f "$backup_config" ]; then
        mv "$backup_config" "$config_path"
    else
        rm -f "$config_path"
    fi

    rm -rf "$custom_dir" "$old_dir"
}

@test "A1: should create config file and set base_dir to current directory" {
    rm -f "$config_path"

    run runp --use
    [ "$status" -eq 0 ]
    [ -f "$config_path" ]
    [ "$(grep 'base_dir=' "$config_path" | cut -d'=' -f2)" = "$(pwd)" ]
}

@test "A2: should user directory from parameter when using --use" {
    echo "base_dir=$old_dir" > "$config_path"

    run runp --use /home
    [ "$status" -eq 0 ]
    [ "$(grep 'base_dir=' "$config_path" | cut -d'=' -f2)" = "/home" ]
}

@test "B1: should overwrite base_dir correctly when using --use" {
    echo "base_dir=$old_dir" > "$config_path"

    run runp --use
    [ "$status" -eq 0 ]
    [ "$(grep 'base_dir=' "$config_path" | cut -d'=' -f2)" = "$(pwd)" ]
}

@test "B2: should run runp alone, get a subdirectory, and then run runp with that subdirectory" {
    echo "base_dir=$custom_dir" > "$config_path"

    run runp
    [ "$status" -eq 0 ]
    output_lines=($(echo "$output" | grep -v "Executando"))
    [ "${#output_lines[@]}" -gt 0 ]

    first_subdir="${output_lines[0]}"

    run runp "$first_subdir"
    [ "$status" -eq 0 ]

    [[ "$output" == *"$first_subdir" ]]
}

@test "C1: should show help information when running runp --help" {
    run runp --help
    [ "$status" -eq 0 ]
    echo "$output" | grep -q "Usage"
    echo "$output" | grep -q -- "--use"
}

@test "D1: should add a directory to ignore list using --exclude" {
    rm -f "$config_path"
    echo "base_dir=$custom_dir" > "$config_path"

    run runp --exclude subdir1
    [ "$status" -eq 0 ]
    [ "$(grep 'ignore_dirs=' "$config_path" | cut -d'=' -f2)" = "subdir1" ]

    run runp
    [ "$status" -eq 0 ]
    [[ "$output" != *"subdir1"* ]]
}

@test "D2: should add multiple directories to ignore list using --exclude" {
    rm -f "$config_path"
    echo "base_dir=$custom_dir" > "$config_path"

    run runp --exclude subdir1
    run runp --exclude subdir2
    [ "$status" -eq 0 ]
    [ "$(grep 'ignore_dirs=' "$config_path" | cut -d'=' -f2)" = "subdir1,subdir2" ]

    run runp
    [ "$status" -eq 0 ]
    [[ "$output" != *"subdir1"* ]]
    [[ "$output" != *"subdir2"* ]]
}

