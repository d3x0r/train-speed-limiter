

local function migrateAccumulators() 
	local surfaces = game.surfaces;
	--logAccumulators();
	for _,surface in pairs(surfaces) do
		accums = surface.find_entities_filtered{ name="rail-accu" }
		--log( "Total:".. #accums );
		for _,accum in pairs(accums) do

			if( accum.electric_buffer_size ~= 25000 ) then
				--log( "update accumulator:"..j.." from ".. accum.electric_buffer_size);
				accum.electric_buffer_size = 25000;
				accum.energy = 25000;
			end
			if( accum.electric_drain > 0 ) then
				--log( "accum "..j.." has:".. accums[j].electric_drain )
				accum.electric_drain=0
			end
		end
	end
end
