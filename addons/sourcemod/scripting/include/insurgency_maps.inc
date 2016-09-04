/** Double-include prevention */
#if defined _insurgency_maps_included_
  #endinput
#endif
#define _insurgency_maps_included_
 
/**
 * Return map count
 *
 * @return        	Map count integer.
 */
native int InsurgencyMap_MapCount();

/**
 * Create adt_array before using this function.
 *
 * @param array		Fill the array with the maps.
 * @noreturn
 */
native void InsurgencyMap_MapArray(ArrayList array);

/**
 * Create adt_array before using this function.
 *
 * @param array		Fill the array with the gamemodes in a given map.
 * @noreturn
 */
native void InsurgencyMap_MapGamemodesArray(const char[] mapname, ArrayList array);

/**
 * Create adt_array before using this function.
 *
 * @param array		Fill the array with the maps in a given gamemode.
 * @noreturn
 */
native void InsurgencyMap_GamemodeMapsArray(const char[] gamemode, ArrayList array);

/**
 * Get current gamemode
 *
 * @param gamemode		Return current gamemode
 * @noreturn
 */
native void InsurgencyMap_Gamemode(char[] gamemode, len);



public SharedPlugin:__pl_insurgency_maps = 
{
	name = "insurgency_maps",
	file = "insurgency_maps.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};