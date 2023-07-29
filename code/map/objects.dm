/obj/stool
	name = "stool"
	icon = 'icons/chairs.dmi'
	icon_state = "stool"

/obj/stool/chair
	name = "chair"
	icon_state = "chair"
/obj/table
	name = "table"
	icon = 'icons/table.dmi'
	icon_state = "alone"
	density = TRUE
	var/t_type = null
	layer = TURF_LAYER

/obj/table/secret
	layer = TURF_LAYER+2
/obj/trashcan
	name = "trashcan"
	icon = 'icons/misc.dmi'
	icon_state = "trashcan"
	density = TRUE
/obj/window
	name = "window"
	icon = 'icons/misc.dmi'
	icon_state = "window"
	density = TRUE
	layer = TURF_LAYER

/obj/plants
	name = "potted plant"
	icon = 'icons/objects.dmi'
	icon_state = "s_plant"
	density = TRUE
/obj/plants/large
		name = "large plant"
		icon_state = "l_plant"
/obj/alphanumeric
	name = "alphanumeric"
	icon = 'icons/alphanumeric.dmi'
	layer = TURF_LAYER
/obj/sign
	name = "sign"
	icon = 'icons/misc.dmi'
	icon_state = "sign"
