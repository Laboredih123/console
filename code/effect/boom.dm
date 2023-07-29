/image/boom
	icon='icons/packet.dmi'
	icon_state="boom"
	layer = FLY_LAYER

/image/boom/New()
	..()
	world<<src
	spawn(20)
		del(src)
