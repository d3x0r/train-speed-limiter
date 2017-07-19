

local track_types = {  { name = "curved-scrap-rail", max=(0.279933/60.5)*80, q = 0.5 }
		,  { name = "straight-scrap-rail", max=(0.279933/60.5)*80, q = 0.5 }
		,  { name = "curved-cement-rail", max=(0.279933/60.5)*720, q = 1.6 }
		,  { name = "straight-cement-rail", max=(0.279933/60.5)*720, q = 1.6 }
		,  { name = "curved-rail-power", max=(0.279933/60.5)*360, q = 1.2 }
		,  { name = "straight-rail-power", max=(0.279933/60.5)*360, q = 1.2 }
		,  { name = "curved-rail-wood-bridge", max=(0.279933/60.5)*280, q = 0.9 }
		,  { name = "straight-rail-wood-bridge", max=(0.279933/60.5)*280, q = 0.9 }
		,  { name = "bridge-curved-rail", max=(0.279933/60.5)*280, q = 0.9 }
		,  { name = "bridge-straight-rail", max=(0.279933/60.5)*280, q = 0.9 }
		,  { name = "curved-rail", max=(0.279933/60.5)*360, q = 1 }
		,  { name = "straight-rail", max=(0.279933/60.5)*360, q = 1 }
		}

local lastRail = {};

local function log(string)
	game.write_file( "train-limiter.log", string.."\n", true, 1 );
end

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
    _log_keys( "", object )
end

local function _log_keys(prefix,object)
    for _, __ in pairs(object) do
        log( _.."="..tostring(__) );
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

function glob_init()
    global.trains = {}
	local index = 1; -- for adding available rail types
	for name,entity in pairs(game.entity_prototypes) do
		if entity.type == "straight_rail" then
			-- BridgeRailway
			if entity.name == "bridge-straight-rail" then
			end
			-- JunkTrain
			if entity.name == "straight-scrap-rail" then
			end
			-- bio industries woor bridge
			if entity.name == "bi-straight-rail-wood-bridge" then
			end
			-- RailPowerSystem
			if entity.name == "straight-rail-power" then
			end

			if entity.name == "straight-rail" then
			end


			log( "Game ProtoTypes:".. name.. " : "..entity.name.." type:"..entity.type );
		end
	end

	local surfaces = game.surfaces;--players[event.player_index]
	log_keys( surfaces );	
    	for name,surface in pairs(surfaces) do
		local trains = surface.get_trains();		
		log( "Surface trains:".. tostring(#trains) );
		for i=1, #trains do
			local train = trains[i];
			log( "Surface add train:" .. trains[i].id );
			global.trains[i] = train;
			log_keys(train.locomotives )
		end
		
	end
end


script.on_init(function()
	log( "ON INIT" );

    glob_init()

    --for _, player in pairs(game.players) do
    --    gui_init(player, false)
    --end


end)

script.on_load(function()
        -- game is not available.
        -- called when save is reloaded.
	 -- log( "ON LOAD" );
end)


---------------------------------------------------
--On research finished
---------------------------------------------------
script.on_event(defines.events.on_research_finished, function(event)
	--if event.research.name==trainWhistleTech then
		global.trains={}
	--end
end)

local temp = 0;
script.on_event(defines.events.on_tick, function(event)
	--if event.research.name==trainWhistleTech then
	--log( "active trains:"..#global.trains);
	if temp == 0 then 
		log( "process: ".. #global.trains );
		temp = 1;
        end
	for i=1,#global.trains do
		if global.trains[i] then
			limitTrain( event.tick, i, global.trains[i] );		
		end
	end
	--end
end)

function limitTrain( tick, index, train ) 
	local frontRail = train.front_rail;
	local _lastRail = lastRail[index];
	if( _lastRail ) then
		if( _lastRail.rail ~= frontRail ) then
			--if( index == 1 ) then 
			--	log( "tickdel train 1="..(tick-lastRail[index].tick));
			--end
			_lastRail.tick = tick;
			_lastRail.rail = frontRail;
		 	-- new rail type - need to go down and find the track.
		else
			if _lastRail.type then
			if( train.speed > _lastRail.type.max ) then
				train.speed = _lastRail.type.max;
				return;
			end
			end
		end
	else 
		lastRail[index] = { rail=frontRail, tick=tick, type = nil }
		_lastRail = lastRail[index];
	end
			

--	local frontLoco = train.locomotives.front_movers[1];
--	if not frontLoco then
--		frontLoco = train.locomotives.back_movers[1];
--	end
--	if not frontLoco then
--		log( "no movers on this train..." );
--		return
--	end

	local speed = train.speed;
	if( speed > 0.001 ) then
		--log( frontLoco.name.."train speed:".. train.speed );
		for i=1, #track_types do
			local tt = track_types[i];
			if( tt.name == frontRail.name ) then
				_lastRail.type = tt;
				--log( "train speed:".. train.speed.. "something:".. track_types[i].max );
				if( speed > tt.max ) then
					train.speed = speed - (( speed-tt.max ) * 0.1);
				end
				return;
			end
		end
	end
		
	--log( 'train: '..train.id..'('..frontLoco.name..') is on:'..frontRail.name );
end


---------------------------------------------------
--On train created
---------------------------------------------------
script.on_event(defines.events.on_train_created, function(event)
	local train = event.train;

	log( "Created Train:"..tostring(train.locomotives.front_movers[1]).. "id1:"..tostring(event.old_train_id_1).."  id2:"..tostring(event.old_train_id2)  );

	log( "Inertial stuff:"..train.locomotives.front_movers[1].effectivity_modifier .. "  consump:"..train.locomotives.front_movers[1].consumption_modifier .."  fict:"..train.locomotives.front_movers[1].friction_modifier );
        _log_keys( "   ", train );

	for i=1, #global.trains do
		if global.trains[i] == train then
			log( "train already tracked in global:"..train.id);
			return;
		end
	end
	for i=1, #global.trains do
		if not global.trains[i] then
			log( "filling train into missing slot." );
			global.trains[i] = train;
			return;
		end
	end
	log( "filling train into last slot.".. (#global.trains+1) );
	global.trains[#global.trains+1] = train;
end )



script.on_event(defines.events.on_player_mined_entity, function(event)
	log( 'player picked up:'.. event.entity.type );
	if( event.entity.type == "train" ) then
		local train = event.entity.train;
		if not train then return end
		for i=1, #global.trains do
			if global.trains[i] == train then
				global.trains[i] = nil;
			end
		end
	
		log( "Destroyed train?" );
	end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
     log( "Player Joined?" );
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
     log( "pre surface delete?" );
end)
script.on_event(defines.events.on_surface_created, function(event)
     log( "surface create?" );
end)

-- Init existing trains
--local surfaces = game.surfaces;--players[event.player_index]
--log_keys( surfaces );

