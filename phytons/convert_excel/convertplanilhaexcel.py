import pandas as pd

# Caminho do arquivo Excel
arquivo_excel = "sua_planilha.xlsx"  # Substitua pelo nome do arquivo

# Ler a planilha Excel
df = pd.read_excel(arquivo_excel)

# Caminho do arquivo de saída
arquivo_saida = "resultado.txt"

# Abrir o arquivo de saída
with open(arquivo_saida, "w", encoding="utf-8") as f:
    # Iterar sobre as linhas do DataFrame e criar a tabela no formato desejado
    for index, row in df.iterrows():
        tabela = f"""
+---------------+-------------------+
| Responsavel   | {row['Responsavel']} |
+---------------+-------------------+
| GMUD          | {row['GMUD']}         |
+---------------+-------------------+
| Horario       | {row['Horario']}      |
+---------------+-------------------+
"""
        # Escrever a tabela no arquivo e exibir no console
        f.write(tabela)
        print(tabela)

print(f"As tabelas foram geradas e salvas em '{arquivo_saida}'.")