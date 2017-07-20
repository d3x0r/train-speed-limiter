


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
-- scrap rail 81(wood) - 150.9 rocket
-- 250.2kmh 1.0 track (wood), full lap  260(solid)   390 rocket fuel
--  169, 205, 312 (latest)
--  184,      340
-- 450 rocket fuel(500max)
data.raw.locomotive.locomotive.max_speed = 4.0;  -- default 1.2
data.raw.locomotive.locomotive.air_resistance = 0.012;  -- default 0.0075

if data.raw.locomotive["JunkTrain"] then
   -- 31.9 unmodified(wood)
   -- 60.4 unmodified(rocket fuel) 
  -- 80 & 99.4
	-- 64kmh 1.0 track
	data.raw.locomotive.JunkTrain.max_speed = 0.4;  -- default 1.2
	data.raw.locomotive.JunkTrain.air_resistance = 0.012;  -- default 0.03


end

if data.raw.locomotive["nuclear-locomotive"] then
      -- 324kmh unmodified.  (speed cap)
    -- scrap rail - 105
    -- 1.0 rail - 380-404 (340 1 lap)
       -- 380 1 lap
	-- 561kmh 1.0 track
	data.raw.locomotive["nuclear-locomotive"].max_power = "1500kW"; -- 1200kW default
	data.raw.locomotive["nuclear-locomotive"].max_speed = 4.0; -- 1.5 default
	data.raw.locomotive["nuclear-locomotive"].air_resistance = 0.015; -- 0.0075 default

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

if data.raw.locomotive["hybrid-train"] then
	data.raw.locomotive["hybrid-train"].max_power = "1200kW";  -- 600kW default
	--reversing_power_modifier
	data.raw.locomotive["hybrid-train"].max_speed = 4.0; -- 1.5 default
	data.raw.locomotive["hybrid-train"].air_resistance = 0.0150; -- 0.0075 default

end


-- working_visualisations=table: 0x0000000011c3d830
--   1=table: 0x0000000011c3d890
--     effect=uranium-glow
--     light=table: 0x0000000011c3d8f0
--       intensity=0.6
--       size=9.9
--       shift=table: 0x0000000011c3d950
--         1=0
--         2=0
--       color=table: 0x0000000011c3d9b0
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
