/obj/items/ult_check/ult_check
	name = "ultraviolet check"
	icon_state = "ult_check"

/obj/items/ult_check/attack_by(obj/items/paper/P, mob/user)
	if (!( istype(P, /obj/items/paper) ))
		return
	user << browse(P.format(1), "window=[P.name]")


/obj/items/not_check
	name = "notoriety check"
	icon_state = "not_check"
	var/id = null

/obj/items/not_check/attack_by(obj/P, mob/user)
	if (!( istype(P, /obj/items/paper) ))
		return
	src.check(P, user)

/obj/items/not_check/verb/change_id(t as text)
	src.id = t

/obj/items/not_check/proc/check(obj/items/paper/P, user)
	var/notorized = FALSE
	if (findtext(P.data, "[ascii2text(4)]", 1, null))
		var/list/Lines = splittext(P.data, "[ascii2text(4)]")
		for(var/line in Lines)
			if ((line && length(line) > 3))
				var/t_id = copytext(line, 1, 4)
				var/act_t = copytext(line, 4, length(line) + 1)
				if (t_id == "\[n\]")
					if (src.id == (copytext(act_t, findtext(act_t, ";", 1, null) + 1, length(act_t) + 1)))
						notorized = TRUE
						user << "\blue Notoriety found as name: [copytext(act_t, 1, findtext(act_t, ";", 1, null))]"

	if (!notorized)
		user << "\blue Unable to find correct notoriety."
