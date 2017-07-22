local searchDirection = {{1,0},{1,1},{0,1},{-1,1},{-1,0},{-1,-1},{0,-1},{1,-1}}

local electricPole={}
local railPower={}
local ghostElectricPoles={}
local ghostElectricPolesNotSelectable={}
local entityghosts={}

entities = {}

--rail
railAccu="rail-accu"
railAccuBridge="rail-accu-bridge"
--powerRail="powered-rail"
railPole="rail-electric-pole"
ghostElectricPole="ghost-electric-pole"
ghostElectricPoleNotSelectable="ghost-electric-pole-not-selectable"
straightRailPower="straight-rail-power"
curvedRailPower="curved-rail-power"
straightRailBridgePower="straight-rail-bridge-power"
curvedRailBridgePower="curved-rail-bridge-power"
straightRailConcretePower="straight-rail-concrete-power"
curvedRailConcretePower="curved-rail-concrete-power"

entities[railPole]=electricPole

entities[straightRailPower]=railPower
entities[curvedRailPower]=railPower

entities[straightRailBridgePower]=railPower
entities[curvedRailBridgePower]=railPower
entities[straightRailConcretePower]=railPower
entities[curvedRailConcretePower]=railPower
entities[ghostElectricPole]=ghostElectricPoles
entities[ghostElectricPoleNotSelectable]=ghostElectricPolesNotSelectable
entities["entity-ghost"]=entityghosts


local railFromPole=function(entity,expectedItemType)
	local x=entity.position.x
	local y=entity.position.y
	log( "(TSL) type:"..expectedItemType .. " around:"..entity.name.."  "..x..","..y  .." ep: "..entity.position.x..","..entity.position.y .. " dir:".. entity.direction);
	local debugList = entity.surface.find_entities {{x-1.5,y-1.5},{x+1.5,y+1.5}}
	for i =1,#debugList do
		log( "found:"..debugList[i].name );
	end
	return entity.surface.find_entities_filtered{area = {{x-1.5,y-1.5},{x+1.5,y+1.5}}, name= expectedItemType}[1]
end

local poleGhostEntities=function(entity)
	local x=entity.position.x
	local y=entity.position.y
	return entity.surface.find_entities_filtered{area={{x-0.5,y-0.5},{x+0.5,y+0.5}},name=ghostElectricPoleNotSelectable}
end

local function connectWires(firstGhost,secondGhost)	
	log( "(TSL)connectWires:".. tostring( firstGhost.name ).." to ".. tostring(secondGhost.name))
	if firstGhost and secondGhost then
		firstGhost.connect_neighbour{wire=defines.wire_type.red,target_entity=secondGhost}
		firstGhost.connect_neighbour{wire=defines.wire_type.green,target_entity=secondGhost}
		firstGhost.connect_neighbour(secondGhost)
	end
end

