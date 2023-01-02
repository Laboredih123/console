obj/signal/antenna
	dish
		name = "Satellite Relay Uplink"
		icon_state = "dish"
		r_accept(string in view(usr.client), source in view(usr.client))
			var/list/ekeys = params2list(src.e_key)
			if(!ekeys) return FALSE
			if ((string in ekeys && istype(source, /obj/signal/antenna/dish)))
				return TRUE
			else
				return FALSE

		process_signal(obj/signal/structure/S, obj/source)
			..()
			if(!S) return
			S.loc = null
			S.master = src
			S.timer_down = TRUE
			if (src.broadcasting)
				del(S)
				return
			src.broadcasting = TRUE
			if (source == src.line1)
				for(var/obj/signal/C in world)
					if (C != src)
						var/list/my_ekeys = params2list(src.e_key)
						var/a = FALSE
						for(var/E in my_ekeys)
							if(C.r_accept(E,src))
								a = TRUE
						if (a)
							var/obj/signal/structure/S1 = new /obj/signal/structure(  )
							S.copy_to(S1)
							S1.timer_down = TRUE
							S1.strength -= 2
							if (S1.strength <= 0)
								del(S1)
								return
							missile(/obj/radio, src.loc, C.loc)
							spawn( 0 )
								C.process_radio(S1,src)

			else
				if (S.id == "e_key")
					var/number
					var/list/my_ekeys = params2list(S.params)
					if(my_ekeys.len > 5) my_ekeys.Cut(6)
					for(var/E in my_ekeys)
						var/b = FALSE
						if(my_ekeys.Find(E) < my_ekeys.len) b = TRUE
						E = text2num(E)
						E = round(min(max(1, E), 65000))
						number += "[E]"
						if(b) number += ";"
					src.e_key = "[number]"
			del(S)
			sleep(5)
			src.broadcasting = null
