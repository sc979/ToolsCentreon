rule PAS_webshell_SQLDumpFile {

    meta:
        author = "FR/ANSSI/SDO"
        description = "Detects SQL dump file created by P.A.S. webshell"
        TLP = "White"

     strings:
        $ = "-- [  SQL Dump created by P.A.S.  ] --"

     condition:
        all of them
}
