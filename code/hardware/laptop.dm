/obj/signal/computer/laptop
	name = "laptop"
	icon = 'icons/laptop.dmi'
	var/e_key = "1"

/obj/signal/computer/laptop/orient_to()
	return 0

/obj/signal/computer/laptop/attack_by(obj/items/D, mob/user)
	if (istype(D, /obj/items/disk))
		if (!( src.disk ))
			D.unequip()
			src.insert_disk(D)
		else
			user << "<B>There is already a disk in the computer.</B>"
	else
		if (istype(D, /obj/items/scan_chip))
			var/obj/items/S = D
			S.rem_equip(user)
			S.loc = src
			src.bugs += S
			user << "Click!"
		else
			if (istype(D, /obj/items/bug_scan))
				for(var/obj/items/I in src.bugs)
					src.bugs -= I
					I.loc = src.loc

/obj/signal/computer/laptop/execute(command in view(usr.client), params in view(usr.client))
	if (command == "e_key")
		var/t1 = splittext(params, "[ascii2text(2)]")
		if (src.status != "on")
			return
		if (src.sys_stat >= 2)
			add_to_log("[command] ([params])")
		var/number = text2num(t1[1])
		number = round(min(max(1, number), 65000))
		src.e_key = "[number]"
		show_message("Encryption key is now [src.e_key]!")
	else
		return ..()

/obj/signal/computer/laptop/send_out(obj/signal/packet/S)
	S.loc = null
	S.master = src
	for(var/obj/signal/C)
		if(C == src) continue
		if ((get_dist(C.loc, src.loc) <= 50 && C != src))
			if (C.r_accept(src.e_key, src))
				var/obj/signal/packet/S1 = new /obj/signal/packet(  )
				S.copy_to(S1)
				S1.strength -= 2
				if (S1.strength <= 0)
					del(S1)
				missile(/obj/radio, src.loc, C.loc)
				spawn( 0 )
					C.process_radio(S1,src)
	del(S)

/obj/signal/computer/laptop/process_radio(obj/signal/packet/S,atom/source)
	S.loc = src
	S.master = src
	spawn(0)
		src.process_signal(S, src)

/obj/signal/computer/laptop/r_accept(string, source)
	if (src.status != "on")
		return FALSE
	if (string == src.e_key)
		return TRUE
	else
		return FALSE

/obj/signal/computer/laptop/verb/equip()
	set src in usr
	set category = "items"
	var/s = FALSE
	if (usr.equipped)
		if(usr.equipped == src) s = TRUE
		if(istype(usr.equipped,/obj/items))
			usr.equipped.suffix = null
			usr.equipped.rem_equip(usr)
		else
			usr.equipped.suffix = null
			usr << "\blue You have unequipped [src]!"
			usr.equipped = null
	if(!s)
		usr << "\blue You have equipped [src]!"
		src.suffix = "\[equipped\]"
		usr.equipped = src

/obj/signal/computer/laptop/verb/unequip()
	set src in usr
	set category = "items"
	usr.equipped.suffix = null
	if(usr.equipped == src)
		usr << "\blue You have unequipped [src]!"
		usr.equipped = null

/obj/signal/computer/laptop/verb/get()
	set src in oview(1)
	set category = "items"

	src.pos_status = 2
	src.invisibility = 0
	src.layer = OBJ_LAYER
	for(var/obj/signal/packet/S in src.loc)
		if (S.master == src)
			S.loc = null
	src.loc = usr

/obj/signal/computer/laptop/verb/drop()
	set src in usr
	set category = "items"

	if (usr.pos_status & 1)
		src.pos_status = 1
		src.invisibility = 98
		src.layer = 21
	src.loc = usr.loc
