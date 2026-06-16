           EXEC SQL DECLARE TRANSACOES TABLE
           ( TRX_ID           INTEGER        NOT NULL,
             CLI_ID           INTEGER        NOT NULL,
             TRX_TIPO         CHAR(1)        NOT NULL,
             TRX_VALOR        DECIMAL(9, 0)  NOT NULL,
             DT_PROCESSAMENTO DATE
           ) END-EXEC.

       01  DCLTRANSACOES.
           05 DB-TRX-ID             PIC S9(09) COMP.
           05 DB-TRX-CLI-ID         PIC S9(09) COMP.
           05 DB-TRX-TIPO           PIC X(01).
           05 DB-TRX-VALOR          PIC S9(09) COMP-3.
           05 DB-DT-PROCESSAMENTO   PIC X(10).