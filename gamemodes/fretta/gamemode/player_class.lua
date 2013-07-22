
module( "player_class", package.seeall )

local ClassTables = {}



function Register( name, classtable )
	ClassTables[ name ] = classtable
	ClassTables[ name ].m_HasBeenSetup = false
end

function Get( name )
	
	if ( !ClassTables[ name ] ) then return {} end

	// Derive class here.
	// I have favoured using table.Inherit over using a meta table 
	// This is to the performance hit is once, now, rather than on every usage
	if ( !ClassTables[ name ].m_HasBeenSetup ) then
	
		ClassTables[ name ].m_HasBeenSetup = true
		
		local Base = ClassTables[ name ].Base 
		if ( ClassTables[ name ].Base && Get( Base ) ) then
			ClassTables[ name ] = table.Inherit( ClassTables[ name ], Get( Base ) )
			ClassTables[ name ].BaseClass = Get( Base )
		end

	end

	return ClassTables[ name ]
end


function GetClassName( name )

	local class = Get( name )
	if (!class) then return name end
	
	return class.DisplayName

end
