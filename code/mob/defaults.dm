/mob
	name = "mob"
	icon = 'icons/asdf.dmi'
	density = TRUE
	layer = 4
	pos_status = 2

	var/obj/items/equipped = null
	var/echo2console = 1
	var/saving = FALSE
	var/tmp/obj/signal/computer/using_computer = null
	var/tmp/obj/signal/computer/using_laptop = null
	var/tmp/atom/vblock = null
	var/bugs = list()
	var/save_version = 0

/mob/New()
	..()
	START_TRACKING

/mob/Del()
	STOP_TRACKING
	..()

/mob/attack_by(obj/D, mob/user)
	if (istype(D, /obj/items/lis_bug))
		var/obj/items/lis_bug/S = D
		S.loc = null
		S.rem_equip(user)
		S.master = src
		src.bugs += S
	else
		if (istype(D, /obj/items/scan_chip))
			var/obj/items/scan_chip/S = D
			S.loc = null
			S.rem_equip(user)
			src.bugs += S
		else
			if (istype(D, /obj/items/bug_scan))
				for(var/obj/items/lis_bug/I in src.bugs)
					src.bugs -= I
					I.master = null
					I.loc = src.loc

/mob/Login()
	if (src.icon_state == "" || src.icon_state == "null")
		src.icon_state = src.gender
	src.loc = locate(/area/start)
	src.rname = src.key

	src << motd
	..()

/mob/Stat()
	statpanel("Inventory", null, src.contents)

/mob/hear(msg in view(usr.client), source as mob|obj|turf|area in view(usr.client), s_type in view(usr.client), c_mes in view(usr.client), r_src as mob|obj|turf|area in view(usr.client))
	src << msg
	for(var/obj/items/lis_bug/L in src.bugs)
		L.hear(msg, source, s_type, c_mes, r_src)
