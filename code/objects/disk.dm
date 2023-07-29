/obj/items/disk
	desc = "You can store and transfer files using these!"
	name = "disk"
	icon = 'icons/computer.dmi'
	icon_state = "disk"
	b_flags = 2
	var/label
	var/datum/file/dir/root = null

/obj/items/disk/New()
	..()
	src.root = new /datum/file/dir(  )
	src.root.disk_master = src
	src.root.name = "A:"

/obj/items/disk/verb/label(title as text)
	set src in usr

	if (title)
		label = title
		src.name = "disk- '[title]'"
	else
		src.name = "disk"
