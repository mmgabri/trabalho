import csv
import uuid
import random
import datetime
from faker import Faker

def gerar_csv(nome_arquivo, qtd_linhas):
    fake = Faker('pt_BR')

    with open(nome_arquivo, mode='w', newline='', encoding='utf-8-sig') as file:
        writer = csv.writer(file, delimiter=',')
        writer.writerow(["cod_unic_pess", "nome_pess", "cod_stat_pessoa", "data_hora_update"])

        for _ in range(qtd_linhas):
            cod_unic_pess = str(uuid.uuid4())
            nome_pess = fake.name()[:50]  # Nome completo (nome + sobrenome), limitado a 50 caracteres
            cod_stat_pessoa = str(random.randint(1, 9))
            data_hora_update = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

            writer.writerow([cod_unic_pess, nome_pess, cod_stat_pessoa, data_hora_update])

    print(f"Arquivo '{nome_arquivo}' gerado com {qtd_linhas} linhas.")

# Exemplo de uso:
gerar_csv("dados_pessoas01.csv", 10000)  # Gera um CSV com 100 linhas
