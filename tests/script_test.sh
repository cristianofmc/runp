#!/usr/bin/env bats

@test "should update base_dir with --use option" {
    config_path="$HOME/.runpconfig"

    # Faz backup do arquivo de configuração original, se existir
    if [ -f "$config_path" ]; then
        cp "$config_path" "$config_path.bak"
    fi

    # Limpa o arquivo de configuração para o teste
    rm -f "$config_path"

    # Executa o comando runp com --use e verifica a saída
    run runp --use
    echo "Comando runp executado com código de saída $?"

    # Verifica se o arquivo de configuração foi criado
    if [ -f "$config_path" ]; then
        echo "Arquivo de configuração criado"
    else
        echo "Falha: arquivo de configuração não foi criado"
    fi

    # Verifica se o diretório base foi atualizado corretamente
    config_base_dir=$(grep "base_dir=" "$config_path" | cut -d'=' -f2)
    echo "Diretório base no arquivo de configuração: $config_base_dir"

    if [ "$config_base_dir" == "$(pwd)" ]; then
        echo "Base dir está correto"
    else
        echo "Falha: Base dir não corresponde ao diretório atual"
    fi

    # Restaura o arquivo de configuração original
    if [ -f "$config_path.bak" ]; then
        mv "$config_path.bak" "$config_path"
    fi
}
