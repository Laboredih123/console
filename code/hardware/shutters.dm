/obj/signal/shutter_box
	name = "Shutter Control"
	icon = 'icons/computer.dmi'
	icon_state = "box"

	var/obj/signal/line1
	var/range = 5

/obj/signal/shutter_box/New()
	..()
	icon += rgb(0,0,75)

/obj/signal/shutter_box/orient_to(obj/target,mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if(line1)
		return FALSE
	else
		if(src.loc != user.loc)
			user << "You must be standing on the same tile as [src] to connect wires."
			return FALSE
		else
			line1 = target
			user << "Connected to shutter control box."
			return TRUE

/obj/signal/shutter_box/cut()
	if(line1)
		line1.disconnectfrom(src)
	line1 = null

/obj/signal/shutter_box/process_signal(obj/signal/structure/S,obj/source)
	..()
	if(isnull(S))return
	S.loc = src.loc
	S.master = src
	if(S.id == "toggle")
		for(var/obj/shutter/ST in view(src,range))
			ST.Open()
	if(S.id == "open")
		for(var/obj/shutter/ST in view(src,range))
			ST.Open(1)
	del(S)

/obj/signal/shutter_box/verb/open()
	set src in view(1,usr)
	for(var/obj/shutter/ST in view(src,range))
		if(ST.icon_state != "open")
			ST.Open()

/obj/signal/shutter_box/verb/close()
	set src in view(1,usr)
	for(var/obj/shutter/ST in view(src,range))
		if(ST.icon_state == "open")
			ST.Open()

/obj/shutter
	name = "Window Shutter"
	icon = 'icons/shutter.dmi'
	icon_state = "closed"
	density = TRUE
	opacity = TRUE
	layer = OBJ_LAYER-1

	var/pcode

/obj/shutter/proc/Open(var/force)
	if(icon_state == "open"||force==2)
		icon_state = "closed"
		opacity = TRUE
		density = TRUE
	else
		icon_state = "open"
		opacity = FALSE
		density = FALSE
