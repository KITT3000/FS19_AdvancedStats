--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 04/11/2020

ExtendedRoller = {}
ExtendedRoller.MOD_NAME = g_currentModName
ExtendedRoller.SPEC_TABLE_NAME = string.format("spec_%s.extendedRoller", ExtendedRoller.MOD_NAME)

function ExtendedRoller.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(AdvancedStats, specializations)
end

function ExtendedRoller.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoadStats", ExtendedRoller)
end

function ExtendedRoller.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "processRollerArea", ExtendedRoller.processRollerArea)
end

function ExtendedRoller:onLoadStats()
    local spec = self[ExtendedRoller.SPEC_TABLE_NAME]

    spec.hasAdvancedStats = true
    spec.advancedStatisticsPrefix = "Roller"

    spec.advancedStatistics =
        self:registerStats(
        spec.advancedStatisticsPrefix,
        {
            {"RolledHectares", AdvancedStats.UNITS.HECTARE}
        }
    )
end

function ExtendedRoller:processRollerArea(superFunc, ...)
    local realArea = superFunc(self, ...)
    if self.isServer and realArea > 0 then
        local spec = self[ExtendedRoller.SPEC_TABLE_NAME]
        local ha = MathUtil.areaToHa(realArea, g_currentMission:getFruitPixelsToSqm()) -- 4096px are mapped to 2048m
        self:updateStat(spec.advancedStatistics["RolledHectares"], ha)
    end
    return realArea, realArea
end
