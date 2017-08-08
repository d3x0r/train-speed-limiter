

local function migrateAccumulators() 
	local surfaces = game.surfaces;
	--logAccumulators();
	for _,surface in pairs(surfaces) do
		accums = surface.find_entities_filtered{ name="rail-accu" }
		--log( "Total:".. #accums );
		for _,accum in pairs(accums) do

			if( accum.electric_buffer_size ~= 29176.667 ) then
				--log( "update accumulator:"..j.." from ".. accum.electric_buffer_size);
				accum.electric_buffer_size = 29176.667;
				accum.electric_input_flow_limit = 29176.667;
				accum.electric_output_flow_limit = 0;  -- don't allow the rest of the network to draw from this storage.
				accum.energy = 29176.667;
			end
			if( accum.electric_drain > 0 ) then
				--log( "accum "..j.." has:".. accums[j].electric_drain )
				accum.electric_drain=0
			end
		end
	end
end
