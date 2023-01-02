/atom/movable/var/tmp/has_teleported = FALSE

/obj/signal/teleport_pad
	icon = 'icons/teleport.dmi'
	icon_state = "active_0"
	name = "Teleport Pad"

	var/destination
	var/identifier
	var/tmp/active = FALSE
	var/tmp/charged = FALSE
	var/tmp/primed = FALSE
	var/tmp/charged_destination
	var/obj/signal/wire/line1

/obj/signal/teleport_pad/proc/Engage(loop=1,dest_or=null)
	var/dest = destination
	if(dest_or) dest = dest_or
	var/obj/signal/teleport_pad/T = locate("teleport_[dest]") in world
	if(T && !ismob(T.loc) && T.identifier)
		if(!T.active)
		/*	T.active = TRUE
			T.charged = TRUE
			T.primed = TRUE
			T.icon_state = "active_3"*/
			for(var/atom/movable/A in src.loc)
				spawn(1)
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
					if(A)
						if(A.has_teleported) continue
						A.loc = T.loc
						A.has_teleported = TRUE
						spawn(10)
							if(A)
								A.has_teleported = FALSE
			if(loop)
				T.Engage(0,src.identifier)
			/*for(var/atom/movable/A in T.loc)
				spawn(1)
					if(istype(A,/obj/signal/structure)) continue
					if(A == T) continue
					if(A)
						if(A.has_teleported) continue
						A.loc = src.loc
						A.has_teleported = TRUE
						spawn(4)
							if(A)
								A.has_teleported = FALSE
			T.active = FALSE
			T.charged = FALSE
			T.primed = FALSE
			T.icon_state = "active_0"
			if(T.line1)
				var/obj/signal/structure/S1 = new /obj/signal/structure( src )
				S1.id = "teleporter"
				S1.params = "incoming"
				T.line1.process_signal(S1,src)*/
	active = FALSE
	charged = FALSE
	primed = FALSE
	icon_state = "active_0"

/obj/signal/teleport_pad/orient_to(obj/target, user as mob)
	if (get_dist(src,user) <= 1)
		if (src.line1)
			return FALSE
		else
			src.line1 = target
			return TRUE
	else
		user << "You must be closer to connect a wire to that!"
		return FALSE

/obj/signal/teleport_pad/process_signal(obj/signal/structure/S,atom/source)
	..()
	if(!S) return

	S.loc = src.loc
	S.master = src
	if(source != line1)
		del(S)
		return
	if(S.id == "prime")
		primed = !primed
		icon_state = "active_[primed]"
		if(!primed) charged = FALSE
		var/obj/signal/structure/S1 = new /obj/signal/structure( src )
		S1.id = "teleporter"
		S1.params = "primed_[primed]"
		if(line1)
			line1.process_signal(S1,src)
	if(S.id == "charge")
		if(primed)
			var/obj/signal/teleport_pad/T = locate("teleport_[destination]") in world
			icon_state = "active_2"
			charged = TRUE
			charged_destination = destination
			if(T)
				if(!T.active)
					T.primed = TRUE
					T.charged = TRUE
					T.icon_state = "active_2"
					T.charged_destination = identifier
			var/obj/signal/structure/S1 = new /obj/signal/structure( src )
			S1.id = "teleporter"
			S1.params = "charged"

			if(line1)
				line1.process_signal(S1,src)
		else
			var/obj/signal/structure/S1 = new /obj/signal/structure( src )
			S1.id = "teleporter"
			S1.params = "charge_failed"
			if(line1)
				line1.process_signal(S1,src)
			flick("not_primed",src)
	if(S.id == "activate")
		if(primed&&charged)
			icon_state = "active_3"
			active = TRUE
			Engage()
			var/obj/signal/structure/S1 = new /obj/signal/structure( src )
			S1.id = "teleporter"
			S1.params = "outgoing:[destination]"
			if(line1)
				line1.process_signal(S1,src)
	if(S.id == "deactivate")
		primed = FALSE
		charged = FALSE
		active = FALSE
		icon_state = "active_0"
		var/obj/signal/structure/S1 = new /obj/signal/structure( src )
		S1.id = "teleporter"
		S1.params = "deactivate"
		if(line1)
			line1.process_signal(S1,src)
	if(S.id == "dest")
		if(S.params)
			destination = "[S.params]"
			var/obj/signal/structure/S1 = new /obj/signal/structure( src )
			S1.id = "teleporter"
			S1.params = "dest_change:[destination]"
			if(line1)
				line1.process_signal(S1,src)
	if(S.id == "ident")
		if(S.params)
			identifier = S.params
			tag = "teleport_[identifier]"
			var/obj/signal/structure/S1 = new /obj/signal/structure( src )
			S1.id = "teleporter"
			S1.params = "ident_change:[identifier]"
			if(line1)
				line1.process_signal(S1,src)
	del(S)

/obj/signal/teleport_pad/New()
				..()
				tag = "teleport_[identifier]"
				icon_state = "active_0"

/obj/signal/teleport_pad/Read()
				..()
				tag = "teleport_[identifier]"
				icon_state = "active_0"
