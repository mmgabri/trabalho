import csv

def read_csv(file_path):
    """Lê o arquivo CSV e retorna uma lista de dicionários com os dados."""
    try:
        with open(file_path, mode='r', newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            # Imprimir as colunas para depuração
            print(f"Colunas do arquivo '{file_path}': {reader.fieldnames}")
            return list(reader)
    except FileNotFoundError:
        print(f"Erro: O arquivo '{file_path}' não foi encontrado.")
        return []

def write_csv(file_path, data, fieldnames):
    """Escreve os dados no arquivo CSV de saída."""
    try:
        with open(file_path, mode='w', newline='', encoding='utf-8') as csvfile:
            writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
            writer.writeheader()
            writer.writerows(data)
            print(f"Arquivo '{file_path}' gerado com sucesso.")
    except Exception as e:
        print(f"Erro ao escrever no arquivo '{file_path}': {e}")

def merge_files(file1, file2, output_file, key_columns):
    """Combina dois arquivos CSV removendo duplicatas com base nas colunas-chave."""
    # Ler os arquivos CSV
    data1 = read_csv(file1)
    data2 = read_csv(file2)

    if not data1 or not data2:
        print("Erro: Um dos arquivos de entrada está vazio ou não foi lido corretamente.")
        return

    # Criar um conjunto para armazenar as chaves únicas
    unique_records = {}

    # Função para gerar uma chave única com base nas colunas-chave
    def generate_key(row, key_columns):
        return tuple(row[col].strip() for col in key_columns)  # Remover espaços em branco nas chaves

    # Processar o primeiro arquivo
    for row in data1:
        key = generate_key(row, key_columns)
        unique_records[key] = row

    # Processar o segundo arquivo, apenas adicionar se a chave não estiver presente
    for row in data2:
        key = generate_key(row, key_columns)
        if key not in unique_records:
            unique_records[key] = row

    # Preparar os dados únicos para o arquivo de saída
    fieldnames = data1[0].keys()  # Assumindo que ambos os arquivos têm as mesmas colunas
    unique_data = list(unique_records.values())

    # Escrever no arquivo de saída
    write_csv(output_file, unique_data, fieldnames)

if __name__ == "__main__":
    # Arquivos de entrada e de saída
    file1 = 'arq1.csv'  # Substitua pelo caminho do primeiro arquivo CSV
    file2 = 'arq2.csv'  # Substitua pelo caminho do segundo arquivo CSV
    output_file = 'saida.csv'  # Substitua pelo nome desejado para o arquivo de saída
    key_columns = ['coluna1', 'coluna2']  # Substitua pelos nomes das colunas-chaves

    merge_files(file1, file2, output_file, key_columns)
