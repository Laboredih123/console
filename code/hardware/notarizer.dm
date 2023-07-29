/obj/signal/notarizer
	name = "notarizer"
	icon = 'icons/computer.dmi'
	icon_state = "notorizer"
	density = TRUE
	var/obj/signal/line1 = null

/obj/signal/notarizer/attack_by(obj/items/P, mob/user)
	if (istype(P, /obj/items/paper))
		P.unequip()
		P.loc = null
		src.notorize(P)
		P.loc = src.loc
	else
		..()

/obj/signal/notarizer/disconnectfrom(obj/S)
	if (S == src.line1)
		src.line1 = null

/obj/signal/notarizer/cut()
	if (src.line1)
		src.line1.disconnectfrom(src)
	src.line1 = null

/obj/signal/notarizer/orient_to(obj/target, mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if (src.line1)
		return FALSE
	else
		src.line1 = target
		return TRUE

/obj/signal/notarizer/process_signal(obj/signal/S, obj/source)
	..()
	if(isnull(S))return
	S.loc = null
	S.master = src
	if ((istype(S.cur_file, /datum/file/normal) && !( S.cur_file.flags & 1 )))
		src.file = S.cur_file
		S.cur_file = null
		S.id = "nt_accept"
		S.dest_id = S.source_id
		S.source_id = "notorizer"
		S.params = "success"
		spawn( 2 )
			if (src.line1)
				src.line1.process_signal(S, src)

/obj/signal/notarizer/proc/notorize(obj/items/paper/P)
	if (!( istype(src.file, /datum/file/normal) ))
		return
	else
		var/dat = src.file.text
		var/vn = copytext(dat, 1, findtext(dat, "|", 1, null))
		var/id = copytext(dat, findtext(dat, "|", 1, null) + 1, length(dat) + 1)
		P.data += "[ascii2text(4)]\[n\][vn];[id]"
