
local function _log_keys(prefix,object)
    for _, __ in pairs(object) do
        log( prefix.._.."="..tostring(__) );
	--if( type(__)=="string" or type(__)=="number" or type(__)=="function" or type(__)=="boolean" or type(__)=="nil"or type(__)=="thread") then
	if( type(__)=="userdata" ) then
		local meta = getmetatable(__) ;
		if meta then
		        _log_keys( prefix.."  ", getmetatable(__) );
		else
			log( "NIL Userdata?" );
		end
        elseif type(__) == "table" then
	        _log_keys( prefix.."  ", __ );
	end
    end

end

local function log_keys(object)
    _log_keys( ". ", object )
end


--log_keys( data.raw );
