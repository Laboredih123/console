/atom
	var/pos_status = 2
	var/initialized = FALSE

/atom/proc/Initialize()
    initialized = TRUE

/atom/proc/examine()
	. = "\icon[src] <B>This is [src]</B>\n\t[src.desc]"

/atom/movable
	var/anchored = FALSE
