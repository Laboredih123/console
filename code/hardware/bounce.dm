// /obj/signal/bounce (DEF)

/obj/signal/bounce
	name = "bounce"
	icon = 'icons/computer.dmi'
	desc = "After 2 ticks, echoes the signal back."
	icon_state = "bounce"
	var/obj/signal/line1 = null

/obj/signal/bounce/disconnectfrom(S)
	if (S == src.line1)
		src.line1 = null

/obj/signal/bounce/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	src.line1 = null

/obj/signal/bounce/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if (get_dist(src,user)<=1)
		if (src.line1)
			return FALSE
		else
			src.line1 = target
			return TRUE
	else
		user << "You are not close enough to connect to that device."
		return FALSE

/obj/signal/bounce/process_signal(S, source)
	..()
	if(isnull(S))return
	spawn( 2 )
		if (src.line1)
			src.line1.process_signal(S, src)

/obj/signal/bounce/verb/get()
	set src in oview(usr,1)
	set category = "items"

	src.pos_status = 2
	src.invisibility = 0
	src.layer = OBJ_LAYER
	cut()
	src.loc = usr

/obj/signal/bounce/verb/drop()
	set src in usr
	set category = "items"

	if (usr.pos_status & 1)
		src.pos_status = 1
		src.invisibility = 98
		src.layer = 21
	src.loc = usr.loc
