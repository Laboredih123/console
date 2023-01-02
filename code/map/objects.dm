obj
	stool
		name = "stool"
		icon = 'icons/chairs.dmi'
		icon_state = "stool"
		chair
			name = "chair"
			icon_state = "chair"
	table
		name = "table"
		icon = 'icons/table.dmi'
		icon_state = "alone"
		density = TRUE
		var/t_type = null
		layer = TURF_LAYER
		secret
			layer = TURF_LAYER+2
	trashcan
		name = "trashcan"
		icon = 'icons/misc.dmi'
		icon_state = "trashcan"
		density = TRUE


	window
		name = "window"
		icon = 'icons/misc.dmi'
		icon_state = "window"
		density = TRUE
		layer = TURF_LAYER

	plants
		name = "potted plant"
		icon = 'icons/objects.dmi'
		icon_state = "s_plant"
		density = TRUE
		large
			name = "large plant"
			icon_state = "l_plant"

	alphanumeric
		name = "alphanumeric"
		icon = 'icons/alphanumeric.dmi'
		layer = TURF_LAYER

	boxrack
		name = "boxrack"
		icon = 'icons/objects.dmi'
		icon_state = "box_rack"
		opacity = TRUE
		density = TRUE
	bulletin
		name = "bulletin board"
		icon = 'icons/objects.dmi'
		icon_state = "bullitin"
	copier
		name = "copier"
		icon = 'icons/computer.dmi'
		icon_state = "copier"
		density = TRUE
	filecabinet
		name = "filecabinet"
		icon = 'icons/objects.dmi'
		icon_state = "file_cabinet"
		density = TRUE

	shredder
		name = "shredder"
		icon = 'icons/computer.dmi'
		icon_state = "shredder"
	sign
		name = "sign"
		icon = 'icons/misc.dmi'
		icon_state = "sign"
