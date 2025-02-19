/obj/signal/box
	name = "box"
	icon = 'icons/computer.dmi'
	icon_state = "box"
	anchored = TRUE
	id = "0"

	var/keycode = null
	var/doorcode_ref = null
	var/obj/door/connected = null
	var/s_id = "0"
	var/d_id = "0"
	var/d_dir = 10
	var/obj/signal/line1 = null
	var/open_lab = FALSE

/obj/signal/box/New()
	if (!( src.connected ))
		src.connected = new /obj/door( get_step(src, src.d_dir) )
		src.connected.connected = src
		src.connected.dir = src.dir
		if(open_lab)
			connected.open()
	..()

/obj/signal/box/Initialize()
	// If doorcode_ref is present in the door_codes.json config then set the default keycode from it.
	if (doorcode_ref != null)
		if (door_codes[doorcode_ref] != null)
			src.keycode = door_codes[doorcode_ref]
	..()

/obj/signal/box/disconnectfrom(obj/S)
	if (S == src.line1)
		src.line1 = null

/obj/signal/box/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	src.line1 = null

/obj/signal/box/orient_to(obj/target, mob/user)
	if (target.loc == src.loc)
		if (src.line1)
			return FALSE
		else
			src.line1 = target
			return TRUE
	else
		user << "You must be on the same tile of this to operate it."

/obj/signal/box/process_signal(obj/signal/packet/S, obj/source)
	..()
	if(isnull(S))return
	spawn( 2 )
		if (S.id == "door")
			src.connected.receive(S.params)
		else
			if (S.id == "pass")
				src.keycode = S.params
			else
				if (S.id == "dest_id")
					src.d_id = S.params
				else
					if (S.id == "drc_id")
						src.s_id = S.params
		del(S)

/obj/signal/box/proc/receive(code in view(usr.client))
	if (src.line1)
		var/obj/signal/packet/S1 = new /obj/signal/packet( src )
		S1.id = "dqry"
		S1.dest_id = src.d_id
		S1.source_id = src.s_id
		S1.params = code
		spawn( 0 )
			src.line1.process_signal(S1, src)
	else
		if (src.keycode == code)
			spawn( 0 )
				src.connected.receive("0")

/obj/signal/box/verb/open()
				set src in usr.loc
				src.connected.receive("1")

/obj/signal/box/verb/close()
				set src in usr.loc
				src.connected.receive("-1")
