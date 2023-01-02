/obj/items/gps
	icon = 'icons/gps.dmi'
	name = "GPS Locator"

/obj/items/gps/Click()
	if(ismob(loc))
		usr << "[loc.x],[loc.y]"
	else
		usr << "[x],[y]"
