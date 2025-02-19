/obj/signal/infared
	density = TRUE
	name = "Infared Signaler"
	desc = "Emits a beam in any given direction and sends a signal when the beam is passed."
	icon = 'icons/infared.dmi'

	var/range = 5
	var/active = FALSE
	var/beam_hidden = FALSE
	var/list/beams = list()
	var/obj/signal/line1

/obj/signal/infared/proc/Signal()
	if(line1)
		var/obj/signal/packet/S = new()
		S.id = "signaler"
		line1.process_signal(S,src)
	else
		view(src) << "\icon[src]: *BEEP*"

/obj/signal/infared/proc/moved()
	return TRUE

/obj/signal/infared/process_signal(obj/signal/packet/S)
	..()
	if(isnull(S))
		return
	var/id = S.id
	var/list/params = splittext(S.params,ascii2text(2))

	if(id == "power")
		if(length(params) >= 1)
			if(params[1] == "0")
				src.activate()
			else if(params[1] == "1")
				if(!src.active)
					src.activate()
			else
				if(src.active)
					src.activate()
	if(id == "rotate")
		src.rotate()

	if(id == "visible")
		for(var/obj/infared/beam/B in beams)
			if(beam_hidden)
				B.invisibility = 0
			else
				B.invisibility = 101
		beam_hidden = !beam_hidden

	if(id == "range")
		if(!active)
			var/new_range = text2num(params[1])
			if(new_range <= 0) new_range = 2
			if(new_range > 5) new_range = 5
			range = new_range
	del(S)

/obj/signal/infared/orient_to(obj/target,mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if(src.loc == user) return FALSE
	if(!line1)
		user << "Connected to infared signaler"
		line1 = target
		return TRUE
	else
		return FALSE

/obj/signal/infared/cut()
	if(line1)
		line1.disconnectfrom(src)
	line1 = null

/obj/signal/infared/Move()
	if(!ismob(loc))
		cut()
	..()

/obj/signal/infared/Del()
	cut()
	..()

/obj/signal/infared/verb/equip()
	set src in usr
	set category = "items"
	var/s = FALSE
	if (usr.equipped)
		if(usr.equipped == src) s = TRUE
		if(istype(usr.equipped,/obj/items))
			usr.equipped.rem_equip(usr)
		else
			usr.equipped.suffix = ""
			usr << "\blue <B>You have unequipped [usr.equipped]!</B>"
			usr.equipped = null
	if(!s)
		usr.equipped = src
		usr << "\blue <B>You have equipped [src]!</B>"
		src.suffix = "\[equipped\]"

/obj/signal/infared/verb/unequip()
	set src in usr
	set category = "items"
	if(usr.equipped == src)
		src.suffix = ""
		usr.equipped = null
		usr << "\blue <B>You have unequipped [src]!</B>"

/obj/signal/infared/verb/get()
	set src in oview(1,usr)
	set category = "items"
	if(active)
		src << "You must deactivate it first."
	else
		src.Move(usr)

/obj/signal/infared/verb/drop()
	set src in usr
	set category = "items"
	if(usr.equipped == src)
		src.unequip()
	src.loc = usr.loc

/obj/signal/infared/verb/rotate()
	set src in oview(1,usr)
	if(active)
		usr << "You must deactivate it first."
	else
		src.dir = turn(src.dir,90)

/obj/signal/infared/verb/activate()
	set src in oview(1,usr)
	if(active)
		for(var/obj/infared/beam/B in beams)
			del(B)
		active = FALSE
		icon_state = ""
	else
		icon_state = "on"
		active = TRUE
		var/r = 1
		var/xx = src.x
		var/yy = src.y
		switch(src.dir)
			if(NORTH) yy++
			if(SOUTH) yy--
			if(EAST) xx++
			if(WEST) xx--
		while(r <= range)
			var/turf/N = locate(xx,yy,src.z)
			if(!N||N.density)
				r = range+1
				return
			for(var/atom/O in N)
				if(ismob(O)) continue
				if(O.density)
					r = range+1
					return
			var/obj/infared/beam/B = new(locate(xx,yy,src.z))
			B.dir = get_dir(B,src)
			B.master = src
			switch(src.dir)
				if(NORTH) yy++
				if(SOUTH) yy--
				if(EAST) xx++
				if(WEST) xx--
			beams+=B
			r++

/obj/infared
	icon = 'icons/infared.dmi'
	icon_state = "beam"
	layer = MOB_LAYER+1
	anchored = TRUE

/obj/infared/beam
		name = ""
		var/obj/signal/infared/master

/obj/infared/beam/Crossed(atom/movable/AM)
	if (istype(AM, /obj/infared/beam))
		return
