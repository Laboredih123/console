/obj/zoom_plane
	plane = 0
	appearance_flags = PLANE_MASTER | PIXEL_SCALE
	screen_loc = "1,1"
	var/tmp/zoomed = FALSE
	var/tmp/zooming = FALSE
	icon = 'icons/computer.dmi'
	icon_state = "on"
	layer = 99

/client
	var/tmp/obj/zoom_plane/zoom

/client/New()
	..()
	zoom = new()
	screen += zoom


/client/MouseWheel()
	set waitfor = 0
	if(!zoom) zoom = new()
	if(zoom.zooming) return
	var/matrix/mat = matrix()
	if(zoom.zoomed)
		mat:Scale(1)
		zoom.zooming = TRUE
		animate(zoom,transform=mat,time=10)
		sleep(10)
		zoom.zooming = FALSE
		zoom.zoomed = FALSE
	else
		mat.Scale(2)
		zoom.zooming = TRUE
		animate(zoom,transform=mat,time=10)
		sleep(10)
		zoom.zooming = FALSE
		zoom.zoomed = TRUE
