/obj/signal/rackmount
	icon = 'icons/rackmount.dmi'
	icon_state = "0"
	name = "Rackmount"
	density = TRUE
	var/max_mounts = 4
	var/list/mounts = list()
	var/list/connected = list()

/obj/signal/rackmount/New()
	..()
	if(ismob(src.loc))
		connected = list()

/obj/signal/rackmount/orient_to(obj/signal/wire/target,mob/user)
	if(ismob(src.loc))
		user << "Device must be on the ground to connect to it."
		return FALSE
	if(!length(mounts))
		user << "There are no systems mounted to this rack."
		return FALSE
	var/obj/signal/computer/select = input(user,"Which system do you want to connect to?")as null|anything in mounts
	if(!select) return FALSE
	if(!select.line1)
		connected += target
		connected[target] = select
		select.line1 = target
		user << "Connected to I/O port of [select.name]"
		return TRUE
	else if(!select.line2)
		connected += target
		connected[target] = select
		select.line2 = target
		user << "Connected to peripheral port of [select.name]"
		return TRUE
	else return FALSE

/obj/signal/rackmount/process_signal(obj/signal/packet/S,obj/source)
	..()
	if(!S) return

	var/obj/signal/computer/signal_system = connected[source]
	if(signal_system)
		if(signal_system.line1 == source||signal_system.line2 == source)
			var/obj/signal/packet/S2 = new()
			S.copy_to(S2)
			signal_system.process_signal(S2,source)
		del(S)

/obj/signal/rackmount/disconnectfrom(obj/source)
	if(source in connected)
		connected -= source
		for(var/obj/signal/computer/C in mounts)
			if(C.line1 == source||C.line2 == source)
				C.disconnectfrom(source)

/obj/signal/rackmount/cut()
	for(var/obj/signal/C in mounts)
		C.cut()
	connected = list()

/obj/signal/rackmount/attack_by(obj/items/selected, mob/user)
	if(istype(selected,/obj/items/computer))
		var/obj/items/computer/valid_system = selected
		if(length(mounts) >= max_mounts)
			user << "This rackmount is full."
		else
			user << "Successfully mounted the system to the rackmount."
			if(ckey(valid_system.computer.name) == "computer")
				valid_system.computer.label = "mount [length(mounts)+1]"
				valid_system.computer.name = "computer- '[valid_system.computer.label]'"
			mounts += valid_system.computer
			valid_system.computer.status = "off"
			valid_system.computer.loc = src
			icon_state = "[length(mounts)]"
			del(valid_system)
			var/s = 1
			for(var/obj/signal/computer/S in mounts)
				if(findtext(S.name,"computer- 'mount"))
					S.label = "mount [s]"
					S.name = "computer- 'mount [s]'"
					s++

	else
		if(istype(selected,/obj/items/disk))
			if(!length(mounts))
				user << "There are no systems mounted to this rack."
				return
			var/obj/signal/computer/sel = input("Which computer do you want to insert the disk into?")as null|anything in mounts
			if(!sel) return
			sel.insert_disk(selected)
		else if(istype(selected,/obj/items/wire))
			..()
		else if(istype(selected,/obj/items/wrench))
			..()
		else
			user << "You can only mount computers to this device."

/obj/signal/rackmount/verb/unmount_system()
	set src in view(1)
	set category = "computers"
	if(!length(mounts))
		usr << "There are no systems mounted to this rack."
		return
	var/obj/signal/computer/select = input(usr,"Which system do you want to unmount?")as null|anything in mounts
	if(!select) return
	mounts -= select
	select.status = "no_m"
	for(var/obj/signal/S in connected)
		if(connected[S] == select)
			S.cut()
			connected -= S
	var/obj/items/computer/nc = new(src.loc)
	nc.computer = select
	select.loc = nc
	if(select.label)
		nc.name = "computer- '[select.label]'"
	icon_state = "[length(mounts)]"
	var/s = 1
	for(var/obj/signal/computer/S in mounts)
		if(findtext(S.name,"computer- 'mount"))
			S.label = "mount [s]"
			S.name = "computer- 'mount [s]'"
			s++

/obj/signal/rackmount/verb/boot()
	set src in view(1)
	set category = "computers"
	if(!length(mounts))
		usr << "There are no systems mounted to this rack."
		return
	var/obj/signal/computer/select = input(usr,"Which system do you want to boot?")as null|anything in mounts
	if(!select) return
	select.boot()

/obj/signal/rackmount/verb/operate()
	set src in view(1)
	set category = "computers"
	if(!mounts||!length(mounts))
		usr << "There are no systems mounted to this rack."
		return
	var/obj/signal/computer/select = input(usr,"Which system do you want to operate?")as null|anything in mounts
	if(!select) return
	select.temp_user = usr
	select.operate()

/obj/signal/rackmount/verb/eject()
	set src in view(1)
	set category = "computers"
	if(!length(mounts))
		usr << "There are no systems mounted to this rack."
		return
	var/obj/signal/computer/select = input(usr,"Which system do you want to eject a disk from?")as null|anything in mounts
	if(!select) return
	select.eject()

/obj/signal/rackmount/verb/power_off()
	set src in view(1)
	set category = "computers"
	if(!length(mounts))
		usr << "There are no systems mounted to this rack."
		return
	var/obj/signal/computer/select = input(usr,"Which system do you want to power off?")as null|anything in mounts
	if(!select) return
	select.power_off()

/obj/signal/rackmount/verb/label(T as text)
	set src in view(1)
	set category = "computers"
	if(!T) name = "Rackmount"
	else name = "Rackmount- '[T]'"
