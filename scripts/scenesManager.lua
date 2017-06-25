SCRIPT_NAME="scenesManager"

onEDXInitialized = function()
	--OFP:showPopup(SCRIPT_NAME, "initialized")
	
	scripts.mission.waypoints.registerFunction("RegisterScenes")
	scripts.mission.waypoints.registerFunction("onSceneInitialized")
	scripts.mission.waypoints.registerFunction("onSceneDisposed")
	scripts.mission.waypoints.registerFunction("onTargetEscaped")
	scripts.mission.waypoints.registerFunction("LoadNextScene")
	scripts.mission.waypoints.registerFunction("GetTarget")
	
	--OFP:showPopup("EDX.dataManager", tostring(EDX["dataManager"]))
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	if EDX["dataManager"].IsFirstRun() == true then
		--OFP:displaySystemMessage("onEDXInitialized start")
		
		data["isCheckingEnabled"] = false
		data["target"] = ""
		data["suspectedCount"] = 0
		
		data["scenes"] = {}
		data["maxScenesCount"] = 3
		data["currentSceneIndex"] = 0 --base on 1
		data["currentSceneId"] = ""
		
		data["mainMissionFinished"] = false
		data["subMissionFailed"] = false
		data["allPlayersDead"] = false
		
		data["missionFinishedCount"] = 0
		
		data["disposeWhenEnd"] = true
		
		data["attacker"] = ""
		
		--OFP:displaySystemMessage("onEDXInitialized end")
	end
end

onMissionStart = function()
	--OFP:displaySystemMessage("onMissionStart")
	
	data["attacker"] = EDX:getPrimaryPlayer()
	
	moveToNextScene()
end

registerScene = function(sceneId)
	table.insert(data["scenes"], sceneId)
end

RegisterScenes = function(sceneIdList)
	local i = 0
	for _, v in pairs(sceneIdList) do
		if data["maxScenesCount"] <= i then
			break
		end
		registerScene(v)
		i = i + 1
	end
end

moveToNextScene = function()
	--OFP:displaySystemMessage("moveToNextScene")
	
	local currentSceneIndex = data["currentSceneIndex"] + 1
	if currentSceneIndex <= #data["scenes"] then
		data["currentSceneIndex"] = currentSceneIndex
		local sceneId = data["scenes"][currentSceneIndex]
		
		data["currentSceneId"] = sceneId
		
		EDX["mission"].onIdle(sceneId)
	else
		EDX["mission"].onCompleted(data["missionFinishedCount"])
	end
end

LoadNextScene = function(disposeWhenEnd)
	data["disposeWhenEnd"] = disposeWhenEnd
	initializeScene(data["currentSceneId"])
end

initializeScene = function(sceneId)
	OFP:allowPlayerFire(false)
	OFP:allowPlayerMovement(false)
	OFP:showLetterBoxOsd(true)
	
	EDX["sceneBase"].Initialize(sceneId)
end

onSceneInitialized = function(target)
	--OFP:displaySystemMessage("onSceneInitialized")
	
	data["target"] = string.lower(target)
	data["isCheckingEnabled"] = true
	
	OFP:allowPlayerFire(true)
	OFP:allowPlayerMovement(true)
	OFP:showLetterBoxOsd(false)
end

disposeScene = function(sceneIndex)
	--OFP:displaySystemMessage("endCurrentScene : "..sceneIndex)
	local sceneId = data["scenes"][sceneIndex]
	
	local mainObjective = EDX["sceneBase"].GetMainObjective(sceneId)
	if data["mainMissionFinished"] == true then
		if OFP:getObjectiveState(mainObjective) ~= "COMPLETED" then
			OFP:setObjectiveState(mainObjective, "COMPLETED")
		end
		data["missionFinishedCount"] = data["missionFinishedCount"] + 1
	else
		OFP:setObjectiveState(mainObjective, "FAILED")
	end
	
	local subObjective =EDX["sceneBase"].GetSubObjective(sceneId)
	if data["mainMissionFinished"] == true then
		if OFP:getObjectiveState(subObjective) ~= "FAILED" then
			OFP:setObjectiveState(subObjective, "COMPLETED")
			OFP:setObjectiveVisibility(subObjective, "true")
		end
	end
	
	OFP:allowPlayerFire(false)
	OFP:allowPlayerMovement(false)
	
	if data["disposeWhenEnd"] == true then
		EDX["sceneBase"].Dispose(sceneId)
	else
		onSceneDisposed()
	end
end

onSceneDisposed = function()
	--OFP:displaySystemMessage("onSceneDisposed")
	
	if data["allPlayersDead"]==true then
		OFP:missionFailedKIA()
	else
		data["isCheckingEnabled"] = false
		data["target"] = null
		data["suspectedCount"] = 0
		data["mainMissionFinished"] = false
		data["subMissionFailed"] = false
		
		OFP:allowPlayerFire(true)
		OFP:allowPlayerMovement(true)
		OFP:showLetterBoxOsd(false)
		
		moveToNextScene()
	end
end

