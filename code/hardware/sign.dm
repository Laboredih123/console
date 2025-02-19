/obj/signal/sign_box
	name = "Sign Control"
	icon = 'icons/computer.dmi'
	icon_state = "sign_box"
	dir = SOUTH
	anchored = TRUE

	var/sign_dir = SOUTH
	var/tmp/obj/new_sign/my_sign
	var/obj/signal/line1
	var/default_text
	var/text_color = "green"
	var/shadow_color = "black"

/obj/signal/sign_box/New()
	..()
	spawn(5)
		var/obj/new_sign/found_sign = locate() in get_step(src,src.sign_dir)
		if(found_sign)
			del(found_sign)
		my_sign = new()
		my_sign.loc = get_step(src,src.sign_dir)
		if(default_text)
			my_sign.SetText(default_text,text_color, shadow_color)

/obj/signal/sign_box/Del()
	if(my_sign)
		del(my_sign)
	..()

/obj/signal/sign_box/orient_to(obj/target,mob/user)
	if(line1) return FALSE
	if(user.loc != src.loc)
		user << "You must be on the same tile as the sign box to connect to it."
		return FALSE
	else
		line1 = target
		user << "Connected to sign box."
		return TRUE
/obj/signal/sign_box/cut()
	if(line1)
		line1.disconnectfrom(src)
	line1 = null

/obj/signal/sign_box/process_signal(obj/signal/packet/S,obj/source)
	..()
	if(isnull(S))return
	S.loc = src.loc
	S.master = src
	if(S.id == "text")
		var/new_text = S.params
		default_text = new_text
		UpdateSign()
	if(S.id == "color" || S.id == "shadow")
		var/new_color = S.params
		if(S.id == "shadow") src.shadow_color = new_color
		else src.text_color = new_color
		UpdateSign()
	del(S)

/obj/signal/sign_box/proc/UpdateSign()
	if(my_sign)
		my_sign.SetText(default_text,src.text_color,src.shadow_color)

/obj/new_sign
	icon = 'icons/new_sign.dmi'
	name = "Sign"

	var/image/maptext_dummy
	var/image/maptext_shadow

/obj/new_sign/proc/SetText(text,text_color="green",shadow="black")
	//var/empty_spaces = 0
	text = stripHTML(text)
	if(length(text) > 18) text = copytext(text,1,19)
	/*else
		empty_spaces = (16 - length(text))
	while(empty_spaces > 0)
		text = " [text]"
		empty_spaces--*/
	if(!maptext_dummy)
		maptext_dummy = new()
		maptext_shadow = new()
		maptext_dummy.layer = OBJ_LAYER+2
		maptext_shadow.layer = OBJ_LAYER+1
		overlays += maptext_dummy
		overlays += maptext_shadow
	overlays -= maptext_dummy
	overlays -= maptext_shadow
	maptext_dummy.pixel_x = 0
	maptext_shadow.pixel_x = maptext_dummy.pixel_x + 1
	maptext_dummy.pixel_y = 9
	maptext_shadow.pixel_y = maptext_dummy.pixel_y
	maptext_dummy.maptext_width = 96
	maptext_shadow.maptext_width = maptext_dummy.maptext_width
	maptext_dummy.maptext = {"
	<div style="font-size: 7px; text-align: center; color:'[text_color]'; font-family:terminal">
		[text]
	</div>
	"}
	maptext_shadow.maptext = {"
	<div style="font-size: 7px; text-align: center; color:'[shadow]'; font-family:terminal">
		[text]
	</div>
	"}
	overlays += maptext_shadow
	overlays += maptext_dummy
