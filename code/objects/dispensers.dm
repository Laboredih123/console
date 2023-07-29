/obj/electronic
	name = "electronic"
	icon = 'icons/objects.dmi'
	icon_state = "e_convey"

/obj/electronic/New()
	new /obj/items/monitor( src )
	new /obj/items/computer( src )
	new /obj/signal/computer/laptop( src )

/obj/electronic/verb/dispense(obj/O in src)
	set src in oview(1)

	flick("e_convey1", src)
	sleep(10)
	var/I = new O.type( src.loc )
	if(istype(I,/obj/signal))
		var/obj/signal/T = I
		T.anchored = FALSE
		T.density = FALSE
		T.verbs += /obj/signal/proc/get_me
		T.verbs += /obj/signal/proc/drop_me
	usr << "[I] has been created!"
	step(I, NORTH)


/obj/conveyor
	name = "conveyor"
	icon = 'icons/objects.dmi'
	icon_state = "convey"

/obj/conveyor/New()
	new /obj/items/monitor( src )
	new /obj/items/lock_kit( src )
	new /obj/items/lock( src )
	new /obj/items/key( src )
	new /obj/items/toolbox( src )
	new /obj/items/ult_check( src )
	new /obj/items/not_check( src )
	new /obj/items/watch( src )
	new /obj/items/disk( src )
	new /obj/items/pen( src )
	new /obj/items/inv_pen( src )
	new /obj/items/book( src )
	new /obj/items/box( src )
	new /obj/signal/hub/mini(src)
	new /obj/signal/hub/router/mini(src)
	new /obj/signal/antenna(src)
	new /obj/signal/dir_ant(src)
	new/obj/signal/rackmount(src)
	..()

/obj/conveyor/verb/dispense(obj/O in src)
	set src in oview(1)

	flick("convey1", src)
	sleep(4)
	var/I = new O.type( src.loc )
	if(istype(I,/obj/signal))
		var/obj/signal/T = I
		T.anchored = FALSE
		T.density = FALSE
		T.verbs += /obj/signal/proc/get_me
		T.verbs += /obj/signal/proc/drop_me
	usr << "[I] has been created!"
	step(I, NORTH)

/obj/conveyor/electronic
	name = "electronic conveyor"
	icon_state = "e_convey"

/obj/conveyor/electronic/New()
	new /obj/items/monitor( src )
	new /obj/items/computer( src )
	new /obj/items/bug_scan( src )
	new /obj/signal/hub/mini(src)
	new /obj/signal/hub/router/mini(src)
	new/obj/signal/antenna(src)
	new/obj/signal/dir_ant(src)
	new/obj/signal/rackmount(src)
