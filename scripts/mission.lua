SCRIPT_NAME = "mission"

--[[
load next scene with parameter determin whether dispose scene when scene's end attached:
	[disposeWhenEnd] true: dispose scene when end		false: keep scene when end
	EDX["scenesManager"].LoadNextScene(disposeWhenEnd)
set stop point in path and time:
	EDX["patrolSystem"].registerHoldTime("waypointName", holdTime)
patrol:
	[patrolType] 0: circle		1: forwardback		other:once
	EDX["patrolSystem"].patrol("echelonOrGroupName", "pathName", patrolType)
]]
		  
		  
function onEDXInitialized()
	--OFP:showPopup(SCRIPT_NAME, "initialized")
	
	scripts.mission.waypoints.registerFunction("onIdle")
	scripts.mission.waypoints.registerFunction("onCompleted")

	--OFP:showPopup("EDX.dataManager", tostring(EDX["dataManager"]))
	data = EDX["dataManager"].GetOrCreate(SCRIPT_NAME)
	if EDX["dataManager"].IsFirstRun() == true then
		EDX:registerPlayer("iu36plsfrfl") --type main player name here
		EDX:registerPlayable("", false)
		
		EDX["scenesManager"].RegisterScenes({ --type scene Id list here
			
		})
	end
	
	OFP:blockCommandAndReportFeedback(true)
end

function onMissionStart()
	EDX:setTimeOfDay(01, 00, 00)
	--EDX:setRandomTime()
	EDX:setWeatherCurrent(4)
	EDX:setFogCurrent(36)
	--EDX:setRandomWeather()
	--EDX:randomizeWeather(30)
	
	if not scripts.mission.level or not scripts.mission.level.REGISTERED then
		OFP:showPopup("\232\132\154\230\156\172\230\149\176\230\141\174\233\148\153\232\175\175", "\232\175\183\233\135\141\230\150\176\228\184\139\232\189\189\228\187\187\229\138\161")
		OFP:missionCompleted()
	end
end

----------------------ScenesManager callback start--------------------

function onIdle(nextSceneId)
	if nextSceneId == "" then
		
	end
end

function onCompleted(missionFinishedCount)
	if missionFinishedCount < 1 then
		OFP:missionFailed()
	else
		EDX:simpleTimer("onMissionCompleted", 3600)
	end
end

----------------------ScenesManager callback end----------------------

---------------------------------------------------------------------

function onMissionCompleted(timerId)
	OFP:missionCompleted()
end

---------------------------------------------------------------------

