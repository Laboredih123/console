
#define EOT ascii2text(4)

/obj/items/paper
	name = "paper"
	icon_state = "paper"
	var/data = null
	var/secret = null

/obj/items/paper/Del()
	if (src.secret == 1)
		if (!( locate((/obj/items/paper in locate(67, 14, 1))) ))
			var/obj/items/paper/P = new /obj/items/paper( locate(67, 14, 1) )
			P.text = "...hheexx ttoo oocctt..."
			P.data = "[EOT]\[i\]Prototyping New Objects by Exadv1"
			P.secret = 2
	..()

/obj/items/paper/attack_by(obj/P, mob/user)
	if (istype(P, /obj/items/pen))
		var/t = input(user, "Please type text to add:", "Pen and Paper", null)  as message
		if (((get_dist(src, user) <= 1 || src.loc == user) && P.loc == user))
			src.data += "[EOT]\[w\][t] -[user]"
	else
		if (istype(P, /obj/items/inv_pen))
			var/t = input(user, "Please type text to add:", "Pen and Paper", null)  as message
			if (((get_dist(src, user) <= 1 || src.loc == user) && P.loc == user))
				src.data += "[EOT]\[i\]<font face=calligrapher>[t] -[user]</font>"

/obj/items/paper/verb/label(msg as text)
	if (msg)
		src.name = "paper- '[msg]'"
	else
		src.name = "paper"

/obj/items/paper/verb/read()
	var/icon/I = new /icon( 'icons/alphanumeric.dmi', "sX" )
	usr << browse_rsc(I, "stamp")
	del(I)
	usr << browse("[src.format()]", "window=name;size=500x400")

/obj/items/paper/proc/format(t9 in view(usr.client))
	var/ret
	if (findtext(src.data, "[EOT]", 1, null))
		var/list/Lines = splittext(src.data, "[EOT]")
		for(var/line in Lines)
			if ((line && length(line) > 3))
				var/t_id = copytext(line, 1, 4)
				var/act_t = copytext(line, 4, length(line) + 1)
				switch(t_id)
					if("\[t\]")
						var/te = copytext(line, 4, length(line) + 1)
						te = replacetext(te, "\n", "<BR>")
						te = replacetext(te, "<HR>", "HR")
						ret += "[te]<HR>"
					if("\[i\]")
						if ((t9 && t9 & 1))
							var/te = copytext(line, 4, length(line) + 1)
							te = replacetext(te, "\n", "<BR>")
							te = replacetext(te, "<HR>", "HR")
							ret += "<font color=#6D6D6D>[te]</font><HR>"
					if("\[w\]")
						var/te = copytext(line, 4, length(line) + 1)
						te = replacetext(te, "\n", "<BR>")
						te = replacetext(te, "<HR>", "HR")
						ret += "<font face=calligrapher>[te]</font><HR>"
					if("\[n\]")
						var/vn = copytext(act_t, 1, findtext(act_t, ";", 1, null))
						ret += "<IMG src=stamp>[vn]<HR>"
		return ret
	else
		if (copytext(src.data, 1, 2) != "[EOT]")
			return src.data


/obj/copier
	name = "copier"
	icon = 'icons/computer.dmi'
	icon_state = "copier"
	density = TRUE

/obj/copier/attack_by(obj/items/paper/P, mob/user)
	if (istype(P, /obj/items/paper))
		var/obj/items/paper/O = new /obj/items/paper( src.loc )
		O.data = P.data
		if(findtext(O.data,"[EOT]\[n\]"))
			var/n_f = findtext(O.data,"[EOT]\[n\]")
			var/n_e = findtext(O.data,"\n",n_f)
			if(!n_e) n_e = length(O.data)
			var/n_c = copytext(O.data,n_f,n_e+1)
			O.data = replacetext(O.data,n_c,"")
		if (!( findtext(O.data, "[EOT]\[i\]copy", 1, null) ))
			O.data += "[EOT]\[i\]copy"
	else
		..()


/obj/shredder
	name = "shredder"
	icon = 'icons/computer.dmi'
	icon_state = "shredder"

/obj/shredder/attack_by(obj/P, mob/user)
	if (!( istype(P, /obj/items/paper) ))
		return
	view(src, 3) << "\red [user] shreds [P]!"
	del(P)
