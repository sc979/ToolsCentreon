rule PAS_webshell {

    meta:
        author = "FR/ANSSI/SDO"
        description = "Detects P.A.S. PHP webshell - Based on DHS/FBI JAR-16-2029 (Grizzly Steppe)"
        TLP = "White"

    strings:

        $php = "<?php"
        $base64decode = /='base'\.\(\d+(\*|\/)\d+\)\.'_de'\.'code'/
        $strreplace = "(str_replace("
        $md5 = ".substr(md5(strrev($" nocase
        $gzinflate = "gzinflate"
        $cookie = "_COOKIE"
        $isset = "isset"

    condition:

        (filesize > 20KB and filesize < 200KB) and
        #cookie == 2 and
        #isset == 3 and
        all of them
}
