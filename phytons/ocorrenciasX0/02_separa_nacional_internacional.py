def process_output_file(input_file, output_file1, output_file2):
    # Lê o conteúdo do arquivo de saída gerado anteriormente
    with open(input_file, 'r') as file:
        lines = file.readlines()

    # Inicializa listas para armazenar os dados que irão para cada arquivo
    file1_lines = []
    file2_lines = []

    # Processa as linhas e separa o conteúdo conforme necessário
    header = lines[0].strip()  # primeira linha é o header
    codinter = lines[1].strip()  # segunda linha é "codinter"

    file1_lines.append(f"{header},{codinter}\n")  # grava a primeira linha no arquivo 1

    # Loop pelas linhas restantes para separar os valores
    for line in lines[2:]:
        parts = line.strip().split(',')  # quebra cada linha pelos separadores de vírgula

        # Grava as primeiras duas colunas no arquivo 1
        file1_lines.append(f"{parts[0]},{parts[1]}\n")

        # Grava as terceira e segunda colunas no arquivo 2
        file2_lines.append(f"{parts[0]},{parts[2]}\n")

    # Grava o conteúdo formatado no arquivo 1
    with open(output_file1, 'w') as file:
        file.writelines(file1_lines)

    # Grava o conteúdo formatado no arquivo 2
    with open(output_file2, 'w') as file:
        file.writelines(file2_lines)


# Defina os arquivos de entrada e saída
input_file = '01_DEPARA_MASTER_processado.csv'  # arquivo gerado anteriormente
output_file1 = '02_DEPARA_MASTER_nacional.csv'  # primeiro arquivo de saída
output_file2 = '02_DEPARA_MASTER_internacional.csv'  # segundo arquivo de saída

# Processa o arquivo de saída anterior e gera dois novos arquivos
process_output_file(input_file, output_file1, output_file2)
