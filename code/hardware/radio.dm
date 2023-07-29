/obj/radio
	name = "radio"
	icon = 'icons/misc.dmi'
	icon_state = "radio"

/obj/radio/direct
	name = "direct radio"
	var/data = null

/obj/radio/direct/proc/process()
	step(src, src.dir)
	for(var/obj/signal/S in src.loc)
		if (S.d_accept())
			S.process_radio(src.data,src)
			src.data = null
			del(src)
			return

	if ((src.y == 1 || (src.y == world.maxy || (src.x == 1 || src.x == world.maxx))))
		del(src)
		return
	spawn( 1 )
		src.process()

/obj/radio/direct/Del()
	del(src.data)
	..()
