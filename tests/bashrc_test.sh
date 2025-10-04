#!/usr/bin/env bats

setup() {
    # Cria diretórios de teste
    TEST_DIR="$HOME/test_runp_dir"
    mkdir -p "$TEST_DIR/sub1" "$TEST_DIR/sub2"

    # Cria config simulando base_dir
    echo "base_dir=$TEST_DIR" > "$HOME/.runpconfig"

    # Sourcing do código do bashrc
    source ./add_to_bashrc.txt

    # Mock para autocomplete
    _init_completion() { return 0; }
}

teardown() {
    rm -rf "$TEST_DIR"
    rm -f "$HOME/.runpconfig"
}

@test "runp function calls the executable with arguments" {
    run runp --help
    [ "$status" -eq 0 ]
    [[ "$output" == *"Executando o programa runp original com argumentos"* ]]
}

@test "runp with subdir changes directory" {
    pushd /tmp > /dev/null
    runp sub1
    [ "$(pwd)" = "$TEST_DIR/sub1" ]
    popd > /dev/null
}

@test "autocomplete setup sets COMPREPLY" {
    # Simula chamada de autocomplete
    COMP_WORDS=(runp sub1)
    COMP_CWORD=1
    _runp_complete
    [[ "${COMPREPLY[@]}" =~ "sub1" || "${COMPREPLY[@]}" =~ "sub2" ]]
}

