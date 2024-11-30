import csv


def load_descriptions(description_file):
    # Carrega as descrições em um dicionário
    description_dict = {}
    with open(description_file, mode='r', newline='', encoding='utf-8') as file:
        reader = csv.reader(file)
        for row in reader:
            code, description = row
            description_dict[code] = description
    return description_dict


def process_codes(input_file, description_dict, output_file):
    # Processa os códigos e busca as descrições para o primeiro código
    with open(input_file, mode='r', newline='', encoding='utf-8') as file, open(output_file, mode='w', newline='',
                                                                                encoding='utf-8') as outfile:
        reader = csv.reader(file)
        writer = csv.writer(outfile)

        for row in reader:
            code1 = row[0].zfill(3)  # Pega o primeiro código e faz o padding com zeros à esquerda para ter 3 dígitos
            code2 = row[1][:2]  # Pega o segundo código e mantém apenas 2 dígitos
            description1 = description_dict.get(code1, 'Descrição não encontrada')  # Busca a descrição do código 1

            # Escreve a linha de saída: código 1, código 2 (2 posições), e descrição 1
            writer.writerow([code1, code2, description1])


# Defina os arquivos de entrada e saída

input_file = '02_DEPARA_MASTER_internacional.csv'  # Arquivo com dois códigos por linha
description_file = 'ocorsx0.csv'  # Arquivo com código e descrição
output_file = '03_codigo_decodificado_nacional.csv'  # Arquivo de saída com códigos e descrições

# Carrega as descrições em um dicionário
description_dict = load_descriptions(description_file)

# Processa os códigos e grava a saída
process_codes(input_file, description_dict, output_file)

print("Processamento concluído. Arquivo de saída gerado.")
