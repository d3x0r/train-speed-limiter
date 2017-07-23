
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

local scrapPenalty = 0.992;
local waterPenalty = 0.9975;
local standardBonus = 1.0;
local concreteBonus = 1.003;

local track_types = {}

local lastRail = {};
local lastTick = 0;

local enableHybridTick = false;
local hybridEnergy = 0;
local hybridLocos = {};
local hybridEngines = {};

local temp = false;  -- one time init for tick to sync lastTick
local backwardRail = {rail_direction=defines.rail_direction.back, rail_connection_direction=defines.rail_connection_direction.straight};
local previousAccuTable = {};


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
				track_types[#track_types+1] = { name = "curved-rail-wood-bridge", max=(kpt)*280, q = waterPenalty }
				track_types[#track_types+1] = { name = "straight-rail-wood-bridge", max=(kpt)*280, q = waterPenalty }

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

local function loadEngines( i, train )
	local j;

				log( "Setup hybrid engines" );
			--if enableHybridTick then
				local movers = train.locomotives.front_movers;
				local added = false;
				local engines = {};
				local loco = {};
				--log_keys( hybridLocos )
				for j=1,#movers do
					log( "FMover:"..movers[j].name );
					if( movers[j].name == 'hybrid-train' ) then
						if not added then
							hybridLocos[i] = { train=train, engines=engines};
							added = true;
						end
						engines[#engines+1] = movers[j];
					end
				end
				local movers = train.locomotives.back_movers;
				for j=1,#movers do
					log( "BMover:"..movers[j].name );
					if( movers[j].name == 'hybrid-engine' ) then
						if not added then
							hybridLocos[i] = { train=train, engines=engines};
							added = true;
						end
						engines[#engines+1] = movers[j];
					end
				end
			--end

end



local function glob_init()
	
	global.trains = {}
	global.track_types = {};
	global.hybrid_train_energy_buffer = 0;
	local index = 1; -- for adding available rail types
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
			end

		end
	end

	setupTypes();

	local surfaces = game.surfaces;--players[event.player_index]
	--log_keys( surfaces );	
	for name,surface in pairs(surfaces) do
		local trains = surface.get_trains();		
		log( "Surface trains:".. tostring(#trains) .. " "..tostring(enableHybridTick ));
		for i=1, #trains do
			local train = trains[i];
			--log( "Surface add train:" .. trains[i].id );
			global.trains[i] = train;
			--log_keys(train.locomotives )
			if enableHybridTick then
				loadEngines( i, train );
			end
		end
		
	end

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

		script.on_event(defines.events.on_preplayer_mined_item, function(event)
			OnPreRemoveEntity(event.entity)
		end)
	end
end




---------------------------------------------------
-- TICK
---------------------------------------------------
local function limitTrain( ticks, index, train ) 
	local frontRail = train.front_rail;
	local _lastRail = lastRail[index];
	local speed = train.speed;

	--log( "train buffer:".. train.max_energy_usage );
	if( _lastRail ) then
		if( _lastRail.rail ~= frontRail ) then
			log( "New Rail..." );
			_lastRail.rail = frontRail;
		else
			local tt = _lastRail.type;
			if tt then
				if( speed >= (_lastRail.speed * 0.97) ) then
					log( "(ST)update train speed on:" .. tt.name .. " by ".. tt.q .. " from ".. train.speed );
					speed = speed * (tt.q*ticks);
				else
					log( "SLOWING" )
				end
				if( speed > tt.max ) then
					log( "(ST)Overspeed" );
					speed = speed - (( tt.max ) * 0.03 * ticks);
					--train.speed = _lastRail.type.max;
					--log( "to:" .. train.speed );
				end
				log( "update train speed from:" .. train.speed.." lastSet: ".. _lastRail.speed .. " to ".. speed);
				train.speed = speed;
				_lastRail.speed = speed;
				return;
			end
		end
	else 
		lastRail[index] = { rail=frontRail, type = nil, speed = speed }
		_lastRail = lastRail[index];
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

	if( speed > 0.001 ) then
		local tt;
		local fasterTrack = false;
		log( "Increase ".. tostring( speed >= _lastRail.speed ) .. " speed:"..speed.." old:".. _lastRail.speed );
			for i=1, #track_types do
				tt = track_types[i];
				--log( "track type check:"..tt.name..  " == "..frontRail.name );
				if( tt.name == frontRail.name ) then
					if _lastRail.type then
						if( tt.q > _lastRail.type.q ) then
							log( "FASTER" );
							fasterTrack = true;
						end
					end
					_lastRail.type = tt;
					break;
				end
			end
		if( fasterTrack or speed >= (_lastRail.speed * 0.97 ) ) then
			log( "train speed:".. train.speed.. "something:".. tt.max.. " Q:"..tt.q );
			speed = speed * (tt.q*ticks);
			log( "update train speed on:" .. tt.name .. " by ".. tt.q .. " from ".. train.speed .. " to ".. speed);
			--log( "set train speed" .. train.id .. " to "..speed.. "ticks:" ..ticks );
		else
			log( "SLOWER:".. train.speed.. "something:".. tt.max.. " Q:"..tt.q );
			
		end
		if( speed > tt.max ) then
			log( "OverSpeed!" );
			speed = speed - (( speed-tt.max ) * 0.03 * ticks);
		end
		log( "update train speed from:"..train.speed .. " last:" .. _lastRail.speed .. " to ".. speed);
		train.speed = speed;
	else
		log( "update train speed on:" .. _lastRail.speed .. " to ".. speed);
	end

	_lastRail.speed = speed;
	--log( 'train: '..train.id..'('..frontLoco.name..') is on:'..frontRail.name );
end


script.on_event(defines.events.on_tick, function(event)
	--if event.research.name==trainWhistleTech then
	--log( "active trains:"..#global.trains);
	local ticks = 0;
	if lastTick == 0 then
		lastTick = event.tick;
		return;
	end
	ticks = event.tick - lastTick;
	lastTick = event.tick;
	if( enableHybridTick ) then
		--log( "Previous accums:".. #previousAccuTable );
		--for i=1, #previousAccuTable do
		--	local accum = previousAccuTable[i];
		--	if accum.valid then
		--		log( "Clear electric_drawin on prior" );
		--		accum.electric_drain=0
		--	end
		--end
		--previousAccuTable = {};
		local index = 1;
		for i,loco in pairs( hybridLocos)  do
			local train = loco.train;
			local rail = train.front_rail;
			for j=1, #loco.engines do
				local engine = loco.engines[j];
				local requiredPower=hybridEnergy-engine.energy;
				local ghostAccu=ghostRailAccu(rail)
				--log( "Rail:".. tostring(rail.name).. " train has ".. engine.energy.. " accum has:".. ghostAccu.energy .. " draining:"..ghostAccu.electric_drain );
				if ghostAccu then
					local max_power = ghostAccu.energy
					local power_transfer = 0
					if (max_power < requiredPower) then
						power_transfer = max_power
					else
						power_transfer = requiredPower
					end
				  
--					ghostAccu.electric_drain = power_transfer
					--  Transfer energy that will be drained over the next second into some entity
					engine.energy = engine.energy + power_transfer
					ghostAccu.energy=max_power-power_transfer
					previousAccuTable[index ] = ghostAccu;
					index = index+1;
				end
				
				rail = rail.get_connected_rail(backwardRail)
				if not rail then break end
			end
		end
		--logAccumulators();
	end
	if not temp then 
		--log( "process: ".. #global.trains );
		--log_keys( data.raw.entity.locomotive )
		setupEvents();
		temp = true;
	end
	for i=1,#global.trains do
		if global.trains[i] then
			if( global.trains[i].valid ) then
				limitTrain( ticks, i, global.trains[i] );		
			else 
				--log( "skipping train (internal index):".. i );
				global.trains[i] = nil;
			end
		end
	end
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
		for i = 1, #global.trains do
			--log( "check slot: ".. i );
			if not global.trains[i].valid then
				--log( " clear slot:"..i );
				global.trains[i] = nil;
				if enableHybridTick then
					hybridLocos[i] = nil;
				end
			end
		end
	end
	if not train.valid then
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

			if enableHybridTick then
				loadEngines( i, train );
			end
			return;
		end
	end
	--log( "filling train into last slot.".. (#global.trains+1) );
	i = #global.trains+1;
	global.trains[i] = train;
	if enableHybridTick then
		loadEngines( i, train );
	end
end )



script.on_event(defines.events.on_player_mined_entity, function(event)
	--log( 'player picked up:'.. event.entity.type );
	if( event.entity.type == "locomotive" ) then
		local train = event.entity.train;
		if not train then return end
		for i=1, #global.trains do
			if global.trains[i] == train then
				--log( "Found train to remove".. i );
				global.trains[i] = nil;
				hybridLocos[i] = nil;
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
		for k, entity in pairs (entities) do
			if entity.name == ghostElectricPole then
				entity.name = railPole;
				items_changed = true;
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
	log( "ON INIT" );
	glob_init()
end)

script.on_load(function()
	-- game is not available.
	-- called when save is reloaded.

	log( "ON LOAD" );
	--if game then log( "HAVE GAME" ) else log( "NO GAME" ) end
	setupTypes();
	hybridEnergy = global.hybrid_train_energy_buffer
        enableHybridTick = ( hybridEnergy ~= 0 )
end)


script.on_configuration_changed( function()
	log( "CONFIGURATION CHANGED" );
	local mods = game.active_mods;
	for mod,version in pairs(mods) do
		log( "Mod:"..mod.." "..version )
		if( mod == 'RailPowerSystem' ) then
			if( version == '0.1.4' ) then
				enableHybridTick = true;
				log( "RAIL SYSTEM UPGRADE")
                                global.hybrid_train_energy_buffer = game.entity_prototypes["hybrid-train"].max_energy_usage + 10;
                                hybridEnergy = global.hybrid_train_energy_buffer
				enableBlueprintFix();
			end
		elseif( mod == 'JunkTrain' ) then
			if( version == '0.0.9' ) then
				--log_keys( game );
				--game.prototype
			end
		end
	end	
	glob_init()
end)

