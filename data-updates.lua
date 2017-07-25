


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


--log( "DEFAULT AIR:" .. data.raw.locomotive.locomotive.air_resistance );
--log_keys( data.raw.locomotive );
--log_keys( data.raw );


-- 259.1 unmodified(wood)(speedcap)   298.1 unmodified (rocket fuel)
-- 450 rocket fuel(500max)

-- 110 scrap rail  115.7 solid  123 rocket (max rail speed?)
-- 233 wood, normal  257.5 solid  293.4 rocket
-- 279 wood, cement  308 wolid   352 rocket fuel

-- scrap rail 81(wood) - 150.9 rocket
-- 250.2kmh 1.0 track (wood), full lap  260(solid)   390 rocket fuel

-- 73, 88, 134 (scrap rails)
--  169, 205, (302-312) (latest)  (standard rail)
--  184,      340  (concrete rail)
data.raw.locomotive.locomotive.max_power = "1200kW";  -- 600kW default
data.raw.locomotive.locomotive.max_speed = 4.0;  -- default 1.2
data.raw.locomotive.locomotive.air_resistance = 0.008;  -- default 0.0075
data.raw.locomotive.locomotive.burner.effectivity = 1.5;

-- solid
--   2.905 Script data-final-fixes.lua:4: .     fuel_acceleration_multiplier=1.2
--   2.905 Script data-final-fixes.lua:4: .     fuel_top_speed_multiplier=1.05
-- rocket
--   2.906 Script data-final-fixes.lua:4: .     fuel_acceleration_multiplier=1.8
--   2.906 Script data-final-fixes.lua:4: .     fuel_top_speed_multiplier=1.15
-- bi-coke-coal
--   2.936 Script data-final-fixes.lua:4: .     fuel_acceleration_multiplier=1.1
--   2.936 Script data-final-fixes.lua:4: .     fuel_top_speed_multiplier=1.025


data.raw.item["solid-fuel"].fuel_acceleration_multiplier=1.10
data.raw.item["rocket-fuel"].fuel_acceleration_multiplier=1.25



local update_trains = true;

if update_trains then

if data.raw.locomotive["JunkTrain"] then
   -- 31.9 unmodified(wood)
   -- 60.4 unmodified(rocket fuel) 
   -- 30.0 scrap rail  57 rocket fuel
   -- 80 & 99.4
	-- 64kmh 1.0 track
        data.raw.locomotive.JunkTrain.max_power = "750kW"
	data.raw.locomotive.JunkTrain.max_speed = 1.0;  -- default 0.3
	data.raw.locomotive.JunkTrain.air_resistance = 0.05;  -- default 0.03
	data.raw.locomotive.JunkTrain.burner.effectivity = 1.50

	data.raw["rail-planner"]["scrap-rail"].icon = "__train-speed-limiter__/graphics/icons/scrap-rail.png"

end

if data.raw.locomotive["hybrid-train"] then
--  umodified 259.2
--     146
--     261 .9
--     275

	data.raw.locomotive["hybrid-train"].max_power = "1750kW";  -- 600kW default
	--reversing_power_modifier
	data.raw.locomotive["hybrid-train"].max_speed = 4.0; -- 1.5 default
	data.raw.locomotive["hybrid-train"].air_resistance = 0.012; -- 0.0075 default
	data.raw["electric-energy-interface"]["rail-accu"].energy_source.buffer_capacity="25kJ";

end



if data.raw.locomotive["nuclear-locomotive"] then
      -- 324kmh unmodified.  (speed cap)
    -- scrap rail - 127        115.4
    -- 1.0 rail  332           284 
    --  concrete rail 360-372   355

	data.raw.locomotive["nuclear-locomotive"].max_power = "2400kW"; -- 1200kW default
	data.raw.locomotive["nuclear-locomotive"].max_speed = 4.0; -- 1.5 default
	data.raw.locomotive["nuclear-locomotive"].air_resistance = 0.010; -- 0.0075 default

	data.raw.locomotive["nuclear-locomotive"].working_light = {
		color = {
			b = 0.0,
			g = 0.8,
			r = 0.0
		},
		intensity = 0.8,
		size = 3
	}
--	data.raw.locomotive["nuclear-locomotive"].working_visualisations={
--		{ effect="uranium-glow", light={intensity=0.6,size=9.9, shift={0,0}, color{r=0,g=1,b=0}}}
--	}
end

end

--log_keys( data.raw );


-- working_visualisations=table: 0x0000000011c3d830
--   1=table: 0x0000000011c3d890
--     effect=uranium-glow
--     light=table: 0x0000000011c3d8f0
--       intensity=0.6
--       size=9.9
--       shift=table: 0x0000000011c3d950
--         1=0
--         2=0
--       color=table: 0x0000000011c3d9b0                       `
--         r=0
--         g=1
--         b=0


--  effect_animation_period=5
--  effect_animation_period_deviation=1
--  effect_darkness_multiplier=3.6
--  min_effect_alpha=0.2
--  max_effect_alpha=0.3
--  map_color=table: 0x0000000016cb6490
--    r=0
--    g=0.7
--    b=0

--data.raw.locomotive.air_resistance.max_speed = 4.0;


-- if Rail Power System is installed; update icons.
--  if Bio Industries is also installed, add concrete and bridge rail types

if data.raw["straight-rail"]["straight-rail-power"] then

	data.raw["straight-rail"][straightRailPower].icon = "__train-speed-limiter__/graphics/icons/rail-wood-power.png"
	data.raw["rail-planner"][powerRail].icon = "__train-speed-limiter__/graphics/icons/rail-wood-power.png"
	local tmp = data.raw["electric-energy-interface"]["rail-accu"].collision_mask;
	--log_keys( tmp );
	--tmp[#tmp+1] = "object-layer"
	--log_keys( tmp );


	if data.raw["straight-rail"]['bi-straight-rail-wood'] then

	-- if bio industries is included, also extend power rails for matching types
		createData("straight-rail","straight-rail-power","straight-rail-bridge-power",
                {		
			icon = "__train-speed-limiter__/graphics/icons/rail-wood-bridge-power.png",
			minable = {mining_time = 0.6, result = "powered-rail-bridge"},
                	pictures=rail_pictures_w(),
			corpse = "straight-rail-remnants",
			collision_mask = { "object-layer", "not-colliding-with-itself" }
		})	
                
		createData("curved-rail","curved-rail-power","curved-rail-bridge-power",
		{		
                	icon = "__base__/graphics/icons/curved-rail.png",
			minable = {mining_time = 0.6, result = "powered-rail-bridge", count=4},
			placeable_by = { item="powered-rail-bridge", count = 4},
                	pictures=rail_pictures_w(),
			corpse = "curved-rail-remnants",
			collision_mask = { "object-layer", "not-colliding-with-itself" }
		})
                
		
		createData("straight-rail","straight-rail-power","straight-rail-concrete-power",
                {		
			icon = "__train-speed-limiter__/graphics/icons/rail-concrete-power.png",
			minable = {mining_time = 0.6, result = "powered-rail-concrete"},
                	pictures=rail_pictures_c(),
			corpse = "straight-rail-remnants",
		})	
                
		createData("curved-rail","curved-rail-power","curved-rail-concrete-power",
		{		
                	icon = "__base__/graphics/icons/curved-rail.png",
			minable = {mining_time = 0.6, result = "powered-rail-concrete", count=4},
			placeable_by = { item="powered-rail-concrete", count = 4},
                	pictures=rail_pictures_c(),
			corpse = "curved-rail-remnants",
		})
                
		createData("rail-planner","rail","powered-rail-bridge",
		{ 
                	flags = {"goes-to-quickbar"},
			subgroup = "transport",
			icon = "__train-speed-limiter__/graphics/icons/rail-wood-bridge-power.png",
                	place_result = "straight-rail-bridge-power",
			straight_rail = "straight-rail-bridge-power",
			curved_rail = "curved-rail-bridge-power",
                })
		
		createData("rail-planner","rail","powered-rail-concrete",
                { 
			flags = {"goes-to-quickbar"},
			subgroup = "transport",
                	icon = "__train-speed-limiter__/graphics/icons/rail-concrete-power.png",
			place_result = "straight-rail-concrete-power",
			straight_rail = "straight-rail-concrete-power",
                	curved_rail = "curved-rail-concrete-power",
		})

		createData("electric-energy-interface","rail-accu","rail-accu-bridge",
                { 
			collision_mask={"object-layer","not-colliding-with-itself"}
		})
		createData("item","rail-accu","rail-accu-bridge",
                { 
		})

		createData("recipe","powered-rail","powered-rail-bridge",
                { 
		        ingredients = { { "copper-cable", 3 }, { "bi-rail-wood-bridge", 1 } },
		        result = "powered-rail-bridge",
		        result_count = 1,
		})

		createData("recipe","powered-rail","powered-rail-concrete",
                { 
		        ingredients = { { "copper-cable", 3 }, { "rail", 1 } },
		        result = "powered-rail-concrete",
		        result_count = 1,
		})

		data.raw.recipe["powered-rail"].ingredients = { { "copper-cable", 3 }, { "bi-rail-wood", 1 } }
		thxbob.lib.tech.add_recipe_unlock( "rail-power-system", "powered-rail-concrete" );
		thxbob.lib.tech.add_recipe_unlock( "rail-power-system", "powered-rail-bridge" );

	end

else
	log( "did not find:straight-rail-power" )
end
