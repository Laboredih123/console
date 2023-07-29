

/obj/items/ConveyorParts
	name = "Conveyor Parts"
	icon = 'icons/conveyor_parts.dmi'
	desc = "Use by itself to create a lone conveyor, or hit another conveyor to connect it"
	suffix = "\[1\]"
	var/stack = 1

/obj/items/ConveyorParts/New()
	..()
	spawn(10)
		suffix = "\[[stack]\]"

/obj/items/ConveyorParts/attack_hand(mob/user)
	new /obj/signal/Conveyor(user.loc)
	stack--
	if (stack <= 0)
		del(src)

/obj/signal/Conveyor
	name = "Conveyor Belt"
	icon = 'icons/conveyor_belt.dmi'
	icon_state = "inactive"
	desc = "Hit with a wrench to rotate. Hit with a screwdriver to remove."
	anchored = TRUE

	var/tmp/active = FALSE
	var/tmp/deleting = FALSE
	var/tmp/full_delete = FALSE
	var/delay = 10
	var/list/connected = list()
	var/flipped = FALSE
	var/pushdir

/obj/signal/Conveyor/New()
	..()
	src.update_pushdir()

/obj/signal/Conveyor/attack_by(obj/using, mob/user)
	if(istype(using,/obj/items/wrench))
		src.dir = turn(src.dir, -45)
		src.update_pushdir()
	if(istype(using,/obj/items/screwdriver))
		del(src)
	if(istype(using, /obj/items/wirecutters))
		src.Toggle_Line()
	if(istype(using, /obj/items/toolbox))
		flipped = !flipped
		src.icon_state = "[active ? "": "in"]active[flipped ? "-flipped" : ""]"
		src.update_pushdir()
	if(istype(using, /obj/items/ConveyorParts))
		var/obj/items/ConveyorParts/C = using
		var/list/valid_directions = list(NORTH,SOUTH,EAST,WEST)
		if(!valid_directions.Find(get_dir(src,user)))
			user << "Diagonal conveyor belts are not supported, sorry!"
			return
		if(length(src.connected) >= 2)
			user << "There's nowhere to hook them up!"
		else
			var/obj/signal/Conveyor/NewBelt = new(usr.loc)
			src.connected += NewBelt
			NewBelt.connected += src
			C.stack--
			if(C.stack <= 0)
				del(C)
			else
				C.suffix = "\[[C.stack]\]"
	else
		..()

/obj/signal/Conveyor/examine()
	. = ..()
	. += "Its going [num2dir(pushdir)]."
	. += "Its dir is [num2dir(dir)]."

/obj/signal/Conveyor/proc/Activate_Line(obj/signal/Conveyor/caller)
	active = TRUE
	src.icon_state = "active[flipped ? "-flipped" : ""]"

	for (var/obj/signal/Conveyor/belt in connected)
		if (belt == caller)
			continue
		belt.Activate_Line(src)

/obj/signal/Conveyor/proc/Deactivate_Line(obj/signal/Conveyor/caller)
	active = FALSE
	src.icon_state = "inactive[flipped ? "-flipped" : ""]"

	for (var/obj/signal/Conveyor/belt in connected)
		if (belt == caller)
			continue
		belt.Deactivate_Line(src)

/obj/signal/Conveyor/proc/Toggle_Line(obj/signal/Conveyor/caller)
	active = !active
	src.icon_state = "[active ? "": "in"]active[flipped ? "-flipped" : ""]"

	for (var/obj/signal/Conveyor/belt in connected)
		if (belt == caller)
			continue
		belt.Toggle_Line(src)

/obj/signal/Conveyor/proc/update_pushdir()
	var/flippeddir
	switch(dir)
		if(NORTH)
			pushdir = NORTH
			flippeddir = SOUTH
		if(SOUTH)
			pushdir = SOUTH
			flippeddir = NORTH
		if(EAST)
			pushdir = EAST
			flippeddir = WEST
		if(WEST)
			pushdir = WEST
			flippeddir = EAST
		if(NORTHEAST)
			pushdir = EAST
			flippeddir = SOUTH
		if(NORTHWEST)
			pushdir = NORTH
			flippeddir = EAST
		if(SOUTHEAST)
			pushdir = SOUTH
			flippeddir = WEST
		if(SOUTHWEST)
			pushdir = WEST
			flippeddir = NORTH
	if (flipped)
		pushdir = flippeddir

/obj/signal/Conveyor/Crossed()
	if (!active)
		return
	sleep(delay)
	for (var/atom/movable/AM in src.loc)
		if (AM.anchored)
			continue
		step(AM, pushdir)

/obj/signal/Conveyor/orient_to(obj/target, mob/user)
	if (get_dist(src,user) <= 1)
		if (length(src.connected) >= 2)
			user << "That belt has no free connection ports!"
			return FALSE
		else
			src.connected += target
			return TRUE

/obj/signal/Conveyor/Del()
	for (var/obj/signal/obj as anything in connected)
		obj.disconnectfrom(src)
		src.connected -= obj
	..()

/obj/signal/Conveyor/process_signal(obj/signal/packet/S, obj/source)
	..()
	switch (S.id)
		if("activate")
			if (!active)
				Activate_Line()

		if("deactivate")
			if (active)
				Deactivate_Line()

		if("toggle-power")
			Toggle_Line()

		if("delay")
			var/new_speed = text2num(S.params)
			if(new_speed <= 0) new_speed = 1
			if(new_speed >= 15) new_speed = 15
			delay = new_speed
	del(S)

/obj/signal/Conveyor/cut()
	for(var/obj/signal/wire/W in connected)
		W.cut()

/obj/signal/Conveyor/disconnectfrom(obj/S)
	if (S in connected)
		connected -= S


/obj/signal/antenna/Move()
	..()
	if(line1) line1.cut()
	if(control) control.cut()

/obj/signal/dir_ant/Move()
	..()
	if(line1) line1.cut()
	if(control) control.cut()

/obj/signal/microphone/Move()
	..()
	if(line1) line1.cut()

/obj/signal/infared/Move()
	..()
	if(line1) line1.cut()

/obj/signal/teleport_pad/Move()
	..()
	if(line1) line1.cut()

/obj/signal/bounce/Move()
	..()
	if(line1) line1.cut()

/obj/signal/concealed_wire/Move()
	..()
	for(var/obj/signal/wire/W in connected_wires)
		W.cut()
