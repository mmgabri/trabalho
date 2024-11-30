import csv


# Função para ler os valores da primeira coluna do arquivo 2 e armazená-los em um set (linha por linha)
def ler_coluna_arquivo_para_set(caminho_arquivo):
    dados_set = set()
    with open(caminho_arquivo, newline='', encoding='utf-8') as csvfile:
        leitor = csv.reader(csvfile)
        for linha in leitor:
            dados_set.add(linha[0])
    return dados_set


# Função para processar o arquivo 1 e verificar os registros que não estão no arquivo 2
def processar_arquivo_e_filtrar(arquivo1, dados_arquivo2, arquivo_saida):
    with open(arquivo1, newline='', encoding='utf-8') as csvfile, open(arquivo_saida, mode='w', newline='',
                                                                       encoding='utf-8') as saida_csv:
        leitor = csv.reader(csvfile)
        escritor = csv.writer(saida_csv)

        for linha in leitor:
            if linha[0] not in dados_arquivo2:  # Verifica se o valor não está no arquivo 2
                escritor.writerow(linha)  # Escreve no arquivo de saída se não estiver no arquivo 2


# Função principal para gerenciar o processo
def cruzar_arquivos(arquivo1, arquivo2, arquivo_saida):
    # Carrega os valores da primeira coluna do arquivo 2 em um set
    dados_arquivo2 = ler_coluna_arquivo_para_set(arquivo2)

    # Processa o arquivo 1 e grava no arquivo de saída os registros que não estão no arquivo 2
    processar_arquivo_e_filtrar(arquivo1, dados_arquivo2, arquivo_saida)
    print(f"Processo concluído. Registros diferentes salvos em {arquivo_saida}")


# Caminhos para os arquivos CSV
arquivo1 = 'arquivo1.csv'
arquivo2 = 'arquivo2.csv'
arquivo_saida = 'saida.csv'

# Executando o batimento
cruzar_arquivos(arquivo1, arquivo2, arquivo_saida)
