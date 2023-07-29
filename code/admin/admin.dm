var/list/admins

/world/proc/LoadAdmins()
	world.log << "Admins Loading"
	var/json = file2text("config/admins.json")
	if(!json)
		var/json_file = file("config/admins.json")
		if(!fexists(json_file))
			world.log << "Failed to admins.json. File likely corrupt."
			return
		return
	admins = json_decode(json)
	world.log << "Admins Loaded"
	return 0

/mob/Topic(href,href_list[])
	if(href_list["dump"])
		if(!(ckey in admins))
			..()
			return
		var/atom/dp = locate(href_list["dump"])
		if(!dp)
			src << "Unable to dump object."
			return
		var/mob/admin/A = src
		A.DumpVars(dp)
	else if(href_list["edit"])
		if(!(ckey in admins))
			..()
			return
		var/atom/ed = locate(href_list["edit"])
		if(!ed)
			src << "Unable to locate object for editing."
			return
		var/mob/admin/A = src
		A.Edit(ed)
	else
		..()

/mob/admin/verb/AWho()
	set category = "Admin"
	for(var/client/C)
		usr << "<b>[C.key]</b> (IP: [C.address]) (ID: [C.computer_id]) (Inactivity: [C.inactivity])"

/mob/admin/verb/Ascii(T as text)
	set category = "Admin"
	usr << text2ascii(T)

/mob/admin/verb/Char(N as num)
	set category = "Admin"
	usr << ascii2text(N)

/mob/admin/verb/DirOutput(T as text,T2 as text)
	set category = "Admin"
	var/final = dir2num(T) | dir2num(T2)
	usr << "[dir2num(T)] | [dir2num(T2)] = [final]"

/mob/admin/verb/DeleteSegment(obj/O as obj)
	set category = "Admin"
	if(istype(O,/obj/signal/wire))
		var/obj/signal/wire/W = O
		var/list/segments = list()
		W.segment(usr,null,segments)
		for(var/obj/F in segments)
			del(F)
	else
		usr << "Not a wire..."

/mob/admin/verb/ImportLab(fi as file,T as text)
	set category = "Admin"
	fdel("saves/labs/new/[ckey(T)].lab")
	var/savefile/F = new("saves/labs/new/[ckey(T)].lab")
	F.ImportText("/",file2text(fi))

/mob/admin/verb/Load_Old_Lab()
	set category = "Admin"
	var/list/save_areas = list()
	for(var/area/save_location/S in world)
		save_areas += S
	var/area/save_location/save_loc = input("Which lab do you want to load?")as null|anything in save_areas
	if(!save_loc) return
	save_loc.Load("saves/labs/[ckey(save_loc.name)].lab")
	src << "[save_loc.name] loaded."

/mob/admin/verb/Print_Config_Door_Codes()
	set category = "Admin"
	var/p
	for(p in door_codes)
		src << "[p] = [door_codes[p]]"

/mob/admin/verb/ReadSavefile(save as text)
	set category = "Admin"
	var/savefile/F = new(save)
	var/save_contents = F.ExportText("/")
	usr << browse("<pre>[save_contents]</pre>","debug_browser.browser")
	winshow(usr,"debug_browser",1)

/mob/admin/verb/ReloadAdmins()
	set category = "Admin"
	world.LoadAdmins()

/mob/admin/verb/ReloadMOTD()
	set category = "Admin"
	world.LoadMOTD()

/mob/admin/verb/ViewLog()
	set category = "Admin"
	var/logdata = file2text("console.log")
	if(!logdata)
		src << "No log found."
		return
	logdata = replacetext(logdata,"\n","<br>")
	src << browse("<tt>[logdata]</tt>","window=logwindow")

/mob/admin/verb/DeleteLog()
	set category = "Admin"
	fdel("console.log")

/mob/admin/verb/Dump_file_vars()
	set category = "Admin"
	var/list/computers = list()
	for(var/obj/signal/computer/C in usr)
		computers += C
	var/obj/signal/computer/sel_c = input("Which computer?")as null|anything in computers
	if(!sel_c) return
	var/list/files = list()
	for(var/datum/file/F in sel_c.level.files)
		files += F
	var/datum/file/sel_file = input("Which file?")as null|anything in files
	if(!sel_file) return
	src.DumpVars(sel_file)

/mob/admin/verb/Edit(atom/A)
	set category = "Admin"
	var/variable = input("What variable do you want to edit?")as null|anything in A.vars
	if(!variable) return
	var/val = A.vars[variable]
	var/nval
	var/t = input("What to edit it as?")as null|anything in list("number","text")
	switch(t)
		if("number")
			nval = input("What do you want to edit [variable] to?","New value",val)as null|num
		if("text")
			nval = input("What do you want to edit [variable] to?","New value",val)as null|text
	if(!nval)
		switch(alert("Value is 0, do you want to cancel or continue?",,"Cancel","Continue"))
			if("Cancel") return
	A.vars[variable] = nval

