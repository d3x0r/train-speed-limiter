
require( "controls.rail" )
require( "libs.railPowerLib" )

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

-- In 1981, the first section of the new Paris�Lyon High-Speed line was inaugurated, 
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

local scrapPenalty = 0.989;
local waterPenalty = 0.9925;
local standardBonus = 0.995;
local concreteBonus = 0.9965;

local track_types = {}

local lastRail = {};
local lastTick = 0;
local force_reinit = false;

local enableHybridTick = false;
local hybridEnergy = 0;
local hybridLocos = nil;

local backwardRail = {rail_direction=defines.rail_direction.back, rail_connection_direction=defines.rail_connection_direction.straight};
local backwardRail1 = {rail_direction=defines.rail_direction.back, rail_connection_direction=defines.rail_connection_direction.left};
local backwardRail2 = {rail_direction=defines.rail_direction.back, rail_connection_direction=defines.rail_connection_direction.right};
local forwardRail = {rail_direction=defines.rail_direction.front, rail_connection_direction=defines.rail_connection_direction.straight};
local forwardRail1 = {rail_direction=defines.rail_direction.front, rail_connection_direction=defines.rail_connection_direction.left};
local forwardRail2 = {rail_direction=defines.rail_direction.front, rail_connection_direction=defines.rail_connection_direction.right};


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


