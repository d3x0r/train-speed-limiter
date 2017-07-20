
--/c game.player.insert{name="solid-fuel", count=100}

--Class 1: 10 mph (16kph) for freight, 15 mph for passenger. Much yard, branch line, short line, and industrial spur trackage falls into category. 
--Class 2: 25 mph (40kph)  for freight, 30 mph for passenger. Branch lines, secondary main lines, many regional railroads, and some tourist operations frequently fall into this class. Examples are Burlington Northern Santa Fe's branch from Sioux Falls to Madison, S. Dak.; Napa Valley Wine Train's 18-mile ex-SP line between Napa and St. Helena, Calif.; and the entire Strasburg Rail Road, 4 and-a-half miles between Strasburg and Leaman Place, Pa. 
--Class 3: 40 mph (64kph) for freight, 60 mph for passenger. This commonly includes regional railroads and Class 1 secondary main lines. Examples are BNSF between Spokane and Kettle Falls, Wash.; and Canadian National's Wisconsin Central line between Neenah, Wis., and Sault Ste. Marie, Mich. 
--Class 4: 60 mph (96kph) for freight, 80 mph for passenger. This is the dominant class for main-line track used in passenger and long-haul freight service. Examples are most of the suburban trackage of Chicago's Metra commuter railroad, including its own Rock Island District west of Blue Island and Milwaukee District West Line west of Bensenville (also a Soo Line freight route); plus BNSF west of Cicero Yard and Union Pacific (former C&NW) west of Proviso Yard; New England Central's entire main line between New London, Conn., and East Alburgh, Vt.; and the Arizona & California (ex-Santa Fe) between Matthie, Ariz., and Cadiz, Calif. 
--Class 5: 80 mph (128kph) for freight, 90 mph for passenger. This is the standard for most high-speed track in the U.S. Examples are UP's main line between Council Bluffs, Iowa, and North Platte, Neb.; and BNSF between Fullerton and San Diego, Calif., used mostly by Amtrak's Pacific Surfliner trains to San Diego. 
--Class 6: 110 mph (177kph) for freight, 110 mph for passenger. This is found in the U.S. exclusively on Amtrak's Northeast Corridor between New York and Washington, D.C. Amtrak has also received special "Class 7" status for 125 mph operation and (with the launch of high-speed Acela Express trains) "Class 8" status for 150 mph on specific segments of the corridor. 

--Class 6	110 mph (177 km/h)
--Class 7 [us 4]	125 mph (201 km/h)
--Class 8 [us 5]	160 mph (257 km/h)
--Class 9 [us 6]	220 mph (354 km/h)

-- 300kmh = 186mph

-- In 1981, the first section of the new Paris–Lyon High-Speed line was inaugurated, 
-- with a 260 km/h (160 mph) top speed (then 270 km/h (170 mph) soon after). 
-- Being able to use both dedicated high-speed and conventional lines, the TGV offered 
-- the ability to join every city in the country at shorter journey times.[19] After 
-- the introduction of the TGV on some routes, air traffic on these routes decreased 
-- and in some cases disappeared.[19] The TGV set a publicised speed records in 1981 
-- at 380 km/h (240 mph), in 1990 at 515 km/h (320 mph), and then in 2007 at 574 km/h (357 mph).

-- 1mph = 1.60934kph

--  Fastest trains
-- 1. Shanghai Maglev: 267 mph  429 kph
-- 2. Harmony CRH380A: 236 mph  379 kph
-- 3. Trenitalia Frecciarossa 1000: 220 mph   354.0548 kph

-- speed of sound  1,235 km/h; 767 mph

-- 
--   2. The old steam engines were usually run well below 40MPH due to problems with maintaining the tracks
--    but could go much faster. I seem to recall a 45 mile run before 1900 in which a locomotive pulled a 
--   train at better than 65MPH... (Stanley Steamer cars were known to exceed 75MPH).


