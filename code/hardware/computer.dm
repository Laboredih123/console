/obj/signal/computer
	name = "computer"
	icon = 'icons/computer.dmi'
	density = TRUE

	var/datum/file/dir/root = null
	var/obj/items/disk/disk = null
	var/datum/file/normal/cur_log = null
	var/obj/signal/line1 = null
	var/obj/signal/line2 = null
	var/reboot_damage = null
	var/last_startup = null
	var/recursion = null
	var/err_level = null
	var/out_level = null
	var/bios_level = 0
	var/bios1 = "A:/boot.sys"
	var/bios2 = "/sys/boot.sys"
	var/bios3 = null
	var/bios_pass1 = null
	var/bios_pass2 = null
	var/bios_pass3 = null
	var/verbose = 0
	var/datum/file/dir/level = null
	var/status = "off"
	var/sys_stat = 0
	var/cur_prog = null
	var/source
	var/list/bugslist = list()
	var/list/tmp/tasks = list()
	var/label
	var/list/environment = list()
	var/tmp/temp_user

/obj/signal/computer/Move()
	..()
	if(line1) line1.cut()
	if(line2) line2.cut()

/obj/signal/computer/Write(F)
	for(var/obj/signal/packet/S in src)
		del(S)
	..()

/obj/signal/computer/verb/label(msg as text)
	set src in view(1)
	var/n = "computer"
	if(istype(src,/obj/signal/computer/laptop))
		n = "laptop"
	label = msg
	if (msg)
		src.name = "[n]- '[msg]'"
	else
		src.name = "[n]"

/obj/signal/computer/verb/eject()
	set src in view(1)
	set category = "computers"

	if (src.disk)
		src.eject_disk()

/obj/signal/computer/verb/power_off()
	set src in view(1)
	set category = "computers"

	if (src.status == "on")
		spawn( 0 )
			src.stop()
	else
		usr << "It's not even on!"

/obj/signal/computer/verb/boot()
	set src in view(1)
	set category = "computers"

	if (src.status != "on")
		src.start()

/obj/signal/computer/verb/operate()
	set src in view(1)
	set category = "computers"
	var/ty = "desktop"
	if(temp_user)
		usr = temp_user
		temp_user = null
	if(istype(src,/obj/signal/computer/laptop))
		usr.using_laptop = src
		ty = "laptop"
	else
		usr.using_computer = src
	if(!usr.computer_docked)
		winshow(usr,"computer_main",1)
	var/wtabs
	winshow(usr,"[ty]_window",1)
	if(usr.using_computer) wtabs = "desktop_window"
	if(usr.using_laptop) wtabs += "[wtabs?",":""]laptop_window"
	winset(usr,"computer_window.operating_tab","tabs=\"[wtabs]\"")
	winset(usr,"computer_window.computer_input","focus=true")
	winset(usr,"computer_window.operating_tab","current-tab=\"[ty]_window\"")
	for(var/obj/items/scan_chip/S in usr.bugs)
		usr.bugs -= S
		S.loc = src
		src.bugs += S

	if (src.status != "on")
		src.start()

/obj/signal/computer/verb/stop_operate()
	set src in view(1)
	set category = "computers"
	if(istype(src,/obj/signal/computer/laptop))
		usr.using_laptop = null
	else
		usr.using_computer = null

/obj/signal/computer/proc/send_out(obj/S as obj, obj/signal/target)
	spawn( 1 )
		if (target)
			target.process_signal(S, src)

/obj/signal/computer/proc/insert_disk(obj/D)
	if (src.disk)
		src.eject_disk()
	else
		for(var/obj/items/scan_chip/S in D.bugs)
			D.bugs -= S
			S.loc = src
			src.bugs += S

		src.disk = D
		D.loc = src
		src.disk.root.set_master(src)

/obj/signal/computer/proc/eject_disk()
	if (src.disk)
		if ((src.level && src.level.disk_master))
			src.level = src.root
		src.disk.root.set_master(null)
		var/lc = src.loc
		if(istype(lc,/obj/signal/rackmount)) lc = src.loc.loc
		src.disk.loc = lc
		src.disk = null

/obj/signal/computer/proc/stop(console=1)
	src.status = "off"
	src.sys_stat = 0
	for(var/obj/signal/packet/S in src.loc)
		if (S.master == src)
			del(S)

	for(var/datum/task/T in src.tasks)
		del(T)

	if(console)
		for(var/mob/M in oview(src,1))
			if(M.using_computer == src||M.using_laptop == src)
				var/ty = "desktop"
				if(istype(src,/obj/signal/computer/laptop)) ty = "laptop"
				//if(M.computer_docked)
				//	M.window_command("computer_dock")
				winshow(M,"[ty]_window",0)

	spawn( 0 )
		src.recursion = 0
		src.cur_prog = null
		src.icon_state = ""
		if (istype(src.cur_log, /datum/file/normal))
			src.cur_log.text += "Shutdown [time2text(world.realtime, "MM/DD/YYYY hh:mm:ss")]; \[terminate\]"
		src.cur_log = null

/obj/signal/computer/proc/start(console=1)
	if ((src.status == "destroyed" || src.status == "no_m"))
		return
	if(console)
		for(var/mob/M in oview(src,1))
			if(M.using_computer == src||M.using_laptop == src)
				var/ty = "desktop"
				if(istype(src,/obj/signal/computer/laptop)) ty = "laptop"
				M << output(null,"[ty]_window.computer_output")
	src.reboot_damage++
	if ((src.last_startup + 60) < world.time)
		src.last_startup = world.time
		src.reboot_damage--
		src.reboot_damage = max(src.reboot_damage, 0)
	else
		if (src.reboot_damage > 10)
			src.icon_state = "destroyed"
			del(src.root)
			src.root = new /datum/file/dir(  )
			src.root.name = "root"
			src.root.master = src
			src.reboot_damage = 0
	if (src.icon_state == "destroyed")
		src.status = "destroyed"
		return
	src.icon_state = "on"
	src.status = "on"
	src.bios_level = null
	spawn( 0 )
		src.bios()

/obj/signal/computer/proc/bios_done()
	src.bios_level = null
	if ((src.sys_stat < 1 && src.status == "on"))
		src.show_message("System Resource ERROR: Kernel not located. Shutting down...")
		return stop()

/obj/signal/computer/proc/bios(password)
	if (!( src.bios_level ))
		if (src.bios1)
			if (src.bios_pass1)
				src.bios_level = "1p"
				src.show_message("Please type in the password for bios level 1.")
			else
				src.bios_level = "1"
				src.show_message("Looking for [src.bios1]")
				spawn( 0 )
					src.bios()
		else
			if (src.bios2)
				src.show_message("Could not find bios level 1.")
				if (src.bios_pass2)
					src.bios_level = "2p"
					src.show_message("Please type in the password for bios level 2.")
				else
					src.bios_level = "2"
					src.show_message("Looking for [src.bios2]")
					spawn(0)
						src.bios()
			else
				if (src.bios3)
					src.show_message("Could not find bios level 1.")
					src.show_message("Could not find bios level 2.")
					if (src.bios_pass3)
						src.bios_level = "3p"
						src.show_message("Please type in the password for bios level 3.")
					else
						src.bios_level = "3"
						src.show_message("Looking for [src.bios3]")
						spawn( 0 )
							src.bios()
				else
					src.bios_level = "F"
					src.show_message("Could not find any bios data.")
					spawn( 0 )
						src.bios()
	else
		switch(src.bios_level)
			if("1p")
				if ((password == src.bios_pass1 || !( src.bios_pass1 )))
					src.bios_level = "1"
					spawn( 0 )
						src.bios()
				else
					if (src.bios2)
						if (src.bios_pass2)
							src.bios_level = "2p"
							src.show_message("Please type in the password for bios level 2.")
						else
							src.bios_level = "2"
							src.show_message("Looking for [src.bios2]")
							spawn( 0 )
								src.bios()
					else
						if (src.bios3)
							src.show_message("No entry for bios level 2")
							if (src.bios_pass3)
								src.bios_level = "3p"
								src.show_message("Please type in the password for bios level 3.")
							else
								src.bios_level = "3"
								src.show_message("Looking for [src.bios3]")
								spawn( 0 )
									src.bios()
						else
							src.show_message("No entry for bios level 2")
							src.show_message("No entry for bios level 3")
							src.bios_level = "F"
							spawn( 0 )
								src.bios()
			if("2p")
				if ((password == src.bios_pass2 || !( src.bios_pass2 )))
					src.bios_level = "2"
					spawn( 0 )
						src.bios()
				else
					if (src.bios3)
						if (src.bios_pass3)
							src.bios_level = "3p"
							src.show_message("Please type in the password for bios level 3.")
						else
							src.bios_level = "3"
							src.show_message("Looking for [src.bios3]")
							spawn( 0 )
								src.bios()
					else
						src.show_message("No entry for bios level 3")
						src.bios_level = "F"
						spawn( 0 )
							src.bios()
			if("3p")
				if ((password == src.bios_pass3 || !( src.bios_pass3 )))
					src.bios_level = "3"
					spawn( 0 )
						src.bios()
				else
					src.bios_level = "F"
					spawn( 0 )
						src.bios()
			if("1")
				var/datum/file/normal/F = src.parse2file(src.bios1)
				if (istype(F, /datum/file/normal))
					F.execute()
					return src.bios_done()
				else
					src.show_message("Could not find [src.bios1]")
					if (src.bios2)
						if (src.bios_pass2)
							src.bios_level = "2p"
							src.show_message("Please type in the password for bios level 2.")
						else
							src.bios_level = "2"
							src.show_message("Looking for [src.bios2]")
							spawn( 0 )
								src.bios()
					else
						if (src.bios3)
							src.show_message("No entry for bios level 2")
							if (src.bios_pass3)
								src.bios_level = "3p"
								src.show_message("Please type in the password for bios level 3.")
							else
								src.bios_level = "3"
								src.show_message("Looking for [src.bios3]")
								spawn( 0 )
									src.bios()
						else
							src.show_message("No entry for bios level 2")
							src.show_message("No entry for bios level 3")
							src.bios_level = "F"
							spawn( 0 )
								src.bios()
			if("2")
				var/datum/file/normal/F = src.parse2file(src.bios2)
				if (istype(F, /datum/file/normal))
					F.execute()
					return src.bios_done()
				else
					src.show_message("Could not find [src.bios2]")
					if (src.bios3)
						if (src.bios_pass3)
							src.bios_level = "3p"
							src.show_message("Please type in the password for bios level 3.")
						else
							src.bios_level = "3"
							src.show_message("Looking for [src.bios3]")
							spawn( 0 )
								src.bios()
					else
						src.show_message("No entry for bios level 3")
						src.bios_level = "F"
						spawn( 0 )
							src.bios()
			if("3")
				var/datum/file/normal/F = src.parse2file(src.bios3)
				if (istype(F, /datum/file/normal))
					F.execute()
					return src.bios_done()
				else
					src.show_message("Could not find [src.bios3]")
					src.bios_level = "F"
					spawn( 0 )
						src.bios()
			if("F")
				src.show_message("No valid boot processes found!")
				return bios_done()

/obj/signal/computer/proc/ex_trun_list(list/L,target,pos)
	if (length(L) <= target)
		return L
	else
		if (pos)
			while(length(L) > target)
				L[1] = null
				L -= null
			return L
		else
			while(length(L) > target)
				L[length(L)] = null
				L -= null
	return L

/obj/signal/computer/proc/clear_messages()
	for(var/mob/M in view(src.loc,1))
		if(M.using_computer == src)
			M << output(null,"desktop_window.computer_output")
		if(M.using_laptop == src)
			M << output(null,"laptop_window.computer_output")

/obj/signal/computer/proc/show_message(msg, talkative, sound, s_type, c_mes,show_color=0)
	if(!show_color)
		msg = html_encode(msg)
		var/list/allowed_tags = list("b","br","i","u")
		for(var/a in allowed_tags)
			msg = replacetext(msg,"&lt;[a]&gt;","<[a]>")
			msg = replacetext(msg,"&lt;/[a]&gt;","</[a]>")
	if (src.status == "on")
		if(src.verbose == -2) return
		if ((talkative && !( src.verbose )))
			return
		for(var/obj/items/scan_chip/S in src.bugs)
			spawn( 0 )
				S.typed(msg)
		src.out_level = msg
		for(var/mob/M in view(src.loc, 1))
			if (M.using_computer == src||M.using_laptop == src)
				var/ty = "desktop"
				if(istype(src,/obj/signal/computer/laptop)) ty = "laptop"
				if(sound) msg = html_decode(msg)
				M << output("\icon[src][(sound ? " SOUND:" : "")] [msg]","[ty]_window.computer_output")

		if (sound)
			msg = html_decode(msg)
			for(var/atom/A in view(src.loc, null))
				A.hear("[msg] from \icon[src]", sound, s_type, c_mes, src)

		sleep(1)

/obj/signal/computer/proc/process(params)
	if (src.bios_level)
		bios(params)
	else
		if (src.status == "on")
			if (src.sys_stat == 3)
				for(var/obj/items/scan_chip/S in src.bugs)
					spawn( 0 )
						S.typed(params)

				if (!( src.cur_prog ))
					show_message("> [params]")
					src.parse_string(params, "user")
				for(var/datum/task/T in src.tasks)
					T.process(params)

		else
			if (params == "boot")
				boot()

/obj/signal/computer/proc/parse_string(string, source)
	var/list/t1 = list(  )
	t1 = splittext(string, ";")
	for(var/x in t1)
		var/list/t2 = list(  )
		t2 = splittext(x, " ")
		src.execute(t2[1], jointext(t2 - t2[1], "[ascii2text(2)]"), source)

/obj/signal/computer/proc/makedir(string, datum/file/dir/D)
	var/list/L = splittext(string, "/")
	if (!( D ))
		return
	var/t7
	if ((L && length(L)))
		t7 = L[1]
	else
		t7 = string
	if (t7)
		var/datum/file/dir/D2
		if (src.get_file2(t7, D))
			D2 = src.get_file2(t7, D)
		else
			D2 = new /datum/file/dir(  )
			D2.name = t7
			D2.parent = D
			D2.master = D.master
			D2.disk_master = D.disk_master
			D.files += D2
			show_message("Directory Created: [src.get_path(D2)]")
		var/list/I = list(  )
		var/x = null
		x = 2
		while(x <= length(L))
			I += L[x]
			x++
		return src.makedir(jointext(I, "/"), D2)
	return D

/obj/signal/computer/proc/get_file(string in view(usr.client))
	for(var/datum/file/N in src.level.files)
		if ("[N.name]" == "[string]")
			return N
	return null

/obj/signal/computer/proc/get_path(datum/file/dir/F in view(usr.client))
	if (F)
		var/temp = F.buildparent()
		return "[(temp ? "[temp]/" : "")][F]/"

/obj/signal/computer/proc/get_file2(string in view(usr.client), datum/file/dir/directory in view(usr.client))

	if (istype(directory, /datum/file/dir))
		for(var/datum/file/N in directory.files)
			if ("[N.name]" == "[string]")
				return N
	return null

/obj/signal/computer/proc/follow_path(string in view(usr.client))
	if (!( string ))
		return null
	var/F = src.level
	var/list/L = splittext(string, "/")
	if (!( length(L) ))
		return null
	var/i = null
	i = 1
	while(i <= length(L))
		if ((i && L[i]))
			if (L[i] == "root")
				F = src.root
			else
				if (L[i] == "A:")
					if ((src.disk && src.disk.root))
						F = src.disk.root
					else
						return null
				else
					F = src.get_file2(L[i], F)
					if (!( F ))
						return null
		i++
	return F

/obj/signal/computer/proc/parse2file(string)
	if (!( string ))
		return null
	var/F = src.level
	var/list/L = splittext(string, "/")
	if (!( length(L) ))
		return null
	if (copytext(string, 1, 2) == "/")
		F = src.root
	else
		if ("[L[1]]" == "root")
			F = src.root
		else
			if ("[L[1]]" == "A:")
				if (src.disk)
					F = src.disk.root
				else
					return null
			else
				if (L[1])
					F = src.get_file2(L[1], F)
					if (!( F ))
						return null
	var/i = null
	i = 2
	while(i <= length(L))
		if (L[i])
			F = src.get_file2(L[i], F)
			if (!( F ))
				return null
		i++
	return F

/obj/signal/computer/proc/add_to_log(string in view(usr.client))
	if (!( src.cur_log ))
		var/datum/file/dir/t2 = parse2file("/log")
		if (!( istype(t2, /datum/file/dir) ))
			return
		src.cur_log = new /datum/file/normal(  )
		src.cur_log.name = "[world.time].log"
		src.cur_log.parent = t2
		src.cur_log.master = src
		src.cur_log.text = "Log Startup Record Time [time2text(world.realtime, "MM/DD/YYYY hh:mm:ss")];"
		t2.files += src.cur_log
	src.cur_log.text += "[string];"

/obj/signal/computer/attack_hand(mob/user)
	if (istype(src.lock, /obj/items/lock))
		var/t = src.lock
		var/d = src.loc
		if ((src.lock.manipulate(user) && (src.lock == t && src.loc == d)))
			src.lock.loc = src.loc
			src.lock = null

/obj/signal/computer/attack_by(obj/items/D, mob/user)
	if (istype(D, /obj/items/disk))
		if (!( src.disk ))
			D.unequip()
			src.insert_disk(D)
		else
			user << "<B>There is already a disk in the computer.</B>"
	else
		if (istype(D, /obj/items/screwdriver))
			if (!( src.lock ))
				switch(src.status)
					if("destroyed")
						var/obj/items/monitor/M = new /obj/items/monitor( src.loc )
						M.icon_state = "monitord"
						view(src, null) << "\red [user] removes the destroyed monitor!"
						src.icon_state = "removed"
						src.status = "no_m"
					if("on")
						user << "\blue You can't do that while it is on!"
						return
					if("off")
						var/obj/items/monitor/M = new /obj/items/monitor( src.loc )
						M.icon_state = "monitor"
						view(src, null) << "\red [user] removes the monitor!"
						src.icon_state = "removed"
						src.status = "no_m"
					else
			else
				user << "\blue There is a lock on it!"
		else
			if (istype(D, /obj/items/key))
				var/K = D
				if (src.lock)
					if (src.lock.insert_key(K, user))
						src.lock.loc = src.loc
						src.lock = null
				else
					user << "\blue There is no lock!"
			else
				if (istype(D, /obj/items/scan_chip))
					var/obj/items/scan_chip/S = D
					S.rem_equip(user)
					S.loc = src
					src.bugs += S
					user << "Click!"
				else
					if (istype(D, /obj/items/bug_scan))
						for(var/obj/items/I in src.bugs)
							src.bugs -= I
							I.loc = src.loc

					else
						if (istype(D, /obj/items/lockpick))
							var/K = D
							if (src.lock)
								src.lock.insert_object(K, user)
							else
								user << "\blue There is no lock!"
						else
							if (istype(D, /obj/items/lock))
								var/obj/items/lock/K = D
								if (src.lock)
									user << "\blue There already is a lock!"
								else
									K.unequip()
									src.lock = K
									src.lock.loc = src
							else
								if (istype(D, /obj/items/monitor))
									if (src.status != "no_m")
										user << "\blue A monitor is already plugged in!"
										return
									else
										if (D.icon_state == "monitord")
											src.status = "destroyed"
											src.icon_state = "destroyed"
											user << "\blue You place the destroyed monitor onto the computer."
										else
											src.status = "off"
											src.icon_state = null
											user << "\blue You place the monitor onto the computer."
										del(D)
								else
									if (istype(D, /obj/items/wrench))
										if (src.status != "no_m")
											user << "\blue The screws won't go loose!"
											return
										else
											view(src, null) << "[user] packs up a computer!"
											cut()
											var/obj/items/computer/C = new /obj/items/computer( src.loc, src )
											C.name = src.name
											src.loc = C
									else
										if (istype(D, /obj/items/wirecutters))
											if (src.status != "no_m")
												user << "\blue The screws won't go loose!"
												return
											else
												view(src, null) << "[user] resets the bios settings!"
												src.bios1 = "A:/boot.sys"
												src.bios2 = "/sys/boot.sys"
												src.bios3 = null
												src.bios_pass1 = null
												src.bios_pass2 = null
												src.bios_pass3 = null
										else
											..()

/obj/signal/computer/process_signal(obj/signal/packet/S, obj/source)
	..()
	if(!S) return
	if (istype(S.loc, /turf))
		S.loc = src.loc
	S.master = src
	var/line = 0
	if (source == src.line2)
		line = 1
	if (src.status != "on")
		del(S)
		return
	src.show_message("Packet(id:[S.id]) received from [S.source_id][(line ? " (peripheral) " : "")]!", 1)
	for(var/datum/task/E in src.tasks)
		if (!( E.p_type ))
			E.var_list["sys_packet"] = S.id
			E.var_list["pack_params"] = S.params
			E.var_list["pack_d_id"] = S.dest_id
			E.var_list["pack_iline"] = line
			E.var_list["pack_s_id"] = S.source_id

	if (S.id == "-1")
		if (!( S.cur_file ))
			del(S)
			return
		else
			src.show_message("File detected in packet! Please check /tmp. Name: [S.cur_file.name]", 1)
			var/datum/file/dir/D = parse2file("/tmp")
			if ((!( D ) || !( istype(D, /datum/file/dir) )))
				del(D)
				D = new /datum/file/dir(  )
				D.parent = src.root
				D.name = "tmp"
				D.files = list(  )
			var/datum/file/normal/t1 = src.parse2file("/tmp/[S.cur_file.name]")
			if (t1)
				src.show_message("Overwriting [t1.name]", 1)
				del(t1)
			S.cur_file.parent = D
			S.cur_file.set_master(src)
			D.files += S.cur_file
	if ((S.id == "0"&&parse2file("/usr/shell.scr")))
		src.process(S.params)
	else
		if (src.parse2file("/usr/packet[S.id].scr"))
			src.add_to_log("back /usr/packet[S.id].scr [S.source_id] [S.dest_id] [line] [S.params]", null)
			var/datum/file/normal/t2 = src.parse2file("/usr/packet[S.id].scr")
			var/t7 = jointext(list( "[S.source_id]", "[S.dest_id]", "[line]", "[S.params]" ), "[ascii2text(2)]")
			spawn( 0 )
				if (istype(t2, /datum/file/normal))
					t2.execute(t7)
		else
			var/datum/file/normal/t1 = src.parse2file("/tmp/packet[S.id].dat")
			if (t1)
				t1.master = null
				src.show_message("Overwriting [t1.name]", 1)
				del(t1)
			var/datum/file/dir/D = src.parse2file("/tmp")
			if ((!( D ) || !( istype(D, /datum/file/dir) )))
				del(D)
				D = new /datum/file/dir(  )
				D.parent = src.root
				D.name = "tmp"
				D.files = list(  )
			t1 = new /datum/file/normal()
			t1.text = "[S.source_id]~[S.dest_id]:[line]`[S.params]"
			t1.name = "packet[S.id].dat"
			t1.parent = D
			t1.master = src
			D.files += t1
			if (src.parse2file("/usr/packet.scr"))
				src.add_to_log("back /usr/packet.scr [S.source_id] [S.dest_id] [line] [S.id] [S.params]", null)
				var/datum/file/normal/t2 = parse2file("/usr/packet.scr")
				var/t7 = jointext(list( "[S.source_id]", "[S.dest_id]", "[line]", "[S.id]", "[S.params]" ), "[ascii2text(2)]")
				spawn( 0 )
					if (istype(t2, /datum/file/normal))
						t2.execute(t7)
	del(S)

/obj/signal/computer/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if (!( src.line1 ))
		src.line1 = target
		return TRUE
	else
		if (!( src.line2 ))
			src.line2 = target
			user << "Connected to peripheral line!"
			return TRUE
		else
			return FALSE

/obj/signal/computer/disconnectfrom(obj/source)
	if (src.line1 == source)
		src.line1 = null
	else
		if (src.line2 == source)
			src.line2 = null

/obj/signal/computer/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	if (src.line2)
		src.line2.disconnectfrom(src)
	src.line1 = null
	src.line2 = null

