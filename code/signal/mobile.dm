/obj/signal/var/tmp/unlockable = FALSE

/obj/signal/proc/get_me()
	set name = "get"
	set category = "items"
	set src in oview(usr,1)
	if(!isturf(src.loc)) return
	if(src.anchored)
		usr << "[src.name] is anchored in place."
		src.verbs -= /obj/signal/proc/get_me
		src.verbs -= /obj/signal/proc/drop_me
		return
	src.cut()
	src.Move(usr)

/obj/signal/proc/drop_me()
	set name = "drop"
	set category = "items"
	set src in usr
	if(!ismob(src.loc)) return
	src.loc = usr.loc

/obj/signal/antenna
	unlockable = TRUE

/obj/signal/dir_ant
	unlockable = TRUE

/obj/signal/rackmount
	unlockable = TRUE