local kpt = ( 1000/3600 ) /60; -- km per tick
-- 0.00462962962962962962962962962963

local track_types = {  { name = "curved-scrap-rail", max=(kpt)*80, q = 0.992 }  -- 
		,  { name = "straight-scrap-rail", max=(kpt)*80, q = 0.992 }

		,  { name = "curved-cement-rail", max=(kpt)*720, q = 1.005 }  -- hyperloop speed
		,  { name = "straight-cement-rail", max=(kpt)*720, q = 1.005 }

		,  { name = "curved-rail-power", max=(kpt)*360, q = 1.0 }
		,  { name = "straight-rail-power", max=(kpt)*360, q = 1.0 }

		,  { name = "curved-rail-wood-bridge", max=(kpt)*280, q = 0.96 }
		,  { name = "straight-rail-wood-bridge", max=(kpt)*280, q = 0.96 }

		,  { name = "bridge-curved-rail", max=(kpt)*280, q = 0.96 }
		,  { name = "bridge-straight-rail", max=(kpt)*280, q = 0.96 }

		,  { name = "curved-rail", max=(kpt)*360, q = 1.0 }
		,  { name = "straight-rail", max=(kpt)*360, q = 1.0 }
		}

local lastRail = {};
local lastTick = 0;

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

script.on_configuration_changed( function()
	log( "CONFIGURATION CHANGED" );
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
		--log_keys( data.raw.entity.locomotive )
		temp = 1;
        end
	for i=1,#global.trains do
		if global.trains[i] then
			if( global.trains[i].valid ) then
				limitTrain( event.tick, i, global.trains[i] );		
			else 
				log( "skipping train (internal index):".. i );
				global.trains[i] = nil;
			end
		end
	end
	--end
end)

function limitTrain( tick, index, train ) 
	local ticks = 0;
	if not lastTick then
		lastTick = tick;
		return;
	end
	ticks = tick - lastTick;
	local frontRail = train.front_rail;
	local _lastRail = lastRail[index];
	local speed = train.speed;
	

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
				--train.speed = _lastRail.type.max;
				--return;
			end
			end
		end
	else 
		lastRail[index] = { rail=frontRail, tick=tick, type = nil, speed = speed }
		_lastRail = lastRail[index];
	end
			

	local frontLoco = train.locomotives.front_movers[1];
	if not frontLoco then
		frontLoco = train.locomotives.back_movers[1];
	end
	if not frontLoco then
		log( "no movers on this train..." );
		return
	end
	--local currentFuel = frontLoco.get_burnt_result_inventory();
	local burner = frontLoco.burner;
	if burner then 
		local currentFuel = burner.currently_burning;
		if currentFuel then 
			log( "burning:".. currentFuel.name.. " amount:".. burner.remaining_burning_fuel  );
		else
			--log( "no current fuel." );
		end
	end
	
	-- vehicle does not mean train... must be car or player
	--if( index == 2 ) then log( "riding  State:".. tostring(frontLoco.riding_state )); end

	if( speed > 0.001 ) then
		local scalar = 0.1;
		--log( frontLoco.name.."train speed:".. train.speed.."("..(train.speed/kpt)..")"  .. " delta:" .. ((speed-_lastRail.speed)/kpt) .. " fixed accel:"..((speed-_lastRail.speed + (_lastRail.speed*0.0075) )/kpt) );
		if( speed >= _lastRail.speed ) then
			--log( frontLoco.name.."train speed bonus:".. ((speed-_lastRail.speed) * 1.0 ) );
			--speed = speed + ((speed-_lastRail.speed) * 1.5 );
			--speed = speed * 1.02;
			--scalar = 0.2;
			--speed = speed * (1.003  * ticks); -- 1.005 is more than the train can stop
			
			--speed = speed * 1.001;

		end
			--speed = speed * 1.001;
			--speed = speed * 0.95;
			--  -- this is a good amount for slow track limiter on trains  

		-- scrap rail penalty
		-- speed = speed * 0.992;

		-- bridge rail penalty
		-- speed = speed * 0.9975;

		-- cement rail bonus
		-- speed = speed * 1.0005;
		
		--speed = speed * 0.992;
			--speed = speed * 1.003;
		for i=1, #track_types do
			local tt = track_types[i];
			if( tt.name == frontRail.name ) then
				_lastRail.type = tt;
				--log( "train speed:".. train.speed.. "something:".. track_types[i].max );
				speed = speed * tt.q;
				if( speed > tt.max ) then
					--speed = speed - (( speed-tt.max ) * 0.01 * ticks);
				end
				break
			end
		end
		_lastRail.speed = speed;
		train.speed = speed;
	end
		
	--log( 'train: '..train.id..'('..frontLoco.name..') is on:'..frontRail.name );
