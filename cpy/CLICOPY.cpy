           EXEC SQL DECLARE CLIENTES TABLE
           ( CLI_ID           INTEGER        NOT NULL,
             CLI_NOME         VARCHAR(30)    NOT NULL,
             CLI_SALDO        DECIMAL(9, 0)  NOT NULL,
             DT_ATUALIZACAO   DATE
           ) END-EXEC.

       01  DCLCLIENTES.
           05 DB-CLI-ID             PIC S9(09) COMP.
           05 DB-CLI-NOME.
              49 DB-CLI-NOME-TAM    PIC S9(04) COMP.
              49 DB-CLI-NOME-TXT    PIC X(30).
           05 DB-CLI-SALDO          PIC S9(09) COMP-3.
           05 DB-DT-ATUALIZACAO     PIC X(10).