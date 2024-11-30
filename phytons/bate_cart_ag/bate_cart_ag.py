import csv

def cruzar_csv(arquivo1, arquivo2, arquivo_saida):
    # Carregar dados do arquivo 1 em um dicionário {chave: [coluna2, coluna3, coluna4]}
    dados_arquivo1 = {}
    with open(arquivo1, 'r') as f1:
        reader1 = csv.reader(f1)
        next(reader1)  # Pular cabeçalho, se houver
        for linha in reader1:
            chave = linha[0]  # Chave é a primeira coluna
            dados_arquivo1[chave] = linha[1:]  # Guardar as colunas 2, 3 e 4

    # Abrir arquivo 2 e criar o arquivo de saída com os dados combinados
    with open(arquivo2, 'r') as f2, open(arquivo_saida, 'w', newline='') as f_saida:
        reader2 = csv.reader(f2)
        writer = csv.writer(f_saida)

        # Ler e escrever o cabeçalho
        cabecalho_arquivo2 = next(reader2)  # Cabeçalho do arquivo 2
        cabecalho_saida = cabecalho_arquivo2 + ['Coluna2_Arq1', 'Coluna3_Arq1', 'Coluna4_Arq1']
        writer.writerow(cabecalho_saida)

        # Processar cada linha do arquivo 2
        for linha in reader2:
            chave = linha[1]  # Chave é a segunda coluna do arquivo 2
            if chave in dados_arquivo1:
                linha_saida = linha + dados_arquivo1[chave]
            else:
                linha_saida = linha + ['', '', '']  # Preencher com vazio se não achar correspondência
            writer.writerow(linha_saida)

    print(f"Arquivo de saída '{arquivo_saida}' criado com sucesso.")

# Exemplo de uso
cruzar_csv('arquivo1.csv', 'arquivo2.csv', 'saida.csv')
