/* configuration file */

rule exaramel_configuration_key {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Encryption key for the configuration file in sample e1ff72[...]"
		TLP = "White"

	strings:
		$ = "odhyrfjcnfkdtslt"

	condition:
		all of them
}

rule exaramel_configuration_name_encrypted {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Name of the configuration file in sample e1ff72[...]"
		TLP = "White"

	strings:
		$ = "configtx.json"

	condition:
		all of them
}

rule exaramel_configuration_file_plaintext {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Content of the configuration file (plaintext)"
		TLP = "White"

	strings:
		$ = /{"Hosts":\[".{10,512}"\],"Proxy":".{0,512}","Version":".{1,32}","Guid":"/

	condition:
		all of them
}

rule exaramel_configuration_file_ciphertext {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Content of the configuration file (encrypted with key odhyrfjcnfkdtslt, sample e1ff72[...]"
		TLP = "White"

	strings:
		$ = {6F B6 08 E9 A3 0C 8D 5E DD BE D4} // encrypted with key odhyrfjcnfkdtslt

	condition:
		all of them
}

/* persistence */

private rule exaramel_persistence_file_systemd {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Beginning of the file /etc/systemd/system/syslogd.service created for persistence with systemd"
		TLP = "White"

	strings:
		$ = /\[Unit\]\nDescription=Syslog daemon\n\n\[Service\]\nWorkingDirectory=.{1,512}\nExecStartPre=\/bin\/rm \-f \/tmp\/\.applocktx\n/

	condition:
		all of them
}

private rule exaramel_persistence_file_upstart {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Part of the file /etc/init/syslogd.conf created for persistence with upstart"
		TLP = "White"

	strings:
		$ = /start on runlevel \[2345\]\nstop on runlevel \[06\]\n\nrespawn\n\nscript\nrm \-f \/tmp\/\.applocktx\nchdir/

	condition:
		all of them
}

private rule exaramel_persistence_file_systemv {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Part of the file /etc/init.d/syslogd created for persistence with upstart"
		TLP = "White"

	strings:
		$ = "# Short-Description: Syslog service for monitoring \n### END INIT INFO\n\nrm -f /tmp/.applocktx && cd "

	condition:
		all of them
}

rule exaramel_persistence_file {

	meta:
		author = "FR/ANSSI/SDO"
		description = "File created for persistence. Depends on the environment"
		TLP = "White"

	condition:
		exaramel_persistence_file_systemd or exaramel_persistence_file_upstart or exaramel_persistence_file_systemv
}

/* misc */

rule exaramel_socket_path {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Path of the unix socket created to prevent concurrent executions"
		TLP = "White"

	strings:
		$ = "/tmp/.applocktx"

	condition:
		all of them
}

rule exaramel_task_names {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Name of the tasks received by the CC"
		TLP = "White"

	strings:
		$ = "App.Delete"
		$ = "App.SetServer"
		$ = "App.SetProxy"
		$ = "App.SetTimeout"
		$ = "App.Update"
		$ = "IO.ReadFile"
		$ = "IO.WriteFile"
		$ = "OS.ShellExecute"

	condition:
		all of them
}

rule exaramel_struct {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Beginning of type _type struct for some of the most important structs"
		TLP = "White"

	strings:
		$struct_le_config = {70 00 00 00 00 00 00 00 58 00 00 00 00 00 00 00 47 2d 28 42 0? [2] 19}
		$struct_le_worker = {30 00 00 00 00 00 00 00 30 00 00 00 00 00 00 00 46 6a 13 e2 0? [2] 19}
		$struct_le_client = {20 00 00 00 00 00 00 00 10 00 00 00 00 00 00 00 7b 6a 49 84 0? [2] 19}
		$struct_le_report = {30 00 00 00 00 00 00 00 28 00 00 00 00 00 00 00 bf 35 0d f9 0? [2] 19}
		$struct_le_task = {50 00 00 00 00 00 00 00 20 00 00 00 00 00 00 00 88 60 a1 c5 0? [2] 19}

	condition:
		any of them
}

private rule exaramel_strings_url {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Misc strings coming from URL parts"
		TLP = "White"

	strings:
		$url1 = "/tasks.get/"
		$url2 = "/time.get/"
		$url3 = "/time.set"
		$url4 = "/tasks.report"
		$url5 = "/attachment.get/"
		$url6 = "/auth/app"

	condition:
		5 of ($url*)
}

private rule exaramel_strings_typo {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Misc strings with typo"
		TLP = "White"

	strings:
		$typo1 = "/sbin/init |  awk "
		$typo2 = "Syslog service for monitoring \n"
		$typo3 = "Error.Can't update app! Not enough update archive."
		$typo4 = ":\"metod\""

	condition:
		3 of ($typo*)
}

private rule exaramel_strings_persistence {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Misc strings describing persistence methods"
		TLP = "White"

	strings:
		$ = "systemd"
		$ = "upstart"
		$ = "systemV"
		$ = "freebsd rc"

	condition:
		all of them
}

private rule exaramel_strings_report {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Misc strings coming from report file name"
		TLP = "White"

	strings:
		$ = "systemdupdate.rep"
		$ = "upstartupdate.rep"
		$ = "remove.rep"

	condition:
		all of them
}

rule exaramel_strings {

	meta:
		author = "FR/ANSSI/SDO"
		description = "Misc strings including URLs, typos, supported startup systems and report file names"
		TLP = "White"

	condition:
		exaramel_strings_typo or (exaramel_strings_url and exaramel_strings_persistence) or (exaramel_strings_persistence and exaramel_strings_report) or (exaramel_strings_url and exaramel_strings_report)
}