local function connectGhostsInsideRail(rail)
	local ghostRailsEntities=railGhostEntities(rail)
	log( "(TSL)conectGhosts:"..#ghostRailsEntities)
	if #ghostRailsEntities<2 then
		return
	end
	for i=1,#ghostRailsEntities-1,1 do
		connectWires(ghostRailsEntities[i],ghostRailsEntities[i+1])		
	end
end

function onGlobalBuilt(entity)
	if entity.type=="electric-pole" then	
		for _,neighbour in pairs(entity.neighbours.copper) do
			if neighbour.name == ghostElectricPoleNotSelectable or entity.name==ghostElectricPoleNotSelectable then
				entity.disconnect_neighbour(neighbour)
			end
		end
	end
end

local newEntity = nil;

ghostElectricPoles.onBuilt=function(entity)
	--local newEntity=addGhostEntity(entity,{entity.position.x,entity.position.y},ghostElectricPole,true)	
	newEntity = entity;
end

ghostElectricPolesNotSelectable.onBuilt = function(entity )
	log( "TSL GEPNS." );
	local floorEntity = entity;

	log( "(TSL)Raise event direction:".. entity.direction );
	--connectWires( floorEntity, newEntity );

	--local newEntity=addGhostEntity(entity,{entity.position.x,entity.position.y},ghostElectricPole,true)	
	--local floorEntity=addGhostEntity(entity,{entity.position.x,entity.position.y},ghostElectricPoleNotSelectable,false)	
	--connectWires(floorEntity,newEntity)
	local railToConnect=railFromPole(entity,straightRailConcretePower) or railFromPole(entity,curvedRailConcretePower)
	         or railFromPole(entity,straightRailBridgePower) or railFromPole(entity,curvedRailBridgePower)
	log( "rail to connect:"..tostring(railToConnect));
	local railEntity = closestRailGhostEntity(floorEntity,railToConnect);
	if railEntity then
		connectWires(floorEntity,railEntity)	
	else
		log( "(TSL)Failed to find rail entity to connect to." );
	end

end

entityghosts.onBuilt=function(entity)
	local ghost_name= entity.ghost_prototype.name

	log( "(TSL)ghost power?"..entity.name );
	if ghost_name==ghostElectricPole then
		game.surfaces[entity.surface.name].create_entity{
			name="entity-ghost",
			position=entity.position,
			force=entity.force,
			inner_name=railPole,
		}
		entity.destroy()
	end
end

electricPole.onBuilt=function(entity)
	log( "(TSL)Built POwer POle... lookging for entity?" );
	local newEntity=addGhostEntity(entity,{entity.position.x,entity.position.y},ghostElectricPole,true)	
	local floorEntity=addGhostEntity(entity,{entity.position.x,entity.position.y},ghostElectricPoleNotSelectable,false)	
	connectWires(floorEntity,newEntity)
	local railToConnect=railFromPole(entity,straightRailConcretePower) 
	         or railFromPole(entity,curvedRailConcretePower) 
	         or railFromPole(entity,straightRailBridgePower) 
	         or railFromPole(entity,curvedRailBridgePower)
	connectWires(floorEntity,closestRailGhostEntity(floorEntity,railToConnect))	
	entity.destroy()
end

railPower.onBuilt=function(entity)
	local ghostEntities={}

	local fromMine = true;

	if entity.name == straightRailPower or entity.name == curvedRailPower then
		fromMine = false;
	end

	if fromMine then	        
		for i,node in pairs(nodesPositions(entity)) do
			ghostEntities[i]=addGhostEntity(entity,node,ghostElectricPoleNotSelectable,false)		
		end	
		
		local ghostAccu= nil;
		if entity.name == straightRailPowerBridge or entity.name == curvedRailPowerBridge then
			ghostAccu = addGhostEntity(entity,entity.position,railAccuBridge,false)
		else	        
			ghostAccu = addGhostEntity(entity,entity.position,railAccu,false)
		end
	
		connectGhostsInsideRail(entity)
	end

	--connect to all possible rails
	for _,railDir in pairs(defines.rail_direction) do
		for _,railConnDir in pairs(defines.rail_connection_direction) do
			if railConnDir~=defines.rail_connection_direction.none then			
				local connectedRail=entity.get_connected_rail{rail_direction=railDir,rail_connection_direction=railConnDir}
	
				if connectedRail and (connectedRail.name==straightRailConcretePower 
                                                      or connectedRail.name==curvedRailConcretePower
				                      or connectedRail.name==straightRailBridgePower
                                                      or connectedRail.name==curvedRailBridgePower
				                      or ( fromMine and connectedRail.name==straightRailPower )
                                                      or ( fromMine and connectedRail.name==curvedRailPower )
					             ) then
					local firstGhostEntity=nil
					local secondGhostEntity=nil
					local localDistance=99999999
					for _,ghostEntity in pairs(ghostEntities) do
						local closestGhost=closestRailGhostEntity(ghostEntity,connectedRail)		
						if closestGhost and distance(ghostEntity,closestGhost)<localDistance then														
							localDistance=distance(ghostEntity,closestGhost)
							firstGhostEntity=ghostEntity
							secondGhostEntity=closestGhost
						end
					end
					connectWires(firstGhostEntity,secondGhostEntity)				
				end
			end
		end
	end
end

ghostElectricPoles.onRemove=function(entity)
	for _,ghostEntity in pairs(poleGhostEntities(entity)) do
		if ghostEntity and ghostEntity.valid then
			ghostEntity.destroy()
		end
	end
end

electricPole.onRemove=function(entity)
end

railPower.onRemove=function(entity)
	for _,ghostEntity in pairs(railGhostEntities(entity)) do
		if ghostEntity and ghostEntity.valid then
			ghostEntity.destroy()
		end
	end
	local ghostRailAccuEntity=ghostRailAccu(entity)
	if ghostRailAccuEntity and ghostRailAccuEntity.valid then
		ghostRailAccuEntity.destroy()
	end
end
