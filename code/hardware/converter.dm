/obj/signal/converter
	name = "converter"
	icon = 'icons/computer.dmi'
	icon_state = "converter"
	density = TRUE
	place_locked = TRUE
	var/obj/signal/line1 = null
	var/obj/signal/line2 = null

/obj/signal/converter/orient_to(obj/target in view(usr.client),mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if (src.line1)
		if (src.line2)
			return FALSE
		else
			src.line2 = target
	else
		src.line1 = target
	return TRUE

/obj/signal/converter/disconnectfrom(obj/source as obj in view(usr.client))
	if (src.line1 == source)
		src.line1 = null
	else
		src.line2 = null

/obj/signal/converter/process_signal(obj/signal/structure/S as obj in view(usr.client), obj/source as obj in view(usr.client))
	..()
	if(isnull(S))return
	S.loc = src.loc
	S.master = src
	if (source == src.line1)
		spawn( 10 )
			if (!( src.line2 ))
				del(S)
			else
				src.line2.process_signal(S, src)
	else
		spawn( 10 )
			if (!( src.line1 ))
				del(S)
			else
				src.line1.process_signal(S, src)

/obj/signal/converter/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	if (src.line2)
		src.line2.disconnectfrom(src)
	src.line1 = null
	src.line2 = null
