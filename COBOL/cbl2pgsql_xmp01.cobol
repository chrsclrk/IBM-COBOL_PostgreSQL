       IDENTIFICATION DIVISION.
       PROGRAM-ID.  "HELLO_POSTGRES".

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  PGSQL-CONNECT.
           10  DB-NAME            PIC X(4)  VALUE "AD22".
       01  PGSQL-DATA.  
           10  NAME-FIRST         PIC X(8) VALUE SPACES.
           10  NAME-LAST          PIC X(8) VALUE SPACES.
       01  REPORT-AREA.
           10  HDR_001            PIC x(17) VALUE '   emp_names    '.
           10  HDR_002            PIC x(17) VALUE '----------------'.
           10  LINE_001           PIC X(17) VALUE SPACES.


       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
      *  Reloy on PGSQL environment variables for database connection.
           EXEC SQL 
               CONNECT TO :DB-NAME 
           END-EXEC.

           EXEC SQL
               DECLARE EMP_CURSOR CURSOR FOR
               SELECT first_name, last_name FROM teachers
           END-EXEC.

           EXEC SQL 
               OPEN EMP_CURSOR 
           END-EXEC.

           IF SQLCODE NOT EQUAL ZERO THEN
               DISPLAY "+++ Error opening cursor: " SQLCODE
               STOP RUN
           END-IF.
           
           DISPLAY HDR_001.
           DISPLAY HDR_002.
           PERFORM UNTIL SQLCODE = 100  *> 100 indicates "no data found"
               EXEC SQL 
                   FETCH EMP_CURSOR
                       INTO :NAME-FIRST, 
                            :NAME-LAST 
               END-EXEC

               IF SQLCODE NOT EQUAL ZERO AND SQLCODE NOT EQUAL 100 
               THEN
                   DISPLAY "+++ Error fetching data: " SQLCODE
                   STOP RUN
               ELSE 
                   IF SQLCODE EQUAL ZERO THEN
                       STRING " " DELIMITED BY SIZE
                              NAME-FIRST DELIMITED BY SPACE
                              " " DELIMITED BY SIZE
                              NAME-LAST DELIMITED BY SPACE
                           INTO LINE_001
                       DISPLAY LINE_001
                       MOVE SPACES TO NAME-FIRST
                       MOVE SPACES TO NAME-LAST
                       MOVE SPACES TO LINE_001
                    END-IF
               END-IF
           END-PERFORM.

           EXEC SQL CLOSE EMP-CURSOR END-EXEC.

      *> Disconnect from the database
           EXEC SQL
               DISCONNECT CURRENT
           END-EXEC.

           IF SQLCODE NOT EQUAL ZERO THEN
               DISPLAY "+++ Error disconnecting from database: " SQLCODE
               STOP RUN
           END-IF.

           DISPLAY "+++ Disconnected from PostgreSQL database. +++"
           GOBACK.