def format_string(input_str):
    # Substitui os espaços por quebras de linha
    formatted_str = input_str.replace(' ', '\n')
    return formatted_str


def process_file(input_file, output_file):
    # Lê o conteúdo do arquivo de entrada
    with open(input_file, 'r') as file:
        input_str = file.read().strip()  # Remove espaços em branco ao redor

    # Formata a string
    formatted_str = format_string(input_str)

    # Grava a string formatada no arquivo de saída
    with open(output_file, 'w') as file:
        file.write(formatted_str)


# Defina os arquivos de entrada e saída
input_file = 'DEPARA_MASTER.csv'
output_file = '01_DEPARA_MASTER_processado.csv'

# Processa o arquivo
process_file(input_file, output_file)