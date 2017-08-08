


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

-- 219 W-LCCCC   260 S-LCCCC 272 LCC         298.1 R-LCCCC
-- 2599.2 (MAX) W-LLCCCC , LL CCCC CCCC, 
-- 110(1), 136(2) W-L CCCC CCCC

-- 2700 267 W-LLCCCC       337 R-LLCCCC
--    202 W-LLCCCC CCCC
--    152 W-LCCCC
--    108 W-LCCCC CCCC

-- cement
--  179 W-LCCCC     
--  323 W LLCCCC
--            171 R-L CCCC CCCC
--  254 W-LL CCCC CCCC   322 R 



-- 110 scrap rail  115.7 solid  123 rocket (max rail speed?)
-- 233 wood, normal  257.5 solid  293.4 rocket
-- 279 wood, cement  308 wolid   352 rocket fuel

-- scrap rail 81(wood) - 150.9 rocket
-- 250.2kmh 1.0 track (wood), full lap  260(solid)   390 rocket fuel

-- 73, 88, 134 (scrap rails)
--  169, 205, (302-312) (latest)  (standard rail)
--  184,      340  (concrete rail)
data.raw.locomotive.locomotive.max_power = "3000kW";  -- 600kW default
data.raw.locomotive.locomotive.max_speed = 4.0;  -- default 1.2
data.raw.locomotive.locomotive.air_resistance = 0.030;  -- default 0.0075
data.raw.locomotive.locomotive.burner.effectivity = 5;

-- data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.001;  -- default 0.01
data.raw["cargo-wagon"]["cargo-wagon"].max_speed = 4; --1.75; -- 378 -- default 1.5 (324)
data.raw["cargo-wagon"]["cargo-wagon"].air_resistance = 0.05; -- 0.01 default -- need to make sure it's worse to put one ahead of a train
data.raw["fluid-wagon"]["fluid-wagon"].max_speed = 4; --1.75; -- 378 -- default 1.5 (324)
data.raw["fluid-wagon"]["fluid-wagon"].air_resistance = 0.05; -- 0.01 default -- need to make sure it's worse to put one ahead of a train

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
        data.raw.locomotive.JunkTrain.max_power = "900kW"
	data.raw.locomotive.JunkTrain.max_speed = 1.0;  -- (216) default 0.3 (64)
	data.raw.locomotive.JunkTrain.air_resistance = 0.05;  -- default 0.03
	data.raw.locomotive.JunkTrain.burner.effectivity = 3.6;

	data.raw["cargo-wagon"]["ScrapTrailer"].weight = 500; -- 1500 default
	data.raw["cargo-wagon"]["ScrapTrailer"].max_speed = 0.5; -- 0.4 default

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
	data.raw.locomotive["hybrid-train"].air_resistance = 0.010; -- 0.0075 default
	data.raw.locomotive["hybrid-train"].burner.effectivity = 2.91667;
	data.raw["electric-energy-interface"]["rail-accu"].energy_source.buffer_capacity="29176.667J";  -- 29,166.667 in reality
	data.raw["electric-energy-interface"]["rail-accu"].energy_source.input_flow_limit="29176.667J";
	data.raw["electric-energy-interface"]["rail-accu"].energy_source.output_flow_limit="0kJ";

end

if data.raw.locomotive["petro-locomotive-1"] then
	-- weight = 3000
	data.raw.locomotive["petro-locomotive-1"].max_power = "1400kW";  -- 800kW default
	data.raw.locomotive["petro-locomotive-1"].max_speed = 4.0;  -- default 1.2
	data.raw.locomotive["petro-locomotive-1"].air_resistance = 0.008;  -- default 0.0075
	data.raw.locomotive["petro-locomotive-1"].burner.effectivity = 1.5;
end

if data.raw.locomotive["heavy-locomotive"] then
	-- weight = 2600
	  -- water  156.6  172.5  196.4
          -- standard - 180.1   198  225.9
          -- concrete - 197.7  218.1  248.2
	data.raw.locomotive["heavy-locomotive"].max_power = "2200kW";  -- 1100kW default
	data.raw.locomotive["heavy-locomotive"].max_speed = 4.0;  -- default 0.95  205.2 
	data.raw.locomotive["heavy-locomotive"].air_resistance = 0.03;  -- default 0.0075
	data.raw.locomotive["heavy-locomotive"].burner.effectivity = 2;  -- default 1

	-- weight = 2200
	--  water  215   236.9   269.6
	--  standard 255.6  281    320.4
	--  concrete 288.2  317.5  361.4	
	data.raw.locomotive["express-locomotive"].max_power = "2100kW";  -- 700kW default  (showw as 1166)
	data.raw.locomotive["express-locomotive"].max_speed = 4.0;  -- default 1.5   324
	data.raw.locomotive["express-locomotive"].air_resistance = 0.018;  -- default 0.005
	data.raw.locomotive["express-locomotive"].burner.effectivity = 1.801;  -- default 0.6

        -- weight = 4000
        -- water      213
	-- standard   266.5
        -- concrete   313.5
	data.raw.locomotive["nuclear-locomotive"].max_power = "3000kW";  -- 1600kW default
	data.raw.locomotive["nuclear-locomotive"].max_speed = 4.0;  -- default 1.4   302.4
	data.raw.locomotive["nuclear-locomotive"].air_resistance = 0.020;  -- default 0.0075
	data.raw.locomotive["nuclear-locomotive"].burner.effectivity = 1.875;  -- default 1

else
	if data.raw.locomotive["nuclear-locomotive"] then
	      -- 324kmh unmodified.  (speed cap)
	    -- scrap rail - 127        115.4
	    -- 1.0 rail  332           284 
	    --  concrete rail 360-372   355
	
        	data.raw.locomotive["nuclear-locomotive"].max_power = "2400kW"; -- 1200kW default
		data.raw.locomotive["nuclear-locomotive"].max_speed = 4.0; -- 1.5 default
		data.raw.locomotive["nuclear-locomotive"].air_resistance = 0.010; -- 0.0075 default
		data.raw.locomotive["nuclear-locomotive"].burner.effectivity = 1.5;  -- default 1
	
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


if data.raw.locomotive["electric-locomotive"] then
	-- weight = 2000
      -- original max 259.2 
	data.raw.locomotive["electric-locomotive"].max_power = "1200kW";  -- 600kW default
	data.raw.locomotive["electric-locomotive"].max_speed = 4.0;  -- default 1.2
	data.raw.locomotive["electric-locomotive"].air_resistance = 0.008;  -- default 0.0075
	data.raw.locomotive["electric-locomotive"].burner.effectivity = 2;
end

if data.raw.locomotive["electric-locomotive-mk2"] then
	-- weight = 2000
      -- original max 324
	data.raw.locomotive["electric-locomotive-mk2"].max_power = "1500kW";  -- 900kW default
	data.raw.locomotive["electric-locomotive-mk2"].max_speed = 4.0;  -- default 1.5
	data.raw.locomotive["electric-locomotive-mk2"].air_resistance = 0.0072;  -- default 0.005625
	data.raw.locomotive["electric-locomotive-mk2"].burner.effectivity = 1.667;
end

if data.raw.locomotive["electric-locomotive-mk3"] then
	-- weight = 2000
      -- original max 432
	data.raw.locomotive["electric-locomotive-mk3"].max_power = "1800kW";  -- 1200kW default
	data.raw.locomotive["electric-locomotive-mk3"].max_speed = 4.0;  -- default 2
	data.raw.locomotive["electric-locomotive-mk3"].air_resistance = 0.0064;  -- default 0.00375
	data.raw.locomotive["electric-locomotive-mk3"].burner.effectivity = 1.5;
end

if data.raw.locomotive["fusion-locomotive"] then
	-- weight = 2000
	data.raw.locomotive["fusion-locomotive"].max_power = "1800kW";  -- 1200kW default
	data.raw.locomotive["fusion-locomotive"].max_speed = 4.0;  -- default 1.4
	data.raw.locomotive["fusion-locomotive"].air_resistance = 0.010;  -- default 0.0075
	data.raw.locomotive["fusion-locomotive"].burner.effectivity = 1.5;
end

if data.raw.locomotive["farl"] then
	-- weight = 2000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["farl"].max_power = "900kW";  -- 600kW default
	data.raw.locomotive["farl"].max_speed = 4.0;  -- default 0.8
	data.raw.locomotive["farl"].air_resistance = 0.010;  -- default 0.0075
	--data.raw.locomotive["farl"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_emd1500blue"] then
	-- weight = 1500
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_emd1500blue"].max_power = "900kW";  -- 800kW default
	data.raw.locomotive["y_loco_emd1500blue"].max_speed = 4.0;  -- default 0.5
	data.raw.locomotive["y_loco_emd1500blue"].air_resistance = 0.008;  -- default 0.0035
	--data.raw.locomotive["y_loco_emd1500blue"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_emd1500blue_v2"] then
	-- weight = 1400
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_emd1500blue_v2"].max_power = "1000kW";  -- 900kW default
	data.raw.locomotive["y_loco_emd1500blue_v2"].max_speed = 4.0;  -- default 0.6
	data.raw.locomotive["y_loco_emd1500blue_v2"].air_resistance = 0.008;  -- default 0.0035
	--data.raw.locomotive["y_loco_emd1500blue_v2"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_emd1500black"] then
	-- weight = 1400
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_emd1500black"].max_power = "900kW";  -- 800kW default
	data.raw.locomotive["y_loco_emd1500black"].max_speed = 4.0;  -- default 0.5
	data.raw.locomotive["y_loco_emd1500black"].air_resistance = 0.008;  -- default 0.0035
	--data.raw.locomotive["farl"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_emd1500black_v2"] then
	-- weight = 1500
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_emd1500black_v2"].max_power = "1000kW";  -- 900kW default
	data.raw.locomotive["y_loco_emd1500black_v2"].max_speed = 4.0;  -- default 0.6
	data.raw.locomotive["y_loco_emd1500black_v2"].air_resistance = 0.008;  -- default 0.0035
	--data.raw.locomotive["y_loco_emd1500black_v2"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_fesw_op"] then
	-- weight = 1100
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_fesw_op"].max_power = "800kW";  -- 450kW default
	data.raw.locomotive["yir_loco_fesw_op"].max_speed = 4.0;  -- default 0.6
	data.raw.locomotive["yir_loco_fesw_op"].air_resistance = 0.008;  -- default 0.003
	--data.raw.locomotive["yir_loco_fesw_op"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_fut_red"] then
	-- weight = 6000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_fut_red"].max_power = "3600kW";  -- 3000kW default
	data.raw.locomotive["yir_loco_fut_red"].max_speed = 4.0;  -- default 2.5
	data.raw.locomotive["yir_loco_fut_red"].air_resistance = 0.014;  -- default 0.00275
	--data.raw.locomotive["yir_loco_fut_red"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_del_KR"] then
	-- weight = 3000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_del_KR"].max_power = "3000kW";  -- 2700kW default
	data.raw.locomotive["yir_loco_del_KR"].max_speed = 4.0;  -- default 2.5
	data.raw.locomotive["yir_loco_del_KR"].air_resistance = 0.014;  -- default 0.00275
	--data.raw.locomotive["yir_loco_del_KR"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_emd3000_white"] then
	-- weight = 2200
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_emd3000_white"].max_power = "1800kW";  -- 1200kW default
	data.raw.locomotive["y_loco_emd3000_white"].max_speed = 4.0;  -- default 0.9
	data.raw.locomotive["y_loco_emd3000_white"].air_resistance = 0.014;  -- default 0.003
	--data.raw.locomotive["y_loco_emd3000_white"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_del_bluegray"] then
	-- weight = 2000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_del_bluegray"].max_power = "2000kW";  -- 1300kW default
	data.raw.locomotive["yir_loco_del_bluegray"].max_speed = 4.0;  -- default 0.8
	data.raw.locomotive["yir_loco_del_bluegray"].air_resistance = 0.016;  -- default 0.00275
	--data.raw.locomotive["yir_loco_del_bluegray"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_del_mk1400"] then
	-- weight = 1800
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_del_mk1400"].max_power = "2300kW";  -- 1400kW default
	data.raw.locomotive["yir_loco_del_mk1400"].max_speed = 4.0;  -- default 0.75
	data.raw.locomotive["yir_loco_del_mk1400"].air_resistance = 0.018;  -- default 0.00275
	--data.raw.locomotive["yir_loco_del_bluegray"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_fs_steam_green"] then
	-- weight = 2000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_fs_steam_green"].max_power = "1700kW";  -- 1000kW default
	data.raw.locomotive["y_loco_fs_steam_green"].max_speed = 4.0;  -- default 0.9
	data.raw.locomotive["y_loco_fs_steam_green"].air_resistance = 0.012;  -- default 0.003
	--data.raw.locomotive["y_loco_fs_steam_green"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_loco_sel_blue"] then
	-- weight = 1900
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_loco_sel_blue"].max_power = "1800kW";  -- 1100kW default
	data.raw.locomotive["yir_loco_sel_blue"].max_speed = 4.0;  -- default 0.9
	data.raw.locomotive["yir_loco_sel_blue"].air_resistance = 0.012;  -- default 0.002
	--data.raw.locomotive["yir_loco_sel_blue"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_steam_wt450"] then
	-- weight = 1400
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_steam_wt450"].max_power = "900kW";  -- 450kW default
	data.raw.locomotive["y_loco_steam_wt450"].max_speed = 4.0;  -- default 0.625
	data.raw.locomotive["y_loco_steam_wt450"].air_resistance = 0.010;  -- default 0.003
	--data.raw.locomotive["y_loco_steam_wt450"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_desw"] then
	-- weight = 1400
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_desw"].max_power = "900kW";  -- 400kW default
	data.raw.locomotive["y_loco_desw"].max_speed = 4.0;  -- default 0.4
	data.raw.locomotive["y_loco_desw"].air_resistance = 0.014;  -- default 0.005
	--data.raw.locomotive["y_loco_desw"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_desw_orange"] then
	-- weight = 1600
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_desw_orange"].max_power = "900kW";  -- 500kW default
	data.raw.locomotive["y_loco_desw_orange"].max_speed = 4.0;  -- default 0.375
	data.raw.locomotive["y_loco_desw_orange"].air_resistance = 0.016;  -- default 0.004
	--data.raw.locomotive["y_loco_desw_orange"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_desw_blue"] then
	-- weight = 1800
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_desw_blue"].max_power = "900kW";  -- 600kW default
	data.raw.locomotive["y_loco_desw_blue"].max_speed = 4.0;  -- default 0.35
	data.raw.locomotive["y_loco_desw_blue"].air_resistance = 0.018;  -- default 0.004
	--data.raw.locomotive["y_loco_desw_blue"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_ses_std"] then
	-- weight = 1100
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_ses_std"].max_power = "600kW";  -- 300kW default
	data.raw.locomotive["y_loco_ses_std"].max_speed = 4.0;  -- default 0.4
	data.raw.locomotive["y_loco_ses_std"].air_resistance = 0.015;  -- default 0.005
	--data.raw.locomotive["y_loco_ses_std"].burner.effectivity = 1.5;
end

if data.raw.locomotive["y_loco_ses_red"] then
	-- weight = 900
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["y_loco_ses_red"].max_power = "600kW";  -- 300kW default
	data.raw.locomotive["y_loco_ses_red"].max_speed = 4.0;  -- default 1.4
	data.raw.locomotive["y_loco_ses_red"].air_resistance = 0.008;  -- default 0.002
	--data.raw.locomotive["y_loco_ses_red"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_atom_header"] then
	-- weight = 2000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_atom_header"].max_power = "3200kW";  -- 2500kW default
	data.raw.locomotive["yir_atom_header"].max_speed = 4.0;  -- default 1
	data.raw.locomotive["yir_atom_header"].air_resistance = 0.012;  -- default 0.00225
	--data.raw.locomotive["yir_atom_header"].burner.effectivity = 1.5;
end

if data.raw.locomotive["yir_atom_mitte"] then
	-- weight = 5000
	-- lower power; it had a default lower max speed...
	data.raw.locomotive["yir_atom_mitte"].max_power = "7500kW";  -- 5000kW default
	data.raw.locomotive["yir_atom_mitte"].max_speed = 4.0;  -- default 1
	data.raw.locomotive["yir_atom_mitte"].air_resistance = 0.011;  -- default 0.00225
	--data.raw.locomotive["yir_atom_mitte"].burner.effectivity = 1.5;
end


--[[

]]
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
			enabled = false
		})

		createData("recipe","powered-rail","powered-rail-concrete",
                { 
		        ingredients = { { "copper-cable", 3 }, { "rail", 1 } },
		        result = "powered-rail-concrete",
		        result_count = 1,
			enabled = false
		})

		data.raw.recipe["powered-rail"].ingredients = { { "copper-cable", 3 }, { "bi-rail-wood", 1 } }
		thxbob.lib.tech.add_recipe_unlock( "rail-power-system", "powered-rail-concrete" );
		thxbob.lib.tech.add_recipe_unlock( "rail-power-system", "powered-rail-bridge" );

	end

else
	log( "did not find:straight-rail-power" )
end
