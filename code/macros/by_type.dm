// Relicenced to AGPL by Adhara, Zewaka, and Pali for use in Console, thanks!

// By_type lets us not loop through world. Just Plop a START_TRACKING in the New of an object to track it
// And use a STOP_TRACKING in the Del to, well, stop tracking.
// To go through something use for (var/obj/dummy/dum as anything in by_type[/obj/dummy])

#ifdef SPACEMAN_DMM
	#define START_TRACKING
	#define STOP_TRACKING
#elif defined(OPENDREAM)
	#define START_TRACKING if(!by_type[__PROC__]) { by_type[__PROC__] = list() }; by_type[__PROC__][src] = 1
	#define STOP_TRACKING by_type[__PROC__].Remove(src)
#else
	#define START_TRACKING if(!by_type[......]) { by_type[......] = list() }; by_type[.......][src] = 1
	#if DM_BUILD >= 1552
		#define STOP_TRACKING by_type[......].Remove(src)
	#else
		#define STOP_TRACKING by_type[.....].Remove(src)
	#endif
#endif

var/list/list/by_type = list()
