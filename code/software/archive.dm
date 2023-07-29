/datum/file/archive
	var/list/files = list()
	var/password

/datum/file/archive/copy_to(datum/file/F)
	..()
	if(F.type == src.type)
		var/datum/file/archive/n_arc = F
		F.name = src.name
		for(var/datum/file/fi in src.files)
			var/datum/file/nf = new fi.type
			fi.copy_to(nf)
			n_arc.files += nf
		n_arc.password = src.password

/datum/file/archive/proc/AddFile(datum/file/file)
	if(file in files) return
	files += file

/datum/file/archive/proc/RemoveFile(datum/file)
	files -= file

/datum/file/archive/proc/Exists(file_name)
	for(var/datum/file/F in files)
		if(F.name == file_name)
			return F
	return 0
