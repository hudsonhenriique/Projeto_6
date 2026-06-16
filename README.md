# Sistema Batch de Contas Bancárias com DB2

![COBOL](https://img.shields.io/badge/COBOL-OS%2FVS_ANSI--74-blue)
![DB2](https://img.shields.io/badge/DB2-Relational_Database-lightgrey)
![VSAM](https://img.shields.io/badge/VSAM-Indexed_Files-orange)

## Sobre o Projeto

Neste projeto desenvolvi uma aplicação batch em COBOL para processamento de contas bancárias com persistência em DB2.

O objetivo foi simular um cenário comum de sistemas financeiros legados, onde um arquivo contendo movimentações de crédito e débito é processado diariamente para atualizar saldos, registrar transações e armazenar informações de auditoria.

Como o ambiente local não possui suporte nativo ao pré-compilador DB2 utilizado em Mainframe, implementei duas versões da solução:

- **BANKAPP**: versão principal desenvolvida para ambiente Mainframe com SQL embarcado e integração com DB2.
- **SIMULADOR**: versão executável localmente utilizando arquivos indexados VSAM através do GnuCOBOL, reproduzindo as mesmas regras de negócio da aplicação principal.

Durante o desenvolvimento trabalhei com conceitos bastante utilizados em ambientes corporativos de grande porte, incluindo acesso a banco de dados relacional, controle transacional, tratamento de exceções, manipulação de arquivos indexados e geração de relatórios operacionais.

Além da implementação das funcionalidades, dediquei uma parte significativa do projeto à realização de testes e ao diagnóstico de problemas de fluxo de execução característicos do COBOL ANSI-74, garantindo que o processamento das transações ocorresse de forma consistente e segura.

## Principais Funcionalidades

- **Atualização de Cadastro:** O sistema verifica se o cliente existe no banco. Se não existir, faz a inserção (`INSERT`); se existir, atualiza os dados e o saldo.
- **Validação de Regras de Negócio:**
  - Recusa transações com valores zerados.
  - Identifica e bloqueia tipos de transação diferentes de `C` (Crédito) ou `D` (Débito).
  - Bloqueia saques para contas sem saldo suficiente.
  - Evita o processamento de transações para clientes que não estão cadastrados.
- **Controle de Banco de Dados:** Implementação de `COMMIT` a cada 100 registros processados e `ROLLBACK` em caso de erro de banco (SQLCODE negativo).
- **Relatórios e Logs:** - Geração de relatório detalhado mostrando o status (sucesso ou motivo do erro) de cada transação lida.
  - Exportação de logs de falha para o arquivo `.txt` e inserção na tabela `ERROS_PROCESSAMENTO` do DB2.
  - Exibição de um resumo consolidado do processamento direto no terminal.

## Tecnologias e Ferramentas

- **Linguagem:** COBOL (OS/VS COBOL ANSI-74)
- **Banco de Dados:** IBM DB2 (Mapeamento via DCLGEN)
- **Emulação Local:** Arquivos Indexados VSAM (via GnuCOBOL)
- **Ambiente de Desenvolvimento:** VS Code com extensão IBM Z Open Editor

## Desafios e Aprendizados

Um dos maiores desafios deste projeto foi reproduzir localmente um comportamento próximo ao ambiente Mainframe utilizando apenas GnuCOBOL e arquivos VSAM.

Também foi necessário lidar com características específicas do COBOL ANSI-74, que não possui recursos presentes em versões mais modernas da linguagem, como `END-IF` e `END-READ`. Isso exigiu atenção especial na organização dos parágrafos e no controle do fluxo de execução.

Durante os testes encontrei problemas relacionados ao processamento sequencial das rotinas, incluindo situações de *fall-through*, em que uma mesma transação poderia percorrer caminhos indevidos da lógica de negócio. A análise detalhada dos logs e dos acumuladores permitiu identificar a origem dos problemas e ajustar a estrutura dos `PERFORMs`, garantindo a correta separação entre validações, atualizações de saldo e geração de relatórios.

Outro aprendizado importante foi a implementação de mecanismos de controle transacional utilizando `COMMIT` e `ROLLBACK`, simulando práticas utilizadas em aplicações financeiras reais para garantir a integridade dos dados mesmo em cenários de erro.

## Estrutura do Projeto

```text
PROJETO 6/
│
├── cpy/                  # Copybooks DCLGEN (Mapeamento DB2)
│   ├── CLICOPY.cpy
│   ├── ERRCOPY.cpy
│   └── TRXCOPY.cpy
│
├── data/                 # Massa de dados de teste
│   ├── CLIENTES.TXT
│   └── TRANSACOES.TXT
│
├── src/                  # Códigos-fonte
│   ├── BANKAPP.CBL       # Código Oficial (DB2/Mainframe)
│   └── SIMULADOR.CBL     # Simulador Local (VSAM/GnuCOBOL)
│
├── .gitignore
├── zapp.yaml             # Configuração do IBM Z Open Editor
└── README.md
```
## Como Executar Localmente (Simulador)

Para validar a lógica de negócio na sua máquina antes de realizar a execução no ambiente Mainframe:

1. Certifique-se de ter o **GnuCOBOL** instalado e configurado nas variáveis de ambiente do sistema.

2. Clone este repositório e abra um terminal na pasta raiz do projeto.

3. Compile o simulador executando o comando:

```bash
cobc -x src/SIMULADOR.cbl
```

4. Execute o arquivo gerado:

```bash
.\SIMULADOR.exe
```

5. Após a execução, verifique:
   - O dashboard exibido no console;
   - O arquivo `RELATORIO.txt`;
   - O arquivo `ERROS.txt`.

Esses arquivos serão gerados na raiz do projeto e conterão os resultados do processamento e as inconsistências encontradas durante a execução.

---

## Autor

**Hudson Henrique**

- GitHub: https://github.com/hudsonhenriique
- LinkedIn: https://www.linkedin.com/in/hudsonhenriique
