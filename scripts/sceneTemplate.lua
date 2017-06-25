SCRIPT_NAME = "" --type unique sceneId here

--[[
call this when all entity set spawned and ready to go
	EDX["sceneBase"].raiseInitialized(getTarget())
	
call this when all spawned entity sets despawned
	EDX["sceneBase"].raiseDisposed()
	
call this when target escaped
	EDX["sceneBase"].raiseTargetEscaped()
--]]

onEDXInitialized = function()
	--OFP:showPopup(SCRIPT_NAME, "initialized")
	
	scripts.mission.waypoints.registerFunction("initialize")
	scripts.mission.waypoints.registerFunction("dispose")
	scripts.mission.waypoints.registerFunction("onSpotted")
	scripts.mission.waypoints.registerFunction("getMainObjective")
	scripts.mission.waypoints.registerFunction("getSubObjective")
	
	--OFP:showPopup("EDX.dataManager", tostring(EDX["dataManager"]))
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	if EDX["dataManager"].IsFirstRun() == true then
		data["setId"] = {}
		data["spotted"] = false
	end
end

initialize = function()
	--type spawn code here
	table.insert(data["setId"], OFP:activateEntitySet(""))
end

onSpawnedReady = function(setName, setID, tableOfEntities)
	if setName == "" then
		EDX["sceneBase"].raiseInitialized(getTarget())
	end
end

dispose = function()
	--type despawn code here
	for i=1, #data["setId"] do
		OFP:destroyEntitySet(data["setId"][i])
	end
end

onDespawnEntitySet = function(setID)
	for i=1, #data["setId"] do
		if data["setId"][i] == setID then
			table.remove(data["setId"], i)
			
			if #data["setId"] == 0 then
				EDX["sceneBase"].raiseDisposed()
			end
			
			break
		end
	end
end

onSpotted = function() --from sceneBase
	if not data["spotted"] then
		data["spotted"] = true
		
		--if next scene will not load when has been spotted in current scene, enable these lines.
		--[[
		OFP:displaySystemMessage("\231\155\174\230\160\135VIP\232\161\140\231\168\139\229\183\178\229\143\150\230\182\136")
		
		if OFP:isAlive(getTarget()) then
			OFP:setObjectiveState(getMainObjective(), "FAILED")
		else
			OFP:setObjectiveState(getMainObjective(), "COMPLETED")
		end
		
		OFP:setObjectiveState(getSubObjective(), "FAILED")
		OFP:setObjectiveVisibility(getSubObjective(), true)
		
		--EDX:simpleTimer("spotted", 9600)
		--]]
	end
end

getTarget = function()
	return "" --type target name here
end

getMainObjective = function()
	return "" --type your main objective name here
end

getSubObjective = function()
	return "" --type your sub objective name here
end

----------------------------------------
function spotted(timerId)
	OFP:missionFailed()
end
