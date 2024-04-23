-- upsidedown 2024
-- home of code is https://github.com/upsidedownLS13
-- works with Telemetry mod and telemetry server application

Telemetry_Addon = {};
Telemetry_Addon.modDirectory = g_currentModDirectory;
local modDesc = loadXMLFile("modDesc", g_currentModDirectory .. "modDesc.xml");
Telemetry_Addon.modversion = getXMLString(modDesc, "modDesc.version");
Telemetry_Addon.author = getXMLString(modDesc, "modDesc.author");


local modversion = Telemetry_Addon.modversion; -- moddesc

function Telemetry_Addon.prerequisitesPresent(specializations) 
    return true
end 


function Telemetry_Addon:onUpdate(dt, isActiveForInput, isActiveForInputIgnoreSelection, isSelected)
	if isActiveForInputIgnoreSelection or self.rootVehicle == g_currentMission.controlledVehicle then
		Telemetry_Addon.updateAttachedObject(self,0)
	end
end -- onUpdate

function Telemetry_Addon.updateAttachedObject(object,depth)
	if object ~= nil then
		Telemetry_Addon.updateObject(object)
		
		-- if your mod only applies to the main (Drivable) vehicle, you are done here. just close the if-statement and the function and you are good.
		-- The remaining code in this function applies a recursive search over all the implements. Depends on what you want to do with your addon if this is needed (or even meaningful) or not.
		local attachedImplements = object:getAttachedImplements();
		if attachedImplements == nil then		
			return;
		end
		
		for _, implement in pairs(attachedImplements) do
			local objectA = implement.object
			if objectA ~= nil and objectA.schemaOverlay ~= nil then
				if 10 > depth then --make 10 parameter again..
					Telemetry_Addon.updateAttachedObject(objectA,depth+1)
				end			
			end
		end
	end
end
Drivable.onUpdate  = Utils.prependedFunction(Drivable.onUpdate, Telemetry_Addon.onUpdate);


--to make new addons for the Telemetry Mod you only need to make a new updateObject function like this:
function Telemetry_Addon.updateObject(object)
		local spec = object.spec_fillUnit
		local fillLevel = 0
		local capacity = 0
		local maxMassReached = false
		
		if spec ~= nil then
			for i = 1, #spec.fillUnits do
				local fillUnit = spec.fillUnits[i]

				if fillUnit.capacity > 0 and fillUnit.showOnHud then
					fillLevel = fillUnit.fillLevel
					if fillUnit.fillLevelToDisplay ~= nil then
						fillLevel = fillUnit.fillLevelToDisplay
					end

					capacity = fillUnit.capacity
					if fillUnit.parentUnitOnHud ~= nil then
						capacity = 0
					end
					if object.getMaxComponentMassReached ~= nil then
						maxMassReached = object:getMaxComponentMassReached()
					end
				end
			end
		else
			fillLevel = -1
			capacity = -1
			maxMassReached = false
		end

		if object.FStelemetryAddonData == nil then
			object.FStelemetryAddonData = {}
		end
		
		object.FStelemetryAddonData.fillLevel = fillLevel;
		object.FStelemetryAddonData.fillLevelCapacity = capacity;
		object.FStelemetryAddonData.maxMassReached = maxMassReached;
end