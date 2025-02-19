/obj/signal/hub
	name = "hub"
	icon = 'icons/computer.dmi'
	icon_state = "hub"
	density = TRUE
	anchored = TRUE
	var/offset = 0
	var/multi = 20
	var/s_id = "router"
	var/d_id = "0"
	var/obj/signal/line1 = null
	var/obj/signal/line2 = null
	var/obj/signal/line3 = null
	var/obj/signal/line4 = null
	var/obj/signal/line5 = null
	var/obj/signal/line_temp = null
	var/obj/signal/line_control = null
	var/position = 1

/obj/signal/hub/process_signal(obj/signal/packet/S, obj/source)
	..()
	if(!S) return
	S.loc = src.loc
	if (source != src.line_control)
		var/list/L = list( "line1", "line2", "line3", "line4", "line5" )
		for(var/x in L)
			if (src.vars[x] == source)
				L -= x

		spawn(1)
			for(var/x in L)
				if(!S) return
				var/obj/signal/packet/S1 = new/obj/signal/packet()
				S.copy_to(S1)
				S1.strength--
				if (S1.strength <= 0)
					del(S1)
					return
				var/obj/signal/packet/S2 = src.vars[x]
				spawn( 0 )
					if (S2)
						S2.process_signal(S1, src)
				sleep(1)
			del(S)

/obj/signal/hub/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return 0
	if (!( src.line1 ))
		src.line1 = target
		user << "Connection port: Line 1 (1)"
		return TRUE
	else
		if (!( src.line2 ))
			src.line2 = target
			user << "Connection port: Line 2 (2)"
			return TRUE
		else
			if (!( src.line3 ))
				src.line3 = target
				user << "Connection port: Line 3 (3)"
				return TRUE
			else
				if (!( src.line4 ))
					src.line4 = target
					user << "Connection port: Line 4 (4)"
					return TRUE
				else
					if (!( src.line5 ))
						src.line5 = target
						user << "Connection port: Line 5 (5)"
						return TRUE
					else
						if (!( src.line_temp ))
							src.line_temp = target
							user << "Connection port: Line Action (6)"
							return TRUE
						else
							if (!( src.line_control ))
								src.line_control = target
								user << "Connection port: Line Control (7)"
								return TRUE
	return FALSE

/obj/signal/hub/disconnectfrom(obj/source)
	if (src.line1 == source)
		src.line1 = null
	else
		if (src.line2 == source)
			src.line2 = null
		else
			if (src.line3 == source)
				src.line3 = null
			else
				if (src.line4 == source)
					src.line4 = null
				else
					if (src.line5 == source)
						src.line5 = null
					else
						if (src.line_temp == source)
							src.line_temp = null
						else
							if (src.line_control == source)
								src.line_control = null

/obj/signal/hub/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	if (src.line2)
		src.line2.disconnectfrom(src)
	if (src.line3)
		src.line3.disconnectfrom(src)
	if (src.line4)
		src.line4.disconnectfrom(src)
	if (src.line5)
		src.line5.disconnectfrom(src)
	if (src.line_temp)
		src.line_temp.disconnectfrom(src)
	if (src.line_control)
		src.line_control.disconnectfrom(src)
	src.line1 = null
	src.line2 = null
	src.line3 = null
	src.line4 = null
	src.line5 = null
	src.line_temp = null
	src.line_control = null

/obj/signal/hub/Move()
	..()
	if(line1) line1.cut()
	if(line2) line2.cut()
	if(line3) line3.cut()
	if(line4) line4.cut()
	if(line5) line5.cut()
	if(line_control) line_control.cut()
	if(line_temp) line_temp.cut()

/obj/signal/hub/verb/swap(n1 as num, n2 as num)
	set src in oview(1)
	set desc = "6=line_action, 7 = line_control"

	if (n1 == 6)
		n1 = "line_temp"
	else
		if (n1 == 7)
			n1 = "line_control"
		else
			if ((n1 > 0 && n1 <= 5))
				n1 = "line[round(n1)]"
			else
				return
	if (n2 == 6)
		n2 = "line_temp"
	else
		if (n2 == 7)
			n2 = "line_control"
		else
			if ((n2 > 0 && n2 <= 5))
				n2 = "line[round(n2)]"
			else
				return
	var/temp = src.vars[n1]
	src.vars[n1] = src.vars[n2]
	src.vars[n2] = temp
	var/obj/O1 = src.vars[n1]
	var/obj/O2 = src.vars[n2]
	usr << "[n1] (Now:[(O1 ? O1.name : "null")]) swapped with [n2] (Now:[(O2 ? O2.name : "null")])"

/obj/signal/hub/verb/disconnect()
	set src in oview(1)

	var/choice = input("Which line would you like to disconnect? 1-6 (6=control)", "Hub", null, null)  as num
	switch(choice)
		if(1)
			if (src.line1)
				src.line1.disconnectfrom(src)
			src.line1 = null
		if(2)
			if (src.line2)
				src.line2.disconnectfrom(src)
			src.line2 = null
		if(3)
			if (src.line3)
				src.line3.disconnectfrom(src)
			src.line3 = null
		if(4)
			if (src.line4)
				src.line4.disconnectfrom(src)
			src.line4 = null
		if(5)
			if (src.line5)
				src.line5.disconnectfrom(src)
			src.line5 = null
		if(6)
			if (src.line_temp)
				src.line_temp.disconnectfrom(src)
			src.line_temp = null
		if(7)
			if (src.line_control)
				src.line_control.disconnectfrom(src)
			src.line_control = null

/obj/signal/hub/mini
	density = FALSE
	name = "Mini Hub"
	max_signal = 10
	icon = 'icons/mini.dmi'
	icon_state = "hub"
	unlockable = TRUE
	anchored = FALSE

/obj/signal/hub/mini/New()
	..()
	if(!anchored)
		verbs += /obj/signal/proc/get_me
		verbs += /obj/signal/proc/drop_me

/obj/signal/hub/router

/obj/signal/hub/router/New()
	..()
	if(!anchored)
		verbs += /obj/signal/proc/get_me
		verbs += /obj/signal/proc/drop_me

/obj/signal/hub/router/mini
	density = FALSE
	name = "Mini Router"
	max_signal = 10
	icon = 'icons/mini.dmi'
	icon_state = "router"
	unlockable = TRUE
	anchored = FALSE
