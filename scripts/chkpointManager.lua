SCRIPT_NAME = "chkpointManager"

onEDXInitialized = function()
	--scripts.mission.waypoints.registerFunction("register")
	--scripts.mission.waypoints.registerFunction("scriptedCheckpoint")
	
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	if EDX["dataManager"].IsFirstRun() == true then
		data["map"] = {}
		data["ckpset"] = "ckpset"
		data["ckzset"] = "ckzset"
	end
end

onMissionStart = function()
	OFP:activateEntitySet(data["ckpset"])
end

--[[
register = function(checkpoint, zoneSetName)
	data["map"][OFP:activateEntitySet(zoneSetName)] = checkpoint
end
--]]

onSpawnedReady = function(setName, setID, tableOfEntities)
	if setName == data["ckpset"] then
		for _, ckp in pairs(tableOfEntities) do
			data["map"][OFP:spawnEntitySetAtEntityPosition(data["ckzset"], ckp)] = ckp
		end
	elseif data["map"][setID] then
		local ckp = data["map"][setID]
		data["map"][tableOfEntities[1]] = {
			["ckp"] = ckp,
			["ckz"] = setID
		}
		OFP:startParticleSystem(ckp, 0)
		data["map"][setID] = nil
	end
	--[[
	if data["map"][setID] then
		data["map"][tableOfEntities[1]-] = setID
		OFP:enableCheckpoint(data["map"][setID])
		data["map"][setID] = nil
	end
	--]]
end

onEnter = function(zone, unit)
	if unit == EDX:getPrimaryPlayer() then
		if data["map"][zone] then
			OFP:destroyEntitySet(data["map"][zone]["ckz"]) --this will cause sence completed
			OFP:stopParticleSystem(data["map"][zone]["ckp"])
			data["map"][zone] = nil
			
			EDX["dataManager"].Save()
			OFP:scriptedCheckpoint()
		end
	end
end

--[[
scriptedCheckpoint = function()
	EDX["dataManager"].Save()
	OFP:scriptedCheckpoint()
end
--]]