local function setupTypes() 
	if global.track_types then
		track_types = {} -- reset this list (probably new items added or deleted anyway
		local bi_found = false;
		--log( "Have some types:"..#global.track_types )
		for name,type in pairs(global.track_types) do
			if( type == "bi-wood" ) then
				bi_found = true;
				break
			end
		end
		for name,type in pairs(global.track_types) do
			-- BridgeRailway
			if type == "bridge" then
				track_types[#track_types+1] = { name = "bridge-curved-rail", max=(kpt)*280, q = waterPenalty }
				track_types[#track_types+1] = { name = "bridge-straight-rail", max=(kpt)*280, q = waterPenalty }
			-- JunkTrain
			elseif type == "scrap" then
				track_types[#track_types+1] = { name = "curved-scrap-rail", max=(kpt)*95, q = scrapPenalty } 
				track_types[#track_types+1] = { name = "straight-scrap-rail", max=(kpt)*95, q = scrapPenalty }
			elseif type == "bi-bridge" then
				-- bio industries woor bridge
				track_types[#track_types+1] = { name = "bi-curved-rail-wood-bridge", max=(kpt)*280, q = waterPenalty }
				track_types[#track_types+1] = { name = "bi-straight-rail-wood-bridge", max=(kpt)*280, q = waterPenalty }

			elseif type == "bi-wood" then
				track_types[#track_types+1] = { name = "bi-curved-rail-wood", max=(kpt)*360, q = standardBonus }
				track_types[#track_types+1] = { name = "bi-straight-rail-wood", max=(kpt)*360, q = standardBonus }
			elseif type == "power" then
				-- RailPowerSystem
				track_types[#track_types+1] = { name = "curved-rail-power", max=(kpt)*360, q = standardBonus };
				track_types[#track_types+1] = { name = "straight-rail-power", max=(kpt)*360, q = standardBonus };
			elseif type == "power-bridge" then
				-- RailPowerSystem + BI wood
				track_types[#track_types+1] = { name = "curved-rail-bridge-power", max=(kpt)*280, q = waterPenalty };
				track_types[#track_types+1] = { name = "straight-rail-bridge-power", max=(kpt)*280, q = waterPenalty };
			elseif type == "power-concrete" then
				--log( "power concrete..." );
				track_types[#track_types+1] = { name = "curved-rail-concrete-power", max=(kpt)*720, q = concreteBonus };
				track_types[#track_types+1] = { name = "straight-rail-concrete-power", max=(kpt)*720, q = concreteBonus };

			elseif type == "standard" then
				if( bi_found ) then
					track_types[#track_types+1] = { name = "straight-rail", max=(kpt)*720, q = concreteBonus };
					track_types[#track_types+1] = { name = "curved-rail", max=(kpt)*720, q = concreteBonus };
				else
					track_types[#track_types+1] = { name = "straight-rail", max=(kpt)*360, q = standardBonus };
					track_types[#track_types+1] = { name = "curved-rail", max=(kpt)*360, q = standardBonus };
				end
			end


			--log( "Game ProtoTypes:".. name.. " : "..entity.name.." type:"..type );
		end
	end
end


local function logAccumulators() 
	local surfaces = game.surfaces;--players[event.player_index]
	--log_keys( surfaces );	
	local i, j;
	for i=1,#surfaces do
		accums = surfaces[i].find_entities_filtered{ name="rail-accu" }
		log( "Total:".. #accums );
		for j=1, #accums do
			if( accums[j].circuit_connected_entities ) then
				log( "accum:"..j.. " at "..accums[j].position.x.. ","..accums[j].position.y.." connections:".. tostring(accums[j].circuit_connected_entities)  );
			end
			--log( "accum:"..j.." connections:".. accums[j].neighbours );--circuit_connected_entities );
			if( accums[j].electric_buffer_size ~= 25000 ) then
				log( "accum "..j.." has(buf):".. accums[j].electric_buffer_size )
			end
			if( accums[j].energy ~= 25000  and accums[j].energy ~= 11000 ) then
				log( "accum "..j.. " at "..accums[j].position.x.. ","..accums[j].position.y.." has(nrg):".. accums[j].energy )
			end
			if( accums[j].electric_input_flow_limit ~= 25000 and accums[j].electric_input_flow_limit ~= 15000000 ) then
				log( "accum "..j.." has(in ):".. accums[j].electric_input_flow_limit )
			end
			if( accums[j].electric_input_flow_limit ~= 25000 and accums[j].electric_output_flow_limit ~= 15000000) then
				log( "accum "..j.." has(out):".. accums[j].electric_output_flow_limit )
			end
			if( accums[j].electric_emissions ~= 0 ) then
				log( "accum "..j.." has(emi):".. accums[j].electric_emissions )
			end
			if( accums[j].power_usage ~= 0 ) then
				log( "accum "..j.." has(usg):".. accums[j].power_usage )
			end
			if( accums[j].electric_drain > 0 ) then
				log( "accum "..j.." has(drain):".. accums[j].electric_drain )
			end

		end
	end
end

local function migrateAccumulators() 
	local surfaces = game.surfaces;
	--logAccumulators();
	for _,surface in pairs(surfaces) do
		accums = surface.find_entities_filtered{ name="rail-accu" }
		--log( "Total:".. #accums );
		for _,accum in pairs(accums) do

			if( accum.electric_buffer_size ~= 30000 ) then
				--log( "update accumulator:"..j.." from ".. accum.electric_buffer_size);
				accum.electric_buffer_size = 30000;
				accum.energy = 30000;
			end
			if( accum.electric_drain > 0 ) then
				--log( "accum "..j.." has:".. accums[j].electric_drain )
				accum.electric_drain=0
			end
		end
	end
end


local function loadEngines( train, ltrain )
	local j;

	--log( "Setup hybrid engines" );
	local movers = train.locomotives.front_movers;
	local added = false;
	local engines = nil;
	--log_keys( hybridLocos )
	local move = hybridLocos;
	for j=1,#movers do
		--log( "FMover:"..movers[j].name );
		if( movers[j].name == 'hybrid-train' ) then
			--log( "Add Engine." );
			engines = {next = engines, engine= movers[j] };
			if not added then
				--log( "Add hybrid train itself" );
				hybridLocos = { train=train, engines=engines, next=hybridLocos};
				ltrain.hybrid = hybridLocos;
				added = true;
			end
		end
	end
	local movers = train.locomotives.back_movers;
	for j=1,#movers do
		--log( "BMover:"..movers[j].name );
		if( movers[j].name == 'hybrid-engine' ) then
			--log( "Add Engine." );
			engines = {next = engines, engine= movers[j] };
			if not added then
				--log( "Add hybrid train itself" );
				hybridLocos = { train=train, engines=engines, next=hybridLocos};
				ltrain.hybrid = hybridLocos;
				added = true;
			end
		end
	end
	if( added ) then
		-- update loco engines, becuase it's a insert at start operation.
		--log( "updat eengines" );
		hybridLocos.engines = engines;
	end

end


local function loadTrains()
	local surfaces = game.surfaces;--players[event.player_index]
	--log_keys( surfaces );	
	for name,surface in pairs(surfaces) do
		local trains = surface.get_trains();		
		--log( "Surface trains:".. tostring(#trains) .. " "..tostring(enableHybridTick ));
		for i=1, #trains do
			local train = trains[i];
			--log( "Surface add train:" .. trains[i].id );
			local newTrain = {train=train, lastRail = nil, next=global.trains, hybrid=nil, prior = nil}
			if global.trains then
				global.trains.prior = newTrain;
			end
			global.trains = newTrain;
			--log( "added train:"..tostring( newTrain.train.id ) );
			--log_keys(train.locomotives )
			if enableHybridTick then
				loadEngines( train, global.trains );
			end
		end
		
	end
end


local function glob_init()
	
	global.trains = nil;
	global.track_types = {};
	--global.hybrid_train_energy_buffer = 0;

	if( game.entity_prototypes["hybrid-train"] ) then 	
		enableHybridTick = true;
		--log( "RAIL SYSTEM UPGRADE")
		global.hybrid_train_energy_buffer = game.entity_prototypes["hybrid-train"].max_energy_usage + 10;
        	hybridEnergy = global.hybrid_train_energy_buffer
	end

	for name,entity in pairs(game.entity_prototypes) do
		--log( "check entity:"..entity.type.." : "..entity.name );
		if entity.type == "straight-rail" then

			-- BridgeRailway
			if entity.name == "bridge-straight-rail" then
				--log( "add type bridge" );
				global.track_types[#global.track_types+1] = "bridge";

			-- JunkTrain
			elseif entity.name == "straight-scrap-rail" then
				--log( "add type scrap" );
				global.track_types[#global.track_types+1] = "scrap";

			-- bio industries wood bridge
			elseif entity.name == "bi-straight-rail-wood-bridge" then
				--log( "add type bi-bridge" );
				global.track_types[#global.track_types+1] = "bi-bridge";

			-- bio industries wood
			elseif entity.name == "bi-straight-rail-wood" then
				--log( "add type bi-wood" );
				global.track_types[#global.track_types+1] = "bi-wood";
			-- RailPowerSystem
			elseif entity.name == "straight-rail-power" then
				--log( "add type power" );
				global.track_types[#global.track_types+1] = "power";

			elseif entity.name == "straight-rail-bridge-power" then
				--log( "add type power-bridge" );
				global.track_types[#global.track_types+1] = "power-bridge";

			elseif entity.name == "straight-rail-concrete-power" then
				--log( "add type power-concrete" );
				global.track_types[#global.track_types+1] = "power-concrete";

			-- base game
			elseif entity.name == "straight-rail" then
				--log( "add type standard" );
				global.track_types[#global.track_types+1] = "standard";
			else
				log( "unhandled track type:".. entity.name );
			end
		end
	end

	setupTypes();
	migrateAccumulators();
	loadTrains();
end

local function setupEvents()

---------------------------------------------------
-- build and unbuild
---------------------------------------------------
	if game.entity_prototypes["hybrid-train"] and game.entity_prototypes["bi-straight-rail-wood"] then
		function OnBuildEntity(entity)
			-- remove automatic connected cables
			--log( "something1:".. entity.name );
			onGlobalBuilt(entity)
			--log_keys( entities );
			if entities[entity.name] and entities[entity.name].onBuilt then
				entities[entity.name].onBuilt(entity)
			end	
		end

		function OnPreRemoveEntity(entity)
			if entities[entity.name] and entities[entity.name].onRemove then
				entities[entity.name].onRemove(entity)
			end	
		end


		script.on_event(defines.events.on_robot_built_entity, function(event)
			OnBuildEntity(event.created_entity)
		end)

		script.on_event(defines.events.on_built_entity, function(event)
			OnBuildEntity(event.created_entity)
		end)

		--premined
		script.on_event(defines.events.on_robot_pre_mined, function(event)
			OnPreRemoveEntity(event.entity)
		end)

		script.on_event(defines.events.on_pre_player_mined_item, function(event)
			OnPreRemoveEntity(event.entity)
		end)
	end
end


local flyingTextShow = 0;

function lowPrec( n ) 
	if n < 0 then
		return n + ( (-n) % 0.0001 )
	else
		return n - n % 0.0001
	end
end
function lowerPrec( n ) 
	if n < 0 then
		return n + ( (-n) % 0.1 )
	else
		return n - n % 0.1
	end
end
---------------------------------------------------
-- TICK
---------------------------------------------------
local function limitTrains( ticks ) 
	--log( "---- LIMIT TRAINS------".. tostring( global.trains ) );
	local ltrain = global.trains;
	while ltrain do
		local train = ltrain.train;
		--log( "Train :"..tostring(ltrain).." or ".. tostring(ltrain.train.locomotives.front_movers[1].name) .. " or " .. ltrain.train.id);
		repeat
			if( train.valid ) then
				local frontRail;
				local _lastRail = ltrain.lastRail;
				local speed = train.speed;
				local negate = false;
				if speed == 0 then break end
				if speed < 0 then 
					negate = true;
					speed = -speed;
					frontRail = train.back_rail;
				else
					frontRail = train.front_rail;
				end
				--log( "train buffer:".. train.max_energy_usage );
				if _lastRail then
					if( _lastRail.rail ~= frontRail ) then
						--log( "New Rail..." );
						_lastRail.rail = frontRail;
					else
						local lrs = _lastRail.speed;
						_lastRail.speed = speed;
						local tt = _lastRail.type;
						if tt then
							--[[if speed < (lrs ) then -- * 0.97
								if flyingTextShow <= 0 then
								         game.players[1].print( "Cur: "..lowPrec(speed) .. "("..lowerPrec(speed/kpt)..") Prior:"..lowPrec(lrs).. "("..lowerPrec(lrs/kpt)..") delta:"..lowPrec(speed-lrs).."("..lowerPrec((speed-lrs)/kpt)..")" )
								         --game.surfaces[1].create_entity{name = "flying-text", position = {train.locomotives.front_movers[1].position.x+1,train.locomotives.front_movers[1].position.y-2}, text = {"Cur: "..speed .. "("..speed/kpt..") Prior:"..lrs.. "("..lrs/kpt..") delta:"..(speed-lrs).."("..(speed-lrs)/kpt..")" }, color = {r=1,g=1,b=1}}
									flyingTextShow = 60;
								else
									if( flyingTextShow > 0 ) then
										flyingTextShow = flyingTextShow - 1; 
									end
								end
							end--]]
							--log( "speed input is part of last speed?".. lowPrec( lrs/speed ) .. " : ".. lowPrec( speed ) .. " > ".. lowPrec( lrs ).. " ... ".. lowPrec( speed/lrs ) );
							--log( "speed input is part of last speed?".. tostring(_lastRail.slowing).. "  ".. lowPrec( speed/lrs ) .. "     ".. lowerPrec(speed/kpt) );
							if( (speed ) > lrs ) then 
								--log( "(ST)update train speed on:" .. tt.name .. " by ".. tt.q .. " from ".. lowPrec(train.speed) .. "("..lowerPrec(train.speed/kpt)..")" );
								speed = speed * (tt.q);
								if( speed/lrs < 1.001 ) then
									--log( "RESET SLOWING" );
									_lastRail.slowing = false;
								end
							else
								if( _lastRail.slowing and (speed/lrs) > 0.994 ) then
									speed = speed * (tt.q) * 0.95;
								else
									--log( "RESET SLOWING" );
									_lastRail.slowing = false;
								end
								--log( "SLOWING" )
							end
							if( speed > tt.max ) then
								--log( "(ST)Overspeed" );
								speed = speed - (( speed-tt.max ) * 0.1);
								--train.speed = _lastRail.type.max;
								--log( "to:" .. train.speed );
							end
							--log( "update train speed from:" .. lowPrec(train.speed).."("..lowerPrec(train.speed/kpt)..")".." lastSet: ".. lowPrec(lrs).."("..lowerPrec(lrs/kpt)..")" .. " to ".. lowPrec(speed).."("..lowerPrec(speed/kpt)..")".. " + "..lowPrec(speed/lrs) .. " + "..lowPrec(speed/train.speed));
							if negate then
								train.speed = -speed;
							else
								train.speed = speed;
							end
							break;
						end
					end
				else 
					ltrain.lastRail = { rail=frontRail, slowing = false, type = nil, speed = speed }
					_lastRail = ltrain.lastRail;
				end
						

--	local frontLoco = train.locomotives.front_movers[1];
--	if not frontLoco then
--		frontLoco = train.locomotives.back_movers[1];
--	end
--	if not frontLoco then
		--log( "no movers on this train..." );
--		return
--	end

--	log( "loco:".. tostring(frontLoco.name )); 
--	log( "riding  State:".. tostring(frontLoco.riding_state )); 
--	log( "riding  State:".. tostring(train.riding_state )); 

	--local currentFuel = frontLoco.get_burnt_result_inventory();
--	local burner = frontLoco.burner;
--	if burner then 
--		local currentFuel = burner.currently_burning;
--		if currentFuel then 
			--log( "burning:".. currentFuel.name.. " amount:".. burner.remaining_burning_fuel  );
--		else
			--log( "no current fuel." );
--		end
--	end
				
				-- vehicle does not mean train... must be car or player
				---if( index == 2 ) then 
				--   log( "riding  State:".. tostring(frontLoco.riding_state )); 
				--end
				local lrs = _lastRail.speed;
                        	_lastRail.speed = speed;
			
				if( speed > 0.001 ) then
					local tt;
					local fasterTrack = false;
					--log( "Increase ".. tostring( speed >= lrs ) .. " speed:"..speed.." old:".. lrs );
						for i=1, #track_types do
							tt = track_types[i];
							--log( "track type check:"..tt.name..  " == "..frontRail.name );
							if( tt.name == frontRail.name ) then
								--[[if _lastRail.type then
									if( tt.q > _lastRail.type.q ) then
										--log( "FASTER" );
										fasterTrack = true;
									end
								end ]]
								if _lastRail.type then
									if( tt.q < _lastRail.type.q ) then
										--log( "SET SLOWING" );
										_lastRail.slowing = true;
									elseif( tt.q > _lastRail.type.q ) then
										--log( "RESET SLOWING" );
										_lastRail.slowing = false;
									end
								end
								_lastRail.type = tt;
								break;
							end
                        			end
			
					--[[if( speed < (lrs) ) then --* 0.97
						if flyingTextShow <= 0 then
						         game.players[1].print( "Cur: "..lowPrec(speed) .. "("..lowerPrec(speed/kpt)..") Prior:"..lowPrec(lrs).. "("..lowerPrec(lrs/kpt)..") delta:"..lowPrec(speed-lrs).."("..lowerPrec((speed-lrs)/kpt)..")" )
							flyingTextShow = 60;
						else
							if( flyingTextShow > 0 ) then
								flyingTextShow = flyingTextShow - 1; 
							end
                        			end
			
						log( "SLOWER:".. train.speed.. "something:".. tt.max.. " Q:"..tt.q );
						
					end--]]
					--log( "speed input is part of last speed?".. lowPrec( lrs/speed ) .. " : ".. lowPrec( speed ) .. " > ".. lowPrec( lrs ).. " ... ".. lowPrec( speed/lrs ) );
					--log( "speed input is part of last speed?".. tostring(_lastRail.slowing).. "  ".. lowPrec( speed/lrs ) .. "     ".. lowerPrec(speed/kpt));
					if( (speed) > lrs ) then --* 0.97
						--log( "train speed:".. lowPrec(train.speed).."("..lowerPrec(train.speed/kpt)..")".. "  something:".. tt.max.. " Q:"..tt.q );
						speed = speed * (tt.q);           
						--log( "After modification...".. lowPrec( speed/lrs ) );
						if( speed/lrs < tt.q + 0.000001 ) then
							--log( "RESET SLOWING".. speed/lrs );
							_lastRail.slowing = false;
						end
						--log( "update train speed on:" .. " by ".. tt.q .. " from ".. lowPrec(train.speed).."("..lowerPrec(train.speed/kpt)..")" .. " to ".. lowPrec(speed).."("..lowerPrec(speed/kpt)..")" );
						--log( "set train speed" .. train.id .. " to "..speed.. "ticks:" ..ticks );
					else
						if( _lastRail.slowing and (speed/lrs) > 0.994 ) then
							speed = speed * (tt.q);
							--log( "After modification...".. lowPrec( speed/lrs ) );
						end
						--log( "SLOWER:".. train.speed.. "something:".. tt.max.. " Q:"..tt.q );
					end
					if( speed > tt.max ) then
						--log( "OverSpeed!" );
						speed = speed - (( speed-tt.max ) * 0.1);
					end
					--log( "update train speed from:"..lowPrec(train.speed) .. "("..lowerPrec(train.speed/kpt)..")".. " last:" .. lowPrec(lrs).."("..lowerPrec(lrs/kpt)..")" .. " to ".. lowPrec(speed) .. "("..lowerPrec(speed/kpt)..")".. " + "..lowPrec(speed/lrs) .. " + "..lowPrec(speed/train.speed) );
					if negate then
						train.speed = -speed;
					else
						train.speed = speed;
					end
				else
					--log( "update train speed on:" .. lrs .. " to ".. speed);
					if negate then
						train.speed = -speed;
					else
						train.speed = speed;
					end
                        	end
                        
			else 
				--log( "skipping train (internal index):" );
				if not ltrain.prior then global.trains = ltrain.next;
				else ltrain.prior.next = ltrain.next; end
				if ltrain.next then ltrain.next.prior = ltrain.prior; end
				if( ltrain.hybrid ) then
					local hb = ltrain.hybrid;
					if hb.next then hb.next.prior = hb.prior; end
					if hb.prior then hb.prior.next = hb.next; else hybridLocos = hb.next; end
				end
			end
		until true
		ltrain = ltrain.next;
	end


	--log( 'train: '..train.id..'('..frontLoco.name..') is on:'..frontRail.name );
end

script.on_event(defines.events.on_tick, function(event)
	--if event.research.name==trainWhistleTech then
	--log( "active trains:"..#global.trains);

	local ticks = 0;
	if lastTick == 0 then
		setupEvents();
		--log( "first tick...".. tostring(lastTick ) );
		if force_reinit then	
			global.trains = nil;
			hybridLocos = nil;
			loadTrains();
			--glob_init();
		end

		lastTick = event.tick;
		return;
	end
	--ticks = event.tick - lastTick;
	lastTick = event.tick;
	if( enableHybridTick ) then
		--log( "Tick with Hybrid" );
		--logAccumulators();
		local loco = hybridLocos;
		while loco do
			local _rail = nil;
			--local F = 0;
			--local B = 0;
			local rail = loco.train.front_rail;
			local lengine = loco.engines;
			--log( "Refil loco engines.----------------------" );
			--local count = 1;
			while lengine do
				local engine = lengine.engine;
				local requiredPower=hybridEnergy-engine.energy;
				local ghostAccu=ghostRailAccu(rail)
				--log( "Rail:".. tostring(rail.name).. " train has ".. engine.energy.. " accum has:".. ghostAccu.energy .. " draining:"..ghostAccu.electric_drain .." GApos:"..ghostAccu.position.x..","..ghostAccu.position.y .." Railpos:"..rail.position.x..","..rail.position.y );
--[[
				if( event.tick%60 == 0 )then
					local c;

					if B == 0 and F==0 then c = {r=1,g=1,b=1};
					elseif B==1 then c = {r=1,g=0,b=0};
					elseif B==2 then c =  {r=0,g=1,b=0};
					elseif B==3 then c =  {r=0,g=0,b=1};
					elseif F==1 then c = {r=1,g=1,b=0};
					elseif F==2 then c =  {r=0,g=1,b=1};
					elseif F==3 then c =  {r=1,g=0,b=1};
					end
					game.surfaces[1].create_entity{name = "flying-text"
							, position = {rail.position.x + (count/2),rail.position.y}
							, text = tostring(count)
							, color = c}
				end
]]
				if ghostAccu then
					local max_power = ghostAccu.energy
					local power_transfer = 0
					if (max_power < requiredPower) then
						power_transfer = max_power
					else
						power_transfer = requiredPower
					end
				  
					--  Transfer energy that will be drained over the next second into some entity
					engine.energy = engine.energy + power_transfer
					ghostAccu.energy=max_power-power_transfer
				end
				
				lengine = lengine.next;
				--count = count + 1;
				if lengine then
					local next;
					--F=0;B=1;
					next = rail.get_connected_rail(backwardRail)
					if not next then 
						--B=2;
						--log( "Failed to get another rail0?"..tostring(rail) );
						next = rail.get_connected_rail(backwardRail1)
						if not next then
							--B=3;
							--log( "Failed to get another rail1?"..tostring(rail) );
							next = rail.get_connected_rail(backwardRail2)
							if not next then				
								--log( "Failed to get another rail2?"..tostring(rail) );
								--break 
							end
						end
					end
					if not next or next == _rail then
						--B=0;F=1;
						next = rail.get_connected_rail(forwardRail)
						if not next then 
							--F=2;
							--log( "Failed to get another rail0?"..tostring(rail) );
							next = rail.get_connected_rail(forwardRail1)
							if not next then
								--F=3;
								--log( "Failed to get another rail1?"..tostring(rail) );
								next = rail.get_connected_rail(forwardRail2)
								if not next then
									--log( "Failed to get another rail2?"..tostring(rail) );
									break; 
								end
							end
						end
					end
					_rail = rail;
					rail = next;
				end
			end
			loco = loco.next;
		end
		--logAccumulators();
	end
	--log( "TICKS: ".. ticks );
	--logAccumulators();

	limitTrains();
	--end
end)


---------------------------------------------------
--On train created
---------------------------------------------------

script.on_event(defines.events.on_train_created, function(event)
	local train = event.train;
	--log( "Created Train:"..train.id.. " mover:"..tostring(train.locomotives.front_movers[1]).. "  id1:"..tostring(event.old_train_id_1).."   id2:"..tostring(event.old_train_id_2)  );
	local i;
	
	if event.old_train_id_1 then
		--log( "check total: ".. #global.trains );
		local ltrain = global.trains;
		while ltrain do 
			--log( "check slot: ".. i );
			if not ltrain.train.valid then
				--log( " clear bad train:" );
				if not ltrain.prior then 
					global.trains = ltrain.next;
				else
					ltrain.prior.next = train.next;
				end
				if ltrain.next then
					ltrain.next.prior = ltrain.prior;
				end
				if( ltrain.hybrid ) then
					local hb = ltrain.hybrid;
					if hb.next then hb.next.prior = hb.prior; end
					if hb.prior then hb.prior.next = hb.next; else hybridLocos = hb.next; end
				end
			end
			ltrain = ltrain.next
		end
	end
	if not train.valid then
		log( "This train itself is not valid... don't do anything" );
		return
	end

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
	local ltrain = global.trains;
	while ltrain do 
		if ltrain.train == global.trains then
			--log( "train already tracked in global:"..train.id);
		end
		ltrain = ltrain.next;
	end

	local newTrain = { train=train, lastRail=nil, next = global.trains, hybrid=nil, prior = nil };
	if global.trains then
		global.trains.prior = newTrain;
	end
	global.trains = newTrain;
	if enableHybridTick then
		--log( "reload engines for this train." );
		loadEngines( train, global.trains );
	end
end )



script.on_event(defines.events.on_player_mined_entity, function(event)
	--log( 'player picked up:'.. event.entity.type );
	if( event.entity.type == "locomotive" ) then
		local train = event.entity.train;
		if not train then return end
		local ltrain = global.trains;
		while ltrain do
			if ltrain.train == train then
				--log( "Found train to remove".. i );
				if ltrain.prior then
					ltrain.prior.enxt = ltrain.next;
				else
					global.trains = ltrain.next;
				end
				if ltrain.next then
					ltrain.next.prior = ltrain.prior;
				end;
				local hbTrain = ltrian.hybrid;
				if hbTrain then
					if hbTrain.next then
						hbTrain.next.prior = hbTrain.prior;
					end;
					if hbTrain.prior then
						hbTrain.prior.next = hbTrain.next;
					else
						hybridLocos = hbTrain.next;
					end
				end
			end
		end
	
		--log( "Destroyed train?" );
	end
end)

script.on_event(defines.events.on_pre_surface_deleted, function(event)
	--log( "pre surface delete?" );
end)

script.on_event(defines.events.on_surface_created, function(event)
	--log( "surface create?" );
end)



function enableBlueprintFix()
	--script.on_event(defines.events.on_player_setup_blueprint, function(event)
	script.on_event(defines.events.on_player_configured_blueprint, function(event)
		--log( "surface create?" );
		local player = game.players[event.player_index]
		local stack = player.cursor_stack
		--log( "blueprint seetup." );
		if not stack.valid then 
			--log( "stack not valid" );
			return
		end
		if not stack.valid_for_read then
			--log( "stack not valid for read" );
			return
		end
		if stack.name ~= "blueprint" then
			--log( "stack is not a blueprint" );
			return
		end	
	        
		local entities = stack.get_blueprint_entities()
		--log( "blueprint has entities:".. #entities );
		if entities then
		for k, entity in pairs (entities) do
			if entity.name == ghostElectricPole then
				entity.name = railPole;
				items_changed = true;
			end
		end
		end
	        
		local blueprint_icons = player.cursor_stack.blueprint_icons
		for k=1,4 do
			if( blueprint_icons[k] ) then
				if blueprint_icons[k].signal.name == ghostElectricPole then
					blueprint_icons[k].signal.name = railPole
					break
				end
			end
		end
		player.cursor_stack.blueprint_icons = blueprint_icons
		stack.set_blueprint_entities(entities)
	        
		--local stack = player.cursor_stack. event.player_index	end)
	end)
end
-- Init existing trains
--local surfaces = game.surfaces;--players[event.player_index]
--log_keys( surfaces );

--------------------------------------------------
-- Startup Events
--------------------------------------------------


script.on_init(function()
	--log( "ON INIT" );

	glob_init()
end)


script.on_load(function()
	-- game is not available.
	-- called when save is reloaded.

	--log( "ON LOAD" );
	--if game then log( "HAVE GAME" ) else log( "NO GAME" ) end
	setupTypes();
	if global.trains then
		if not global.trains.train then			
			force_reinit = true;
		else
			local train = global.trains;
			while train do
				if train.hybrid then
					--log( "Found hybrid train in global." );
					local h = train.hybrid;
					while h.prior do h = h.prior; end
					hybridLocos = h;
					break
				end
				train = train.next;
			end
		end
	end
	hybridEnergy = global.hybrid_train_energy_buffer
	--log( "hybridEnergy is:".. tostring(hybridEnergy));
	if hybridEnergy then
	        enableHybridTick = true
	end
end)


script.on_configuration_changed( function()
	--log( "CONFIGURATION CHANGED" );
	if force_reinit then	
			global.trains = nil;
			hybridLocos = nil;
			--glob_init();
	end
	local mods = game.active_mods;
	for mod,version in pairs(mods) do
		--log( "Mod:"..mod.." "..version )
		if( mod == 'RailPowerSystem' ) then
			--if( version == '0.1.4' ) then
			enableHybridTick = true;
			--log( "RAIL SYSTEM UPGRADE")
			global.hybrid_train_energy_buffer = game.entity_prototypes["hybrid-train"].max_energy_usage + 10;
			hybridEnergy = global.hybrid_train_energy_buffer
			if( version == '0.1.4' ) then
				enableBlueprintFix();
			end
		elseif( mod == 'JunkTrain' ) then
		end
	end	
	glob_init()
	force_reinit = false;
end)

