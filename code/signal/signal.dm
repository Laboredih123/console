/obj/signal
	var/id
	var/dest_id
	var/datum/file/normal/cur_file
	var/params
	var/source_id
	var/atom/master
	var/datum/file/normal/file
	var/list/lines = list()
	var/tmp/max_lines = 1
	var/tmp/swapable = FALSE
	var/tmp/obj/signal/originator
	var/tmp/signal_hit = 0
	var/tmp/max_signal = 150

/obj/signal/New()
	..()
	if(swapable)
		verbs += /obj/signal/proc/swap_line
	var/ml = 1
	while(ml <= max_lines)
		lines += "[ml]"
		lines["[ml]"] = null
		ml++
	START_TRACKING

/obj/signal/Del()
	STOP_TRACKING
	..()

/obj/signal/proc/process_radio(obj/structure, atom/source)
	return

/obj/signal/proc/r_accept(string)
	return FALSE

/obj/signal/proc/d_accept()
	return FALSE

/obj/signal/proc/process_signal(obj/signal/packet/S, atom/source)
	if(signal_hit>=max_signal)
		if(istype(source,/obj/signal/wire))
			//var /area/boom_loc = source.loc
			spawn(0)
				del(source)
				//new /image/boom(loc=boom_loc)
		del(S)
	signal_hit++
	spawn(20)
		signal_hit--
		if(signal_hit<0) signal_hit = 0

/obj/signal/proc/orient_to(obj/target)

/obj/signal/proc/disconnectfrom(obj/source)

/obj/signal/proc/cut()

/obj/signal/Move()
	if(length(lines))
		for(var/obj/signal/S in lines)
			S.cut()
	..()

/obj/signal/attack_by(obj/W, mob/user)
	if (istype(W, /obj/items/wirecutters))
		if ((user.pos_status & 1 && (user.loc != src.loc || src.pos_status & 1)))
			user << "You can only cut from inside a vent if the wire that is right above you!"
			return

		if(istype(src,/obj/signal/concealed_wire))
			var/obj/signal/concealed_wire/W2 = src
			if(!W2.working)
				user << "That terminal isn't active yet, you cannot cut the wires."
				return
			switch(alert(user,"Warning, this will completely remove both terminals, continue?",,"Yes","No"))
				if("No")
					return

		src.cut(user)
	else if (istype(W, /obj/items/wire))
		var/obj/items/wire/I = W
		spawn( 0 )
			if (I)
				I.wire(src, user)
	else if(istype(W,/obj/items/wrench))
		if(src.unlockable)
			if(anchored)
				user << "You unlock [src.name] from its place."
				anchored = FALSE
				density = FALSE
				src.verbs += /obj/signal/proc/get_me
				src.verbs += /obj/signal/proc/drop_me
			else
				user << "You lock [src.name] in place."
				anchored = TRUE
				density = initial(density)
				src.verbs -= /obj/signal/proc/get_me
				src.verbs -= /obj/signal/proc/drop_me
		else
			..()
	else
		..()

/obj/signal/proc/swap_line()
	set name = "swap"
	set src in oview(1,usr)
	var/l1 = input("What is the first line you want to swap?")as null|num
	if(!l1) return
	var/l2 = input("What is the second line you want to swap?")as null|num
	if(!l2) return
	if(l1 <= 0||l1 > max_lines||l2 <= 0||l2 > max_lines)
		usr << "Line range was invalid, try again."
		return
	lines.Swap(l1,l2)
	usr << "Swapped line [l1] (now: [lines["[l1]"]]) with line [l2] (now: [lines["[l2]"]])"
