

/obj/items/ConveyorParts
	name = "Conveyor Parts"
	icon = 'icons/conveyor_parts.dmi'
	suffix = "\[1\]"
	var/stack = 1

/obj/items/ConveyorParts/New()
	..()
	spawn(10)
		suffix = "\[[stack]\]"

/obj/items/ConveyorParts/attack_by(obj/using,mob/user)
	new /obj/signal/Conveyor/Belt(user.loc)
	user << "Now equip the parts and double click an existing belt to place new belts on that line."

/obj/signal/Conveyor

/obj/signal/Conveyor/Belt
	dir = NORTH
	icon_state = "1"
	name = "Conveyor Belt"
	icon = 'icons/conveyor_belt.dmi'
	var/tmp/active = 0
	var/tmp/deleting = 0
	var/tmp/full_delete = 0
	var/delay = 5
	var/list/connected = list()

/obj/signal/Conveyor/Belt/attack_by(obj/using, mob/user)
	if(istype(using,/obj/items/wrench))
		full_delete = 1
		del(src)
	if(istype(using,/obj/items/screwdriver))
		del(src)
	if(istype(using,/obj/items/ConveyorParts))
		var/obj/items/ConveyorParts/C = using
		var/list/valid_directions = list(NORTH,SOUTH,EAST,WEST)
		if(!valid_directions.Find(get_dir(src,user)))
			user << "Diagonal conveyor belts are not supported, sorry!"
			return
		if(connected.len >= 2)
			user << "There's nowhere to hook them up!"
		else
			var/obj/signal/Conveyor/Belt/NewBelt = new(usr.loc)
			AddBelt(NewBelt)
			C.stack--
			if(C.stack <= 0)
				del(C)
			else
				C.suffix = "\[[C.stack]\]"
	else
		..()

/obj/signal/Conveyor/Belt/Del()
	deleting = 1
	for(var/obj/signal/Conveyor/Belt/B in connected)
		if(full_delete)
			if(B.deleting) continue
			B.full_delete = 1
			del(B)
		else
			B.RemoveBelt(src)
			B.autojoin()

	..()

/obj/signal/Conveyor/Belt/proc/autojoin()
	var/int = 0
	for(var/obj/signal/Conveyor/Belt/B in connected)
		int |= get_dir(src,B)
	icon_state = "[int]"

/obj/signal/Conveyor/Belt/proc/AddBelt(obj/signal/Conveyor/Belt/B)
	connected += B
	B.connected += src
	autojoin()
	B.autojoin()

/obj/signal/Conveyor/Belt/proc/RemoveBelt(obj/signal/Conveyor/Belt/B)
	connected -= B
	B.connected -= src
	autojoin()
	B.autojoin()

/obj/signal/Conveyor/Belt/proc/Activate()
	if(active) return
	active = 1
	spawn(20)
		active = 0
	PushTo(null)

/obj/signal/Conveyor/Belt/proc/PushTo(obj/signal/Conveyor/pushed_from,push_delay)
	var/obj/signal/Conveyor/Belt/push_to
	src.icon = 'icons/conveyor_belt_active.dmi'
	for(var/obj/signal/Conveyor/Belt/connect in connected)
		if(pushed_from == connect) continue
		else push_to = connect
	if(push_to)
		for(var/atom/movable/A in src.loc)
			if(istype(A,/obj/signal/structure)) continue
			if(A == src) continue
			if(istype(A,/obj/signal/infared))
				var/obj/signal/infared/I = A
				if(I.active) continue
			if(istype(A,/obj/signal/wire)) continue
			if(istype(A,/obj/infared)) continue
			if(istype(A,/obj/door)) continue
			if(istype(A,/obj/signal/box)) continue
			if(istype(A,/obj/signal/Conveyor)) continue
			if(istype(A,/obj/signal/sign_box)) continue
			step(A,get_dir(src,push_to))
		if(!push_delay) push_delay = delay
		spawn(push_delay)
			if(push_to)
				push_to.PushTo(src,push_delay)
	spawn(10)
		src.icon = 'icons/conveyor_belt.dmi'

/obj/signal/Conveyor/Belt/orient_to(obj/target in view(usr.client), user as mob in view(usr.client))
	if (get_dist(src,user) <= 1)
		if (src.connected.len >= 2)
			user << "That belt has no free connection ports!"
			return 0
		else
			src.connected += target
			return 1

/obj/signal/Conveyor/Belt/process_signal(obj/signal/structure/S, obj/source)
	..()
	if(S.id == "activate")
		spawn(1) Activate()
	else if(S.id == "delay")
		var/new_speed = text2num(S.params)
		if(new_speed <= 0) new_speed = 1
		if(new_speed >= 15) new_speed = 15
		delay = new_speed
	del(S)

/obj/signal/Conveyor/Belt/cut()
	for(var/obj/signal/wire/W in connected)
		W.cut()

/obj/signal/Conveyor/Belt/disconnectfrom(obj/S)
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
