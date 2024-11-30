import csv


def cruzar_arquivos_csv(arq1, arq2, saida1, saida2):
    # Carrega os registros do Arquivo2 em um conjunto de tuplas (chave1, chave2)
    registros_arq2 = set()
    with open(arq2, mode='r', newline='') as f:
        reader = csv.DictReader(f, delimiter=';')
        # Detecta as colunas do Arquivo2
        colunas = reader.fieldnames
        print("Colunas detectadas no Arquivo2:", colunas)  # Verificar as colunas detectadas
        if len(colunas) < 2:
            raise ValueError("Arquivo2 deve ter pelo menos duas colunas.")

        chave1, chave2 = colunas[0], colunas[1]  # Define as colunas como chave1 e chave2
        for row in reader:
            chave = (row[chave1], row[chave2])
            registros_arq2.add(chave)

    # Abre os arquivos de saída
    with open(saida1, mode='w', newline='') as f_saida1, open(saida2, mode='w', newline='') as f_saida2:
        writer_saida1 = csv.writer(f_saida1, delimiter=';')
        writer_saida2 = csv.writer(f_saida2, delimiter=';')

        # Cabeçalhos para os arquivos de saída
        writer_saida1.writerow([chave1, chave2])
        writer_saida2.writerow([chave1, chave2])

        # Processa o Arquivo1 e verifica se os registros estão no Arquivo2
        with open(arq1, mode='r', newline='') as f:
            reader = csv.DictReader(f, delimiter=';')
            # Detecta as colunas do Arquivo1
            colunas_arquivo1 = reader.fieldnames
            print("Colunas detectadas no Arquivo1:", colunas_arquivo1)
            if len(colunas_arquivo1) < 2:
                raise ValueError("Arquivo1 deve ter pelo menos duas colunas.")

            chave1_arq1, chave2_arq1 = colunas_arquivo1[0], colunas_arquivo1[1]
            for row in reader:
                chave = (row[chave1_arq1], row[chave2_arq1])
                if chave in registros_arq2:
                    writer_saida1.writerow(chave)  # Registro encontrado nos dois arquivos
                else:
                    writer_saida2.writerow(chave)  # Registro apenas no Arquivo1


cruzar_arquivos_csv('nrec.csv', 'frec.csv', 'clientes_que_conseguiram_fazer_compra.csv', 'clientes_que_nao_conseguiram_fazer_compra.csv')