/mob/admin/verb/SetExcodeSpeed(N as num)
	set name = "Excode Speed"
	set category = "Admin"
	excode_speed = N
	world << "Excode parser speed set to [N*10] commands per second."

/mob/admin/verb/Duplicate(atom/A)
	set category = "Admin"
	new A.type(usr.loc)

/mob/admin/verb/Duplicate_Inv(atom/A)
	set category = "Admin"
	set name = "Duplicate Inventory"
	new A.type(usr)

/mob/admin/verb/Create()
	set category = "Admin"
	var/no = input("What do you want to create?")as null|anything in typesof(/datum)
	if(!no) return
	new no(usr.loc)

/mob/admin/verb/Reboot()
	set category = "Admin"
	world << "<b><font color=red>Rebooting Initiated</font></b>"
	SaveLabs()
	world << "<b><font color=red>Labs Saved</font></b>"
	// Save PLayers
	for(var/mob/M as anything in by_type[/mob])
		if (M.saving == TRUE)
			if(M.ckey != null)
				var/savefile/F = new /savefile( "saves/players/[M.ckey].sav" )
				F << M
	world << "<b><font color=red>Players Saved</font></b>"
	world << "<b><font color=red>Rebooting in 5 seconds</font></b>"
	sleep(50)
	world.Reboot()

/mob/admin/verb/Summon(mob/M as mob)
	set category = "Admin"
	M.loc = src.loc

/mob/admin/verb/Teleport(mob/M as mob)
	set category = "Admin"
	src.loc = M.loc

/mob/admin/verb/Teleport_Lab(area/save_location/A)
	set category = "Admin"
	var/turf/T = locate() in A
	if(T) loc = T

/mob/admin/verb/Observe(mob/M as mob)
	set category = "Admin"
	if(client.eye != usr)
		client.eye = usr
		client.perspective = MOB_PERSPECTIVE
	else
		client.eye = M
		client.perspective = EYE_PERSPECTIVE

/mob/admin/verb/Vanish()
	set category = "Admin"
	src.invisibility = !src.invisibility
	src.see_invisible = !src.see_invisible
	src.density = !src.invisibility
	src << "You [density?"reappear":"vanish"]"

/mob/admin/verb/ForceDoor(obj/door/D as obj)
	set category = "Admin"
	if(D.density)
		D.open()
	else
		D.close()

/mob/admin/verb/Delete(atom/A)
	set category = "Admin"
	if(ismob(A)) return
	del(A)

/mob/admin/verb/Spawn()
	set category = "Admin"
	var/ni = input("What do you want to spawn?")as null|anything in typesof(/obj)
	if(!ni) return
	new ni(usr.loc)

/mob/admin/verb/DumpVars(atom/A)
	set category = "Admin"
	var/html = "<b><u>Variable dump for [A.name] (<a href=byond://?src=\ref[src]&edit=\ref[A]>Edit</a>)</b></u><br>"
	for(var/V in A.vars)
		if(istype(A.vars[V],/list))
			var/list/L = A.vars[V]
			html += "<b>[V] (list)</b>"
			if(length(L) > 0)
				html += "<br>"
				for(var/I in L)
					var/vl = "[I]"
					if(!vl) continue
					if(istype(I,/datum))
						vl = "<a href=byond://?src=\ref[src]&dump=\ref[I]>[I]</a>"
					html += "-- [vl]<br>"
			else
				html += " = <i>Empty list</i><br>"
		else
			var/vl = "[A.vars[V]]"
			if(istype(A.vars[V],/datum))
				vl = "<a href=byond://?src=\ref[src]&dump=\ref[A.vars[V]]>[A.vars[V]]</a>"
			html += "[V] = [vl]<br>"
	usr << browse(html,"window=dumpvars")

/mob/Host/verb/Save_Lab()
	set category = "Host"
	set background = TRUE
	var/list/save_areas = list()
	for(var/area/save_location/S in world)
		save_areas += S
	var/area/save_location/save_loc = input("Which lab do you want to save?")as null|anything in save_areas
	if(!save_loc) return
	save_loc.Save()
	src << "[save_loc.name] saved."

/mob/Host/verb/Load_Lab()
	set category = "Host"
	var/list/save_areas = list()
	for(var/area/save_location/S in world)
		save_areas += S
	var/area/save_location/save_loc = input("Which lab do you want to load?")as null|anything in save_areas
	if(!save_loc) return
	save_loc.Load(src)

/mob/Host/verb/Save_All_Labs()
	set category = "Host"
	SaveLabs()

/mob/Host/verb/Load_All_Labs()
	set category = "Host"
	LoadLabs()