end


---------------------------------------------------
--On train created
---------------------------------------------------
script.on_event(defines.events.on_train_created, function(event)
	local train = event.train;

	--log( "Created Train:"..train.id.. " mover:"..tostring(train.locomotives.front_movers[1]).. "  id1:"..tostring(event.old_train_id_1).."   id2:"..tostring(event.old_train_id_2)  );
	
	if event.old_train_id_1 then
		--log( "check total: ".. #global.trains );
		for i = 1, #global.trains do
			--log( "check slot: ".. i );
			if not global.trains[i].valid then
				--log( " clear slot:"..i );
				global.trains[i] = nil;
			end
		end
	end

	local i;

	--local loco = train.locomotives.front_movers[1];

	--log_keys( train.locomotives );
	--local frontLoco = train.locomotives.front_movers;
	--if frontLoco then
	--for i=1, #frontLoco do
	--	log( "front loco:".. i.."  "..frontLoco[i].name );
	--end
	--end
	--local frontLoco = train.locomotives.back_movers;
	--if frontLoco then
	--for i=1, #frontLoco do
	--	log( "back loco:".. i.."  "..frontLoco[i].name );
	--end
	--end
	--local frontLoco = train.carriages;
	--if frontLoco then
	--for i=1, #frontLoco do
	--	log( "carriage:".. i.."  "..frontLoco[i].name );
	--end
	--end
	--local frontLoco = train.cargo_wagons;
	--if frontLoco then
	--for i=1, #frontLoco do
	--	log( "cargo:".. i.."  "..frontLoco[i].name );
	--end
	--end
	--log( "fs:".. train.front_stock.name );
	--log( "bs:".. train.back_stock.name );

	--log( "Train Proto:"..tostring( game.entity_prototypes[ loco.name ].weight ).. " Train:"..train.help() );

	-- car only.
	--log( "Inertial stuff:"..train.locomotives.front_movers[1].effectivity_modifier .. "  consump:"..train.locomotives.front_movers[1].consumption_modifier .."  fict:"..train.locomotives.front_movers[1].friction_modifier );

	for i=1, #global.trains do
		if global.trains[i] == train then
			log( "train already tracked in global:"..train.id);
			return;
		end
	end
	--log( " slots:".. #global.trains );
	for i=1, #global.trains do
		--log( " empty slot?"..i );
		if not global.trains[i] then
			--log( "filling train into missing slot." );
			global.trains[i] = train;
			return;
		end
	end                       	
	--log( "filling train into last slot.".. (#global.trains+1) );
	global.trains[#global.trains+1] = train;
end )



script.on_event(defines.events.on_player_mined_entity, function(event)
	log( 'player picked up:'.. event.entity.type );
	if( event.entity.type == "locomotive" ) then
		local train = event.entity.train;
		if not train then return end
		for i=1, #global.trains do
			if global.trains[i] == train then
				log( "Found train to remove".. i );
				global.trains[i] = nil;
			end
		end
	
		log( "Destroyed train?" );
	end
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

