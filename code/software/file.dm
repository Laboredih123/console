/datum/file
	var/name = "file"
	var/flags = 0
	var/special_flags = 0
	var/datum/file/dir/parent = null
	var/obj/signal/computer/master = null
	var/disk_master = null
	var/len = 0
	var/s_type
	var/s_source
	var/tmp/is_override = 0

/datum/file/proc/copy_to(datum/file/F)

/datum/file/dir
	name = "dir"
	var/list/files = list()

/datum/file/normal
	name = "normal"
	var/text = null

/datum/file/normal/executable
	name = "executable"
	var/function = null
	flags = 3
	var/list/var_list = list()
	var/sys_stat

/datum/file/normal/executable/compiler
	name = "compiler"

/datum/file/normal/executable/dialer
	name = "dialer"

/datum/file/normal/executable/playback
	name = "playback"

/datum/file/normal/executable/resequencer
	name = "resequencer"

/datum/file/normal/executable/scr_compile
	name = "scr_compile"

/datum/file/normal/executable/script
	name = "script"

/datum/file/normal/executable/search
	name = "search"

/datum/file/normal/executable/trunicate
	name = "trunicate"

/datum/file/normal/executable/word_process
	name = "word process"

/datum/file/normal/sound
	name = "sound"
	flags = 3
