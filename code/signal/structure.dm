/obj/signal/packet
	name = "structure"
	icon = 'icons/packet.dmi'
	var/strength = 10
	source_id = 0
	dest_id = 0
	id = 0
	anchored = TRUE

	var/tmp/life_time = 6
	var/tmp/last_loc
	var/tmp/timer_down = FALSE

/obj/signal/packet/New()
	..()
	spawn(1)
		LifeTimer()

/obj/signal/packet/proc/LifeTimer()
	if(timer_down) return
	while(life_time&&!timer_down)
		sleep(10)
		if(loc!=last_loc)
			life_time = 6
			last_loc = loc
		life_time--
	if(!timer_down) del(src)

/obj/signal/packet/orient_to()
	return 0

/obj/signal/packet/proc/copy_to(obj/signal/S)
	S.source_id = src.source_id
	S.dest_id = src.dest_id
	S.id = src.id
	S.params = src.params
	if (src.cur_file)
		var/datum/file/F = new src.cur_file.type()
		src.cur_file.copy_to(F)
		S.cur_file = F
