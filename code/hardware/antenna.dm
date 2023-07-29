/obj/signal/antenna
	name = "antenna"
	icon = 'icons/computer.dmi'
	icon_state = "antenna"
	density = TRUE
	anchored = TRUE
	var/broadcasting = FALSE
	var/obj/signal/line1 = null
	var/obj/signal/control = null
	var/e_key = "1"

/obj/signal/antenna/New()
	..()
	src.verbs += /obj/signal/proc/get_me
	src.verbs += /obj/signal/proc/drop_me

/obj/signal/antenna/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return 0
	if (!( src.line1 ))
		src.line1 = target
		user << "Connected to antenna:I/O"
		return TRUE
	else
		if (!( src.control ))
			user << "Connected to antenna:control"
			src.control = target
			return TRUE
		else
			return FALSE

/obj/signal/antenna/disconnectfrom(obj/target)
	if (target == src.line1)
		src.line1 = null
	else
		if (target == src.control)
			src.control = null

/obj/signal/antenna/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	if (src.control)
		src.control.disconnectfrom(src)
	src.line1 = null
	src.control = null

/obj/signal/antenna/r_accept(string, source)
	var/list/ekeys = params2list(src.e_key)
	if(!ekeys) return FALSE
	if (string in ekeys)
		return TRUE
	else
		return FALSE

/obj/signal/antenna/process_signal(obj/signal/packet/S, obj/source)
	..()
	if(isnull(S))return
	if(istype(src,/obj/signal/antenna/dish)) return
	S.loc = null
	S.master = src
	if (src.broadcasting)
		del(S)
		return
	src.broadcasting = TRUE
	if (source == src.line1)
		for(var/obj/signal/C as anything in by_type[/obj/signal])
			if ((get_dist(C.loc, src.loc) <= 50 && C != src))
				var/a = FALSE
				var/list/my_ekeys = params2list(src.e_key)
				for(var/E in my_ekeys)
					if(C.r_accept(E,src))
						a = TRUE
				if (a)
					var/obj/signal/packet/S1 = new /obj/signal/packet()
					S.copy_to(S1)
					S1.strength -= 2
					if (S1.strength <= 0)
						del(S1)
						return
					missile(/obj/radio, src.loc, C.loc)
					spawn( 0 )
						C.process_radio(S1,src)

	else
		if (S.id == "e_key")
			var/number
			var/list/my_ekeys = params2list(S.params)
			if(length(my_ekeys) > 5) my_ekeys.Cut(6)
			for(var/E in my_ekeys)
				var/b = FALSE
				if(my_ekeys.Find(E) < length(my_ekeys)) b = TRUE
				E = text2num(E)
				E = round(min(max(1, E), 65000))
				number += "[E]"
				if(b) number += ";"
			src.e_key = "[number]"
	del(S)
	sleep(5)
	src.broadcasting = FALSE

/obj/signal/antenna/process_radio(obj/signal/packet/S, atom/source)
	S.loc = src
	S.master = src
	spawn( 0 )
		if (src.line1)
			src.line1.process_signal(S, src)
		else
			del(S)


/obj/signal/antenna/verb/disconnect(t1 as num)
	set desc = "1 for I/O, 2 for control"

	if (t1 == 1)
		if (src.line1)
			src.line1.disconnectfrom(src)
		src.line1 = null
	else
		if (t1 == 2)
			if (src.control)
				src.control.disconnectfrom(src)
			src.control = null

/obj/signal/antenna/verb/swap()
	set src in oview(1)

	var/temp = src.line1
	src.line1 = src.control
	src.control = temp
	usr << "I/O line (Now: [src.line1]) swapped with control (Now: [src.control])!"
