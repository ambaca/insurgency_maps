/** Double-include prevention */
#if defined _insurgency_maps_included_
  #endinput
#endif
#define _insurgency_maps_included_
 
/**
 * Get map count
 *
 * @return		Return map count.
 */
native int InsurgencyMap_MapCount();

/**
 * Get all maps
 *
 * @param array		Fill the adt_array with maps.
 * @noreturn
 */
native void InsurgencyMap_MapArray(ArrayList array);

/**
 * Provides all the gamemodes in a given map .
 *
 * @param map		Map name to get gamemodes.
 * @param array		Fill the adt_array with the gamemodes.
 * @noreturn
 */
native void InsurgencyMap_MapGamemodesArray(const char[] mapname, ArrayList array);

/**
 * Provides all the maps in a given gamemode .
 *
 * @param gamemode		Gamemode to get maps.
 * @param array			Fill the array with the maps.
 * @noreturn
 */
native void InsurgencyMap_GamemodeMapsArray(const char[] gamemode, ArrayList array);

/**
 * Get current gamemode
 *
 * @param gamemode		String buffer to store gamemode.
 * @param len			Maximum size of string buffer.
 * @noreturn
 */
native void InsurgencyMap_Gamemode(char[] gamemode, int len);

/**
 * Get all gamemodes
 *
 * @param array		Fill the adt_array with gamemodes.
 * @noreturn
 */
native void InsurgencyMap_GamemodeArray(ArrayList array);


/**
 * Check is the gamemode type cooperative.
 *
 * @param gamemode		Gamemode name to check.
 *
 * @return bool			True if gamemode type is coop, pvp when false
 */
native bool InsurgencyMap_IsGameTypeCoop(const char[] gamemode);



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