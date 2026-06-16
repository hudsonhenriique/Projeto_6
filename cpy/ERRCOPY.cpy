           EXEC SQL DECLARE ERROS_PROCESSAMENTO TABLE
           ( ID_ERRO          INTEGER GENERATED ALWAYS AS IDENTITY,
             CLI_ID           INTEGER,
             DESCRICAO_ERRO   VARCHAR(100),
             DT_OCORRENCIA    TIMESTAMP
           ) END-EXEC.

       01  DCLERROS.
           05 DB-ERR-CLI-ID         PIC S9(09) COMP.
           05 DB-ERR-DESC.
              49 DB-ERR-DESC-TAM    PIC S9(04) COMP.
              49 DB-ERR-DESC-TXT    PIC X(100).
           05 DB-DT-OCORRENCIA      PIC X(26).