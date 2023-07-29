

/obj/items/attack_by(obj/items/I, mob/user)
	if (istype(I, /obj/items/lis_bug))
		if (src.b_flags & 1)
			var/obj/items/lis_bug/bug = I
			bug.loc = src
			bug.rem_equip(user)
			bug.master = src
			src.bugs += bug
	else
		if (istype(I, /obj/items/scan_chip))
			if (src.b_flags & 2)
				var/obj/items/scan_chip/chip = I
				chip.loc = src
				chip.rem_equip(user)
				src.bugs += chip
		else
			if (istype(I, /obj/items/bug_scan))
				for(var/obj/items/lis_bug/bug in src.bugs)
					src.bugs -= bug
					bug.master = null
					bug.loc = src.loc
				for(var/obj/items/scan_chip/chip in src.bugs)
					src.bugs -= chip
					chip.loc = src.loc

/obj/items/hear(msg in view(usr.client), source as mob|obj|turf|area in view(usr.client), s_type in view(usr.client), c_mes in view(usr.client), r_src as mob|obj|turf|area in view(usr.client))
	for(var/atom/A in src.bugs)
		A.hear(msg, source, s_type, c_mes, r_src)

/obj/items/verb/get()
	set src in oview(1)
	set category = "items"

	src.pos_status = 2
	src.invisibility = 0
	src.layer = OBJ_LAYER
	src.loc = usr

/obj/items/verb/drop()
	set src in usr
	set category = "items"

	if (usr.pos_status & 1)
		src.pos_status = 1
		src.invisibility = 98
		src.layer = 21
	if (src == usr.equipped)
		src.rem_equip(usr)
	src.loc = usr.loc

/obj/items/verb/equip()
	set src in usr
	set category = "items"
	var/s = FALSE
	if (usr.equipped)
		if(usr.equipped == src) s = TRUE
		if(istype(usr.equipped,/obj/items))
			usr.equipped.rem_equip(usr)
		else
			usr.equipped.suffix = null
			usr << "\blue You have unequipped [src]!"
			usr.equipped = null
	if(!s)
		src.add_equip(usr)

/obj/items/verb/unequip()
	set src in usr
	set category = "items"

	if (usr.equipped)
		usr.equipped.rem_equip(usr)
	else
		usr << "\blue <B>You do not have anything equipped!</B>"


/obj/items/proc/rem_equip(mob/user)
	user.equipped = null
	src.suffix = null
	user << "\blue <B>You have unequipped [src]!</B>"
	return TRUE

/obj/items/proc/add_equip(mob/user)
	user.equipped = src
	src.suffix = "\[equipped\]"
	user << "\blue <B>You have equipped [src]!</B>"
	return TRUE

/obj/items/proc/moved(mob/user, turf/old_loc)
	return