/obj/signal/computer/New()
	src.last_startup = world.time
	..()
	src.root = new /datum/file/dir(  )
	src.root.name = "root"
	src.root.master = src
	for(var/x in list( "usr", "bin", "tmp", "log" ))
		var/datum/file/dir/t1 = new /datum/file/dir(  )
		t1.name = x
		t1.parent = src.root
		t1.master = src
		src.root.files += t1
		if (x == "bin")
			var/datum/file/normal/executable/playback/P = new /datum/file/normal/executable/playback(  )
			P.parent = t1
			P.name = "playback.exe"
			P.master = src
			t1.files += P
			var/datum/file/normal/executable/dialer/D = new /datum/file/normal/executable/dialer(  )
			D.parent = t1
			D.name = "dialer.exe"
			D.master = src
			t1.files += D
			var/datum/file/normal/executable/word_process/E = new /datum/file/normal/executable/word_process(  )
			E.parent = t1
			E.name = "wp.exe"
			E.master = src
			t1.files += E
			var/datum/file/normal/executable/compiler/C = new /datum/file/normal/executable/compiler(  )
			C.parent = t1
			C.name = "compiler.exe"
			C.master = src
			t1.files += C
			var/datum/file/normal/executable/resequencer/R = new /datum/file/normal/executable/resequencer(  )
			R.parent = t1
			R.name = "resequence.exe"
			R.master = src
			t1.files += R
			var/datum/file/normal/executable/trunicate/T = new /datum/file/normal/executable/trunicate(  )
			T.parent = t1
			T.name = "trunicate.exe"
			T.master = src
			t1.files += T
			var/datum/file/normal/executable/scr_compile/SC = new /datum/file/normal/executable/scr_compile(  )
			SC.parent = t1
			SC.name = "scr_compiler.exe"
			SC.master = src
			t1.files += SC
			var/datum/file/normal/executable/search/SE = new /datum/file/normal/executable/search(  )
			SE.parent = t1
			SE.name = "search.exe"
			SE.master = src
			t1.files += SE
			var/datum/file/normal/executable/NE = new /datum/file/normal/executable(  )
			NE.text = "shell;\"echo Please type in the password! (test)\nid;retry\nshell;\"delay 50\nif;input:\"1;==;null;retry\nif;input:\"1;==;\"test;correct\nshell;\"shutdown\nid;correct\nshell;\"echo Correct! Unlocking system\nend;\"1\n"
			NE.master = src
			NE.name = "pass.exe"
			NE.parent = t1
			t1.files += NE
			var/datum/file/normal/executable/N = new /datum/file/normal/executable(  )
			N.text = "id;start\nshell;\"echo This is only a test program. If you receive this more than once there is a bug!\nset;test;\"works\nif;test;!=;\"works;failure\nshell;\"echo It works!\nend;1\nid;failure\ngoto;start\n"
			N.master = src
			N.name = "test.exe"
			N.parent = t1
			t1.files += N

	var/datum/file/dir/t1 = new /datum/file/dir()
	t1.name = "sys"
	t1.master = src
	t1.parent = src.root
	src.root.files += t1
	var/datum/file/normal/t2 = new /datum/file/normal(  )
	t2.name = "boot.sys"
	t2.text = "run /sys/kernel.sys;run /sys/os.sys;console;cd /usr"
	t2.parent = t1
	t2.master = src
	t1.files += t2
	var/datum/file/normal/executable/t3 = new /datum/file/normal/executable(  )
	t3.function = 1
	t3.name = "kernel.sys"
	t3.parent = t1
	t3.master = src
	t1.files += t3
	t3 = new /datum/file/normal/executable(  )
	t3.function = 2
	t3.name = "os.sys"
	t3.parent = t1
	t3.master = src
	t1.files += t3
	var/datum/file/dir/t5 = new /datum/file/dir(  )
	t5.name = "registry"
	t5.parent = t1
	t5.master = src
	t1.files += t5
	var/datum/file/normal/write_scr = new /datum/file/normal(  )
	var/datum/file/normal/append_scr = new /datum/file/normal(  )
	var/datum/file/normal/play_scr = new /datum/file/normal(  )
	write_scr.name = "write.com"
	write_scr.parent = t5
	write_scr.master = src
	write_scr.text = "file_clear arg1;run /bin/wp.exe arg1"
	t5.files += write_scr
	append_scr.name = "append.com"
	append_scr.parent = t5
	append_scr.master = src
	append_scr.text = "run /bin/wp.exe arg1"
	t5.files += append_scr
	play_scr.name = "play.com"
	play_scr.parent = t5
	play_scr.master = src
	play_scr.text = "run /bin/playback.exe arg1"
	t5.files += play_scr

/obj/signal/computer/Del()
	for(var/t in src.tasks)
		del(t)

	del(src.root)
	..()


/obj/items/computer
	name = "computer"
	icon_state = "cpu"
	var/obj/signal/computer/computer = null

/obj/items/computer/verb/label(T as text)
	set src in view(1)
	set category = "computers"
	if(!T)
		name = "computer"
		if(src.computer)
			src.computer.label = null
			src.computer.name = "computer"
	else
		name = "computer- '[T]'"
		if(src.computer)
			src.computer.label = T
			src.computer.name = "computer- '[T]'"

/obj/items/computer/New(loca, obj/O)
	if (!isnull(O))
		src.computer = new /obj/signal/computer( src )
		src.computer.icon_state = "removed"
		src.computer.status = "no_m"
	else
		src.computer = O

/obj/items/computer/attack_by(obj/W, mob/user)
	if (!( istype(W, /obj/items/wrench) ))
		user << "You have to use a wrench"
	if (!( isturf(src.loc) ))
		user << "The computer cannot be deployed inside an object."
	else
		src.computer.loc = src.loc
		del(src)
