/obj/items
	name = "items"
	icon = 'icons/items.dmi'
	var/b_flags = 0

	bug_scan
		name = "electronic scanner"
		icon_state = "b_scan"
		b_flags = 1

	inv_pen
		name = "invisible pen"
		icon_state = "inv_pen"
	lock_kit
		name = "lock kit"
		icon_state = "lock_kit"
	monitor
		name = "monitor"
		icon = 'icons/computer.dmi'
		icon_state = "monitor"
		density = TRUE
	paint
		name = "paint"
		icon_state = "paint"
	pen
		name = "pen"
		icon_state = "pen"
	screwdriver
		name = "screwdriver"
		icon_state = "screwdriver"
	watch
		name = "watch"
		icon_state = "watch"
	wirecutters
		desc = "You can cut wire with these. Just equip them and double click on the target wire!"
		name = "wirecutters"
		icon_state = "wirecutters"
	wrench
		name = "wrench"
		icon_state = "wrench"
