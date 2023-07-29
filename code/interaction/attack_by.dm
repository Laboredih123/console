/atom/proc/attack_by(obj/using, mob/user)
	return

/atom/proc/attack_hand(mob/user)
	return

/atom/DblClick()
	if (usr.equipped)
		if (get_dist(src, usr) <= 1)
			if (usr)
				src.attack_by(usr.equipped, usr)
	else
		if (usr)
			src.attack_hand(usr)
