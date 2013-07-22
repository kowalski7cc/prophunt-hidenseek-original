

list.Set( "PlayerColours", "red", 		Color( 255, 0, 0 ) )
list.Set( "PlayerColours", "yellow", 	Color( 255, 255, 0 ) )
list.Set( "PlayerColours", "green", 	Color( 43, 235, 79 ) )
list.Set( "PlayerColours", "blue", 		Color( 43, 158, 255 ) )
list.Set( "PlayerColours", "orange", 	Color( 255, 148, 39 ) )
list.Set( "PlayerColours", "pink", 		Color( 255, 148, 255 ) )
list.Set( "PlayerColours", "lilac", 	Color( 120, 133, 255 ) )
list.Set( "PlayerColours", "army", 		Color( 120, 158, 18 ) )
list.Set( "PlayerColours", "grey", 		Color( 200, 200, 200 ) )

if ( CLIENT ) then
	CreateClientConVar( "cl_playercolor", "", true, true )
end

