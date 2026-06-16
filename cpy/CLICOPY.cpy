           EXEC SQL DECLARE CLIENTES TABLE
           ( CLI_ID               INTEGER NOT NULL,
             CLI_NOME             VARCHAR(30) NOT NULL,
             CLI_SALDO            DECIMAL(9, 0) NOT NULL,
             DT_ATUALIZACAO       DATE
           ) END-EXEC.

       01  DCLCLIENTES.
           05 DB-CLI-ID           PIC S9(9) USAGE COMP.
           05 DB-CLI-NOME.
              49 DB-CLI-NOME-LEN  PIC S9(4) USAGE COMP.
              49 DB-CLI-NOME-TXT  PIC X(30).
           05 DB-CLI-SALDO        PIC S9(9)V USAGE COMP-3.
           05 DB-DT-ATUALIZACAO   PIC X(10).