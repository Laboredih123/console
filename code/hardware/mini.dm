/obj/signal/hub/Move()
	..()
	if(line1) line1.cut()
	if(line2) line2.cut()
	if(line3) line3.cut()
	if(line4) line4.cut()
	if(line5) line5.cut()
	if(line_control) line_control.cut()
	if(line_temp) line_temp.cut()

/obj/signal/hub/mini
	density = 0
	name = "Mini Hub"
	max_signal = 10
	icon = 'icons/mini.dmi'
	icon_state = "hub"
	unlockable = 1
	place_locked = 0

/obj/signal/hub/mini/New()
	..()
	if(!place_locked)
		verbs += /obj/signal/proc/get_me
		verbs += /obj/signal/proc/drop_me

/obj/signal/hub/router

/obj/signal/hub/router/New()
	..()
	if(!place_locked)
		verbs += /obj/signal/proc/get_me
		verbs += /obj/signal/proc/drop_me

/obj/signal/hub/router/mini
	density = 0
	name = "Mini Router"
	max_signal = 10
	icon = 'icons/mini.dmi'
	icon_state = "router"
	unlockable = 1
	place_locked = 0
