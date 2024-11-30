import csv


def load_descriptions(description_file):
    # Carrega as descrições do código 2 em um dicionário
    description_dict = {}
    with open(description_file, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        for row in reader:
            code, description = row
            description_dict[code] = description
    return description_dict


def process_output_file_with_code2_description(input_file, description_file, output_file):
    # Carrega as descrições do código 2
    description_dict = load_descriptions(description_file)

    # Lê o arquivo de saída anterior e processa as descrições do código 2
    with open(input_file, mode='r', newline='', encoding='utf-8') as file, open(output_file, mode='w', newline='',
                                                                                encoding='utf-8') as outfile:
        reader = csv.reader(file)
        writer = csv.writer(outfile)

        for row in reader:
            code1, code2, description1 = row  # Lê o código 1, código 2 e descrição 1 da linha
            description2 = description_dict.get(code2, 'Descrição não encontrada')  # Busca a descrição do código 2

            # Grava a linha com a descrição do código 2 adicionada
            writer.writerow([code1, code2, description1, description2])


# Defina os arquivos de entrada e saída
input_file = '03_codigo_decodificado_nacional1.csv'  # Arquivo gerado anteriormente com códigos e descrição do código 1
description_file = 'desc_iso.csv'  # Arquivo com descrições do código 2
output_file = '04_saida_completa_nacional.csv'  # Arquivo de saída com descrições do código 1 e código 2

# Processa o arquivo de saída anterior e adiciona as descrições do código 2
process_output_file_with_code2_description(input_file, description_file, output_file)

print("Processamento concluído. Arquivo de saída gerado com a descrição do código 2.")
