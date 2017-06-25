SCRIPT_NAME = "patrolSystem"

--[[
	usage:
	EDX["patrolSystem"].registerHoldTime("waypoint", 0)
	EDX["patrolSystem"].patrol("echelonOrGroup", "pathName", 0(circle) or 1(backendfront))
--]]

onEDXInitialized = function()
	--OFP:showPopup(SCRIPT_NAME, "initialized")
	
	scripts.mission.waypoints.registerFunction("registerHoldTime")
	scripts.mission.waypoints.registerFunction("patrol")
	
	--OFP:showPopup("EDX.dataManager", tostring(EDX["dataManager"]))
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	--OFP:showPopup("data")
	if EDX["dataManager"].IsFirstRun() == true then
		--OFP:showPopup("IsFirstRun")
		data["holdTimes"] = {}
	else
		--OFP:showPopup("IsNotFirstRun")
	end
end

registerHoldTime = function(waypoint, interval)
	data["holdTimes"][waypoint] = interval
end

patrol = function(echelonOrGroup, pathName, pathTypeEnum)
	local _pathType
	if pathTypeEnum == 0 then
		_pathType = "ECYCLIC"
	elseif pathTypeEnum == 1 then
		_pathType = "EBACKANDFORTH"
	else
		_pathType ="ESINGLE"
	end
	OFP:patrol(echelonOrGroup, pathName, _pathType, string.sub(pathName, 1, -2), "ADDTOFRONT")
end

function onArriveAtWaypoint(entity, waypoint)
	if data["holdTimes"][waypoint] then
		local echelon = OFP:getParentEchelon(entity)
		local interval = data["holdTimes"][waypoint]
		--OFP:displaySystemMessage("stopForTime: "..echelon.." - "..interval)
		OFP:stopForTime(echelon, interval, "ADDTOFRONT")
	end
end
