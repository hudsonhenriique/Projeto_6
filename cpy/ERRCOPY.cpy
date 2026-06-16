           EXEC SQL DECLARE ERROS_PROCESSAMENTO TABLE
           ( ID_ERRO              INTEGER NOT NULL,
             CLI_ID               INTEGER,
             DESCRICAO_ERRO       VARCHAR(100),
             DT_OCORRENCIA        TIMESTAMP
           ) END-EXEC.

       01  DCLERROS.
           05 DB-ERR-ID           PIC S9(9) USAGE COMP.
           05 DB-ERR-CLI-ID       PIC S9(9) USAGE COMP.
           05 DB-ERR-DESC.
              49 DB-ERR-DESC-LEN  PIC S9(4) USAGE COMP.
              49 DB-ERR-DESC-TXT  PIC X(100).
           05 DB-DT-OCORRENCIA    PIC X(26).