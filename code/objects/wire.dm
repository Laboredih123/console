/obj/items/wire
	desc = "This is just a simple piece of regular insulated wire."
	name = "wire"
	icon_state = "item_wire"
	var/amount = 1
	var/laying = FALSE
	var/obj/signal/old_lay = null
	var/scolor = "black"
	var/label

/obj/items/wire/New()
	..()
	if(!scolor) scolor = "black"
	if(src.type == /obj/signal/wire/hyper||src.type == /obj/items/wire/hyper)
		scolor = "hyper"
		src.verbs -= /obj/items/wire/verb/Color_Wire
	src.update()

/obj/items/wire/attack_by(obj/P, mob/user)
	if ((istype(P, /obj/items/paint) && src.loc == user))
		var/i = input(user, "What color?", "Paint", null) in list( "black", "red", "blue", "green" )
		if ((src.loc == user && P.loc == user))
			src.scolor = i
		src.update()

/obj/items/wire/verb/Color_Wire()
	set src in usr
	if(!ismob(src.loc)) return
	var/n_color = input("What color do you want to make the wire?")as null|anything in list("red","green","blue","black")
	if(!n_color) return
	scolor = "[n_color]"
	update()

/obj/items/wire/verb/Label_Wire(T as text)
	set src in usr
	if(!ismob(src.loc)) return
	label = "[T]"
	var/n = "wire"
	if(src.type == /obj/signal/wire/hyper||src.type == /obj/items/wire/hyper) n = "hyper"
	if(!T)
		src.name = n
		label = null
	else
		src.name = "[n] '[label]'"

/obj/items/wire/verb/stop_laying()
	if (src.laying)
		src.laying = FALSE
		usr << "Your done laying wire!"
	else
		usr << "You are not using this to lay wire..."

/obj/items/wire/verb/thread()
	set src in usr
	for(var/obj/items/wire/target in src.loc)
		if (target != src && src.type == target.type&&src.scolor==target.scolor)
			src.amount += target.amount
			src.scolor = target.color
			if (usr.equipped == target)
				target.rem_equip(usr)
			del(target)
	src.update()

/obj/items/wire/Write(F)
	src.old_lay = null
	..(F)

/obj/items/wire/rem_equip()
	..()
	src.stop_laying()

/obj/items/wire/moved(mob/user, turf/old_loc)
	if ((src.laying && (src.old_lay && get_dist(src.old_lay, user) > 1)))
		src.laying = FALSE
	if ((src.laying && (src.amount >= 1 && src.old_lay)))
		var/obj/signal/wire/W = new /obj/signal/wire( user.loc )
		if (src.scolor)
			switch(src.scolor)
				if("blue")
					W.icon = 'icons/b_wire.dmi'
				if("green")
					W.icon = 'icons/g_wire.dmi'
				if("red")
					W.icon = 'icons/r_wire.dmi'
				if("hyper")
					W.icon = 'icons/hyperwire.dmi'
				if("black")
					W.icon = 'icons/wire.dmi'
		if (user.pos_status & 1)
			W.invisibility = 98
			W.pos_status = 1
			W.layer = 21
		if(label)
			W.name = "wire '[label]'"
			W.label = label
		var/t1 = src.old_lay.orient_to(W, user)
		var/t2 = W.orient_to(src.old_lay, user)
		if ((t1 && t2))
			src.old_lay = W
			src.amount--
			if (src.amount <= 0)
				src.laying = FALSE
				del(src)
				return
			src.update()
		else
			del(W)
			user << "<B>You were unable to connect the wire to the target!</B>"
			src.laying = FALSE

/obj/items/wire/proc/wire(obj/signal/target, mob/user)
	if (!(istype(target)))
		return
	if ((!( target.pos_status & user.pos_status ) && target.loc != user.loc))
		user << "You must be on the same tile to bridge a connection into the vents."
		return
	if (!( src.laying ))
		if (istype(target, /obj/signal/wire))
			var/colorofcable
			switch(target.icon)
				if('icons/b_wire.dmi')
					colorofcable = "blue"
				if('icons/g_wire.dmi')
					colorofcable = "green"
				if('icons/r_wire.dmi')
					colorofcable = "red"
				if('icons/hyperwire.dmi')
					colorofcable = "hyper"
				if('icons/wire.dmi')
					colorofcable = "black"
			if (colorofcable != src.scolor)
				user << "The color doesn't match!"
				return
		src.laying = TRUE
		src.old_lay = target
		moved(user, null)
	else
		src.laying = FALSE
		if(target)
			if ((src.old_lay.orient_to(target) && target.orient_to(src.old_lay, user)))
				user << "Your done laying wire!"
			else
				src.old_lay.disconnectfrom(target)
				target.disconnectfrom(src.old_lay)

/obj/items/wire/proc/update()
	if (src.amount > 1)
		src.icon_state = "spool_[src.scolor]wire"
		src.desc = "This is just spool of regular insulated wire. It consists of about [src.amount] unit\s of wire."
	else
		src.icon_state = "item_[src.scolor]wire"
		src.desc = "This is just a simple piece of regular insulated wire."

/obj/items/wire/MouseDrop(obj/items/wire/target in view(usr.client), t1 in view(usr.client), t2 in view(usr.client))
	if (!( target ))
		return
	if ((t1 != "Inventory" || (t2 != "Inventory" || src.type != target.type)))
		return
	else
		if (target != src)
			src.amount += target.amount
			if (usr.equipped == target)
				target.rem_equip(usr)
			del(target)
			src.update()

/obj/items/wire/hyper
	name = "hyper"
	icon_state = "item_hyperwire"
	scolor = "hyper"
