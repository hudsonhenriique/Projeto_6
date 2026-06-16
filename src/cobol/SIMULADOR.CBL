       IDENTIFICATION DIVISION.
       PROGRAM-ID. SIMULADOR.
       AUTHOR. HUDSON.

       ENVIRONMENT DIVISION.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CLI-FILE ASSIGN TO 'data/CLIENTES.txt'
                  ORGANIZATION IS LINE SEQUENTIAL.
           SELECT TRX-FILE ASSIGN TO 'data/TRANSACOES.txt'
                  ORGANIZATION IS LINE SEQUENTIAL.
           SELECT REL-FILE ASSIGN TO 'RELATORIO.txt'
                  ORGANIZATION IS LINE SEQUENTIAL.
           SELECT ERR-FILE ASSIGN TO 'ERROS.txt'
                  ORGANIZATION IS LINE SEQUENTIAL.

           SELECT DB-CLIENTES ASSIGN TO 'DB_CLI.dat'
                  ORGANIZATION IS INDEXED
                  ACCESS MODE IS DYNAMIC
                  RECORD KEY IS DB-CLI-ID
                  FILE STATUS IS WS-FS-DB-CLI.

       DATA DIVISION.
       FILE SECTION.
       FD  CLI-FILE.
       01  CLI-REG.
           05 CLI-REG-ID       PIC 9(05).
           05 CLI-REG-NOME     PIC X(30).
           05 CLI-REG-SALDO    PIC 9(09).

       FD  TRX-FILE.
       01  TRX-REG.
           05 TRX-REG-CLI-ID   PIC 9(05).
           05 TRX-REG-TRX-ID   PIC 9(05).
           05 TRX-REG-TIPO     PIC X(01).
           05 TRX-REG-VALOR    PIC 9(09).

       FD  REL-FILE.
       01  REL-REG             PIC X(80).

       FD  ERR-FILE.
       01  ERR-REG             PIC X(100).

       FD  DB-CLIENTES.
       01  DB-CLI-REG.
           05 DB-CLI-ID        PIC 9(05).
           05 DB-CLI-NOME      PIC X(30).
           05 DB-CLI-SALDO     PIC S9(09)V99.

       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS.
           05 WS-FS-DB-CLI     PIC XX VALUE SPACES.

       01  WS-COUNTERS.
           05 WS-CONT-COMMIT   PIC 9(04) VALUE ZEROS.
           05 WS-TOT-CLI-LIDOS PIC 9(06) VALUE ZEROS.
           05 WS-TOT-TRX-LIDOS PIC 9(06) VALUE ZEROS.
           05 WS-TOT-TRX-PROC  PIC 9(06) VALUE ZEROS.
           05 WS-TOT-TRX-ERRO  PIC 9(06) VALUE ZEROS.
           05 WS-EOF-CLI       PIC X(01) VALUE 'N'.
           05 WS-EOF-TRX       PIC X(01) VALUE 'N'.

       01  WS-WORK-VARIABLES.
           05 WS-MSG-ERRO      PIC X(50) VALUE SPACES.

       01  WS-LINHA-DETALHE.
           05 FILLER           PIC X(09) VALUE 'CLIENTE: '.
           05 WS-DET-CLI       PIC 9(05).
           05 FILLER           PIC X(07) VALUE ' | OP: '.
           05 WS-DET-OP        PIC X(01).
           05 FILLER           PIC X(10) VALUE ' | VALOR: '.
           05 WS-DET-VALOR     PIC 9(09).
           05 FILLER           PIC X(11) VALUE ' | STATUS: '.
           05 WS-DET-STATUS    PIC X(28).

       PROCEDURE DIVISION.
       0000-PRINCIPAL.
           PERFORM 1000-INICIALIZAR.
           PERFORM 2000-PROCESSA-CLIENTES UNTIL WS-EOF-CLI = 'Y'.
           
           MOVE SPACES TO REL-REG.
           STRING '--- RELATORIO DETALHADO DE TRANSACOES ---'
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           PERFORM 3000-PROCESSA-TRANSACOES THRU 3999-FIM-TRANSACOES 
               UNTIL WS-EOF-TRX = 'Y'.
               
           PERFORM 4000-FINALIZAR.
           STOP RUN.

       1000-INICIALIZAR.
           OPEN INPUT  CLI-FILE
                INPUT  TRX-FILE
                OUTPUT REL-FILE
                OUTPUT ERR-FILE.

           OPEN I-O DB-CLIENTES.
           IF WS-FS-DB-CLI = '35'
               OPEN OUTPUT DB-CLIENTES
               CLOSE DB-CLIENTES
               OPEN I-O DB-CLIENTES.

           READ CLI-FILE AT END MOVE 'Y' TO WS-EOF-CLI.
           READ TRX-FILE AT END MOVE 'Y' TO WS-EOF-TRX.

       2000-PROCESSA-CLIENTES.
           ADD 1 TO WS-TOT-CLI-LIDOS.
           MOVE CLI-REG-ID TO DB-CLI-ID.

           MOVE SPACES TO WS-FS-DB-CLI.
           READ DB-CLIENTES
               INVALID KEY
                   MOVE 'S' TO WS-FS-DB-CLI.

           IF WS-FS-DB-CLI = 'S'
               PERFORM 2100-INSERIR-CLIENTE
           ELSE
               PERFORM 2200-ATUALIZAR-CLIENTE.

           READ CLI-FILE AT END MOVE 'Y' TO WS-EOF-CLI.

       2100-INSERIR-CLIENTE.
           MOVE CLI-REG-NOME TO DB-CLI-NOME.
           MOVE CLI-REG-SALDO TO DB-CLI-SALDO.
           WRITE DB-CLI-REG.

       2200-ATUALIZAR-CLIENTE.
           MOVE CLI-REG-NOME TO DB-CLI-NOME.
           MOVE CLI-REG-SALDO TO DB-CLI-SALDO.
           REWRITE DB-CLI-REG.

       3000-PROCESSA-TRANSACOES.
           ADD 1 TO WS-TOT-TRX-LIDOS.
           MOVE TRX-REG-CLI-ID TO DB-CLI-ID.
           MOVE SPACES TO WS-FS-DB-CLI.

           READ DB-CLIENTES
               INVALID KEY
                   MOVE 'ERRO: CLIENTE INEXISTENTE' TO WS-MSG-ERRO
                   PERFORM 3100-GRAVA-ERRO
                   GO TO 3999-FIM-TRANSACOES.

           IF TRX-REG-VALOR = ZEROS
               MOVE 'ERRO: VALOR DA TRANSACAO ZERADO' TO WS-MSG-ERRO
               PERFORM 3100-GRAVA-ERRO
               GO TO 3999-FIM-TRANSACOES.

           IF TRX-REG-TIPO = 'D'
               GO TO 3200-PROCESSA-DEBITO.
               
           IF TRX-REG-TIPO = 'C'
               GO TO 3300-PROCESSA-CREDITO.

           MOVE 'ERRO: TIPO INVALIDO' TO WS-MSG-ERRO.
           PERFORM 3100-GRAVA-ERRO.
           GO TO 3999-FIM-TRANSACOES.

       3200-PROCESSA-DEBITO.
           IF DB-CLI-SALDO < TRX-REG-VALOR
               MOVE 'ERRO: SALDO INSUFICIENTE' TO WS-MSG-ERRO
               PERFORM 3100-GRAVA-ERRO
               GO TO 3999-FIM-TRANSACOES.

           SUBTRACT TRX-REG-VALOR FROM DB-CLI-SALDO.
           GO TO 3400-ATUALIZA-DB.

       3300-PROCESSA-CREDITO.
           ADD TRX-REG-VALOR TO DB-CLI-SALDO.
           GO TO 3400-ATUALIZA-DB.

       3400-ATUALIZA-DB.
           REWRITE DB-CLI-REG.
           ADD 1 TO WS-TOT-TRX-PROC.
           
           MOVE TRX-REG-CLI-ID TO WS-DET-CLI.
           MOVE TRX-REG-TIPO   TO WS-DET-OP.
           MOVE TRX-REG-VALOR  TO WS-DET-VALOR.
           MOVE 'PROCESSADO COM SUCESSO' TO WS-DET-STATUS.
           WRITE REL-REG FROM WS-LINHA-DETALHE.

           ADD 1 TO WS-CONT-COMMIT.
           IF WS-CONT-COMMIT >= 100
               DISPLAY '>>> COMMIT EXECUTADO NO DB2 <<<'
               MOVE ZEROS TO WS-CONT-COMMIT.

       3999-FIM-TRANSACOES.
           READ TRX-FILE AT END MOVE 'Y' TO WS-EOF-TRX.

       3100-GRAVA-ERRO.
           ADD 1 TO WS-TOT-TRX-ERRO.
           
           MOVE TRX-REG-CLI-ID TO WS-DET-CLI.
           MOVE TRX-REG-TIPO   TO WS-DET-OP.
           MOVE TRX-REG-VALOR  TO WS-DET-VALOR.
           MOVE WS-MSG-ERRO    TO WS-DET-STATUS.
           WRITE REL-REG FROM WS-LINHA-DETALHE.

           MOVE SPACES TO ERR-REG.
           STRING 'CLI_ID: ' TRX-REG-CLI-ID ' - ' WS-MSG-ERRO
                  DELIMITED BY SIZE INTO ERR-REG.
           WRITE ERR-REG.

       4000-FINALIZAR.
           DISPLAY '=================================================='.
           DISPLAY '      SISTEMA BATCH DE CONTAS BANCARIAS - V1      '.
           DISPLAY '=================================================='.
           DISPLAY ' STATUS DO PROCESSAMENTO : FINALIZADO             '.
           DISPLAY '--------------------------------------------------'.
           DISPLAY ' [Estatisticas de Carga]                          '.
           DISPLAY ' Clientes Lidos          : ' WS-TOT-CLI-LIDOS.
           DISPLAY ' Transacoes Lidas        : ' WS-TOT-TRX-LIDOS.
           DISPLAY '--------------------------------------------------'.
           DISPLAY ' [Resultado Transacional]                         '.
           DISPLAY ' Transacoes com Sucesso  : ' WS-TOT-TRX-PROC.
           DISPLAY ' Transacoes com Erro     : ' WS-TOT-TRX-ERRO.
           DISPLAY '=================================================='.
           DISPLAY ' Logs exportados para ERROS.txt e RELATORIO.txt   '.
           DISPLAY '=================================================='.

           MOVE SPACES TO REL-REG.
           WRITE REL-REG.
           MOVE SPACES TO REL-REG.
           STRING '--- RESUMO DE PROCESSAMENTO BATCH ---'
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           MOVE SPACES TO REL-REG.
           STRING 'TOTAL CLIENTES LIDOS: ' WS-TOT-CLI-LIDOS
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           MOVE SPACES TO REL-REG.
           STRING 'TOTAL TRX LIDAS:      ' WS-TOT-TRX-LIDOS
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           MOVE SPACES TO REL-REG.
           STRING 'TOTAL TRX SUCESSO:    ' WS-TOT-TRX-PROC
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           MOVE SPACES TO REL-REG.
           STRING 'TOTAL TRX ERRO:       ' WS-TOT-TRX-ERRO
                  DELIMITED BY SIZE INTO REL-REG.
           WRITE REL-REG.

           CLOSE CLI-FILE TRX-FILE REL-FILE ERR-FILE DB-CLIENTES.
           