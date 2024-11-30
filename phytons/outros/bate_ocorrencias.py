import csv


def pad_column(value, length):
    """Preenche com zeros à esquerda até atingir o tamanho especificado."""
    return str(value).zfill(length)


def batimento_csv(file1, file2, output_file):
    # Lendo o arquivo 1
    with open(file1, 'r') as f1, open(file2, 'r') as f2, open(output_file, 'w', newline='') as out_file:
        reader1 = csv.reader(f1)
        reader2 = csv.reader(f2)
        writer = csv.writer(out_file)

        # Lendo o conteúdo do arquivo 2 e ajustando a primeira coluna
        data2 = {(pad_column(row[0], 3), row[1]): row for row in reader2}

        # Processando o arquivo 1 e fazendo o batimento
        for row1 in reader1:
            key1 = (row1[0], row1[1])  # Chave baseada nas duas primeiras colunas do arquivo 1
            if key1 in data2:
                writer.writerow(row1)  # Gravando no arquivo de saída os dados do arquivo 1


# Exemplo de uso
file1 = 'arquivo1.csv'
file2 = 'arquivo2.csv'
output_file = 'arquivo_saida.csv'

batimento_csv(file1, file2, output_file)