onTargetEliminated = function(target)
	--OFP:displaySystemMessage("onTargetEliminated")
	
	data["mainMissionFinished"] = true
	--when target is prone, changing camera to target may trigger a fatal exception
	if OFP:getStance(target) == "EProne" then
		endCurrentScene()
	elseif OFP:getDistance(EDX:getPrimaryPlayer(), target) < 100 then
		endCurrentScene()
	else
		EDX:simpleTimer("cameraToTarget", 100)
	end
end

cameraToTarget = function(timerId)
	EDX:deleteTimer("cameraToTarget")
	
	OFP:showLetterBoxOsd(true)
	OFP:selectCamera(data["target"])
	
	--OFP:displaySystemMessage("just watching...");
	
	EDX:simpleTimer("cameraToPlayer", 1600)
end

cameraToPlayer = function(timerId)
	EDX:deleteTimer("cameraToPlayer")
	
	OFP:selectCamera(data["attacker"])
	endCurrentScene()
end

endCurrentScene = function()
	--OFP:displaySystemMessage("endCurrentScene")
	--[
	OFP:displaySystemMessage(" ")
	OFP:displaySystemMessage(" ")
	OFP:displaySystemMessage(" ")
	OFP:displaySystemMessage(" ")
	OFP:displaySystemMessage(" ")
	--]]
	
	disposeScene(data["currentSceneIndex"])
end

onSubMissionFailed = function()
	local currentSceneIndex = data["currentSceneIndex"]
	local sceneId = data["scenes"][currentSceneIndex]
	
	local subObjective = EDX["sceneBase"].GetSubObjective(sceneId)
	OFP:setObjectiveState(subObjective, "FAILED")
	OFP:setObjectiveVisibility(subObjective, "true")
	
	EDX["sceneBase"].raiseSpotted(sceneId)
end

onTargetEscaped = function()
	--OFP:displaySystemMessage("onTargetEscaped")
	
	data["mainMissionFinished"] = false
	endCurrentScene()
end

GetTarget = function()
	return data["target"]
end

-------------------Origin Events Start-------------------
onSuspected = function(victim, suspector)
	--OFP:displaySystemMessage("onSuspected - "..victim)
	
	if data["isCheckingEnabled"] == true and data["subMissionFailed"] == false then
		if victim == data["attacker"] then
			data["suspectedCount"] = data["suspectedCount"] + 1
			
			--when player has been suspected, suspector will raise doctrine up
			if data["suspectedCount"] >= 6 then
				local echelon = OFP:getParentEchelon(suspector)
				OFP:setDoctrine(echelon, "ECombat", "addtofront")
			elseif data["suspectedCount"] >= 2 then
				local echelon = OFP:getParentEchelon(suspector)
				OFP:setDoctrine(echelon, "EAware", "addtofront")
			end
			
			--OFP:displaySystemMessage("Ya have been suspected "..data["suspectedCount"].." times, Be careful!")
			OFP:displaySystemMessage("\230\149\140\230\150\185\232\173\166\232\167\137\230\172\161\230\149\176\239\188\154 "..data["suspectedCount"])
		end
	end
end

onIdentified = function(victim, identifier)
	--OFP:displaySystemMessage("onIdentified - "..victim)
	
	if data["isCheckingEnabled"] == true and data["subMissionFailed"] == false then
		if victim == data["attacker"] then
			--OFP:displaySystemMessage("Ya have been identified!")
			OFP:displaySystemMessage("\228\189\160\229\183\178\231\187\143\230\154\180\233\156\178\228\186\134\239\188\129")
			
			data["subMissionFailed"] = true
			
			local x,y,z = OFP:getPosition(identifier)
			OFP:playOneShotSound("flashpoint2", "Placeable", "SPC3_Alarm", x, y, z, 100, 36, 0)
			
			onSubMissionFailed()
		end
	end
end

onDeath = function(victim)
	--OFP:displaySystemMessage("onDeath - "..victim)
	
	if string.lower(victim) == data["target"] then
		onTargetEliminated(victim)
	end
end

onMount = function(vehicleName, unitName)
	if unitName == data["attacker"] then
		data["attacker"] = vehicleName
		--OFP:displaySystemMessage(data["attacker"])
	end
end

onDismount = function(vehicleName, unitName)
	if vehicleName == data["attacker"] then
		data["attacker"] = unitName
		--OFP:displaySystemMessage(data["attacker"])
	end
end

onAllPlayersDead = function()
	--OFP:displaySystemMessage("onAllPlayersDead")
	
	data["allPlayersDead"] = true
	endCurrentScene()
end

--[[
onUnderfire = function(underfireID, shooterID, method)
	OFP:displaySystemMessage("size: "..OFP:getSide(underfireID))
	if shooterID == data["attacker"] then
		local echelon = OFP:getParentEchelon(underfireID)
		if echelon then
			OFP:assault(echelon, data["attacker"], "addtofront")
		else
			OFP:assault(underfireID, data["attacker"], "addtofront")
		end
	end
end
--]]
--------------------Origin Events End-------------------