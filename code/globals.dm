var/n_version = "N2.3"
var/n_sub = ".1R"
var/list/rsc_fonts = list('fonts/CALLIGRA.ttf')
var/list/door_codes = list()
var/motd = ""

/world
	mob = /mob
	turf = /turf/floor
	area = /area
	view = "18x18"
	hub = "Exadv1.console"
	name = "console"
	status = "Version N2.3"

/world/New()
	..()
	status = "Version [n_version][n_sub]"

	LoadAdmins()
	LoadConfig()
	LoadMOTD()

	// Initialize with loaded config.
	for(var/atom/A as anything in world)
		A.Initialize()

	LoadLabs()

	// Spawn a process to save the labs every 5 minutes.
	spawn(1)
		while(TRUE)
			sleep(3000)
			SaveLabs()

/datum
	var/rname

/obj
	layer = OBJ_LAYER
	var/list/bugs = list()
	var/obj/items/lock/lock
