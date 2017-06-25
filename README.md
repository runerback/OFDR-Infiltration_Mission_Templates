# OFDR-Infiltration_Mission_Templates
Markers Collection and Scripts used in OFDR Mission Editor

In OFDR callback functions, there are `onSuspected(victim, suspector)` and `onIdentified(identifiedID, identifierID)`among them. So I made this template base on these two functions. When player has been Suspected by enemy force, they will raise their doctrine level up (`setDoctrine`), which means player will be identified with more probability. If player has been Identified, the target will try to escape and player will got slim chance to completed the mission (you need to implement this in your mission).

This templates are consisted with two parts: one called `TemplateManager` which contains many scripts, another is `Template` which contains single script and I call it `Scene Template`. The implementation is so weird that I don't know how to descripte them (just lazy)...

waypoints.lua is supported by EDX, and I modified a little:
  in function `registerFunction(funcName)`
    origin codes:
    <code><pre>scripts.mission.waypoints.EDX[funcName] = v[funcName]</pre></code>
    modified:
    <code><pre>if v.SCRIPT_NAME then
    &nbsp;&nbsp;if not scripts.mission.waypoints.EDX[v.SCRIPT_NAME] then
    &nbsp;&nbsp;&nbsp;&nbsp;scripts.mission.waypoints.EDX[v.SCRIPT_NAME] = {}
    &nbsp;&nbsp;end
    &nbsp;&nbsp;scripts.mission.waypoints.EDX[v.SCRIPT_NAME][funcName] = v[funcName]
    else
    &nbsp;&nbsp;scripts.mission.waypoints.EDX[funcName] = v[funcName]
    end</pre></code>
    
The scripts communicate with each other depend on this modification.

Templates are stored in xml file called `markerscollection` which can be import/export by MissionEditor. markerscollection contains lua scripts and informations of marker such as position, entityset, etc. I will put lua scripts into a independent folder `scripts`, and markerscollection files in root folder.
