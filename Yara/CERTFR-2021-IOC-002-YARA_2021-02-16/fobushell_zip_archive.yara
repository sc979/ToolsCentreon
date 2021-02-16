rule PAS_webshell_ZIPArchiveFile {

    meta:
        author = "FR/ANSSI/SDO"
        description = "Detects an archive file created by P.A.S. for download operation"
        TLP = "White"

    strings:
        $ = /Archive created by P\.A\.S\. v.{1,30}\nHost: : .{1,200}\nDate : [0-9]{1,2}-[0-9]{1,2}-[0-9]{4}/

    condition:
        all of them
}
