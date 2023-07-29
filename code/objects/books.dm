/obj/items/book
	name = "book"
	icon_state = "book"
	var/flags = null

/obj/items/book/New()
	..()
	spawn( 1 )
		if (src.flags & 1)
			src.verbs -= /obj/items/book/verb/bind
			src.verbs -= /obj/items/book/verb/label

/obj/items/book/attack_by(obj/items/target)
	if (istype(target, /obj/items/paper))
		target.unequip()
		src.contents += target

/obj/items/book/verb/bind()
	for(var/obj/items/paper/P in src.contents)
		if (P.name != "paper")
			P.name = copytext(P.name, 9, length(P.name))

	if (src.name != "book")
		src.name = copytext(src.name, 8, length(src.name))
	src.flags = src.flags | 1
	src.verbs -= /obj/items/book/verb/bind
	src.verbs -= /obj/items/book/verb/label

/obj/items/book/verb/label(msg as text)
	if (msg)
		src.name = "book- '[msg]'"
	else
		src.name = "book"

/obj/items/book/verb/remove(obj/items/paper/O as null|anything in src.contents)
	if (O)
		O.loc = src.loc
		O.name = "paper- '[O.name]'"

/obj/items/book/verb/table()
	usr << "Table of contents for \icon[src] [src.name]"
	var/x = null
	x = 1
	while(x <= src.contents.len)
		var/obj/items/paper/temp = src.contents[x]
		usr << "\t Page [x]: [temp.name]"
		temp = null
		x++

/obj/items/book/verb/read(number as num)
	number = min(max(1, round(number)), src.contents.len)
	if (number < 1)
		usr << "The book is empty!"
		return
	else
		var/obj/items/paper/temp = src.contents[number]
		usr << browse(temp.format(), "window=Page [number] of \icon[src][src.name] titled [temp.name]")
