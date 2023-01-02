/obj/door
	name = "door"
	icon = 'icons/door.dmi'
	icon_state = "door1_1"
	opacity = TRUE
	density = TRUE
	var/obj/door/connected = null
	var/operating = FALSE

/obj/door/proc/receive(id in view(usr.client))
	if (id == "0")
		if (src.density)
			src.open()
		else
			src.close()
	else
		if (id == "1")
			if (src.density)
				src.open()
		else
			if (!( src.density ))
				src.close()

/obj/door/proc/open()
	if (src.operating)
		return
	src.operating = TRUE
	flick("door1_0", src)
	src.icon_state = "door0_0"
	sleep(6)
	src.density = FALSE
	src.opacity = FALSE
	sleep(2)
	src.operating = FALSE

/obj/door/proc/close()
	set src in oview(1)
	if ((src.operating || src.density))
		return
	src.operating = TRUE
	flick("door0_1", src)
	src.icon_state = "door1_1"
	sleep(2)
	src.density = TRUE
	src.opacity = TRUE
	sleep(6)
	src.operating = FALSE

/obj/door/verb/access(code as text)
	set src in oview(1)

	if (src.connected)
		src.connected.receive(code)
