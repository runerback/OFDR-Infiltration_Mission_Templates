SCRIPT_NAME="sceneBase"

onEDXInitialized = function()
	--OFP:showPopup(SCRIPT_NAME, "initialized")
	
	scripts.mission.waypoints.registerFunction("Initialize")
	scripts.mission.waypoints.registerFunction("Dispose")
	scripts.mission.waypoints.registerFunction("GetMainObjective")
	scripts.mission.waypoints.registerFunction("GetSubObjective")
	scripts.mission.waypoints.registerFunction("raiseInitialized")
	scripts.mission.waypoints.registerFunction("raiseDisposed")
	scripts.mission.waypoints.registerFunction("raiseSpotted")
	scripts.mission.waypoints.registerFunction("raiseTargetEscaped")
	
	--OFP:showPopup("EDX.dataManager", tostring(EDX["dataManager"]))
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	if EDX["dataManager"].IsFirstRun() == true then
		data["sceneId"] = -1
	end
end

Initialize = function(sceneId)
	data["sceneId"] = sceneId
	
	EDX[sceneId].initialize()
end

raiseInitialized = function(target)
	local mainObjective = GetMainObjective(data["sceneId"])
	OFP:setObjectiveState(mainObjective, "IN_PROGRESS")
	OFP:setObjectiveVisibility(mainObjective, "true")
	
	local subObjective = GetSubObjective(data["sceneId"])
	OFP:setObjectiveState(subObjective, "IN_PROGRESS")

	EDX["scenesManager"].onSceneInitialized(target) --in scenesManager
end

Dispose = function(sceneId)
	data["sceneId"] = sceneId
	
	EDX[sceneId].dispose()
end

raiseDisposed = function()
	local subObjective = GetSubObjective(data["sceneId"])
	if OFP:getObjectiveState(subObjective) ~= "IN_PROGRESS" then
		OFP:setObjectiveVisibility(subObjective, "true")
	end
	
	EDX["scenesManager"].onSceneDisposed() --in scenesManager
end

raiseTargetEscaped = function() --to scene manager
	EDX["scenesManager"].onTargetEscaped()
end

raiseSpotted = function(sceneId) --to current scene
	EDX[sceneId].onSpotted()
end

GetMainObjective = function(sceneId)
	return EDX[sceneId].getMainObjective()
end

GetSubObjective = function(sceneId)
	return EDX[sceneId].getSubObjective()
end
