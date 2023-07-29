// /obj/signal/dir_ant (DEF)

/obj/signal/dir_ant
	name = "direct antenna"
	icon = 'icons/computer.dmi'
	icon_state = "dir_ant"
	desc = "An antenna that beams info to another direct antenna in it's path."
	anchored = TRUE
	density = TRUE
	var/obj/signal/line1 = null
	var/obj/signal/control = null

/obj/signal/dir_ant/New()
	..()
	src.verbs += /obj/signal/proc/get_me
	src.verbs += /obj/signal/proc/drop_me

/obj/signal/dir_ant/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
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

/obj/signal/dir_ant/d_accept()
	return TRUE

/obj/signal/dir_ant/disconnectfrom(obj/target)
	if (target == src.line1)
		src.line1 = null
	else
		if (target == src.control)
			src.control = null

/obj/signal/dir_ant/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	if (src.control)
		src.control.disconnectfrom(src)
	src.line1 = null
	src.control = null

/obj/signal/dir_ant/process_radio(obj/signal/packet/S, atom/source)
	S.loc = src
	S.master = src
	spawn( 0 )
		if (src.line1)
			src.line1.process_signal(S, src)
		else
			del(S)
/obj/signal/dir_ant/process_signal(obj/signal/packet/S, obj/source)
	..()
	S.loc = null
	S.master = src
	if (source == src.line1)
		var/turf/cur_tile = src.loc
		var/turf/next_tile = get_step(cur_tile,src.dir)
		var/obj/signal/dir_ant/found_ant = locate() in next_tile
		while(!found_ant && next_tile)
			var/turf/last_tile = next_tile
			next_tile = get_step(cur_tile,src.dir)
			cur_tile = last_tile
			found_ant = locate() in next_tile
		if(found_ant)
			var/obj/signal/packet/S1 = new()
			S.copy_to(S1)
			found_ant.process_radio(S1,src)
	else
		if (S.id == "direct")
			var/number = S.params
			if(dir2num(number))
				src.dir = dir2num(number)
		if (S.id == "turn")
			var/number = text2num(S.params)
			switch(number)
				if(45,90,18) src.dir = turn(src.dir, number)
		del(S)

/obj/signal/dir_ant/verb/disconnect(t1 as num)
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

/obj/signal/dir_ant/verb/swap()
	set src in oview(1)
	var/temp = src.line1
	src.line1 = src.control
	src.control = temp
	usr << "I/O line (Now: [src.line1]) swapped with control (Now: [src.control])!"
