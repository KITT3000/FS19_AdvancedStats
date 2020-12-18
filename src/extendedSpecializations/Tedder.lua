--
-- ${title}
--
-- @author ${author}
-- @version ${version}
-- @date 14/11/2020

ExtendedTedder = {}
ExtendedTedder.MOD_NAME = g_currentModName
ExtendedTedder.SPEC_TABLE_NAME = string.format("spec_%s.extendedTedder", ExtendedTedder.MOD_NAME)

function ExtendedTedder.prerequisitesPresent(specializations)
    return SpecializationUtil.hasSpecialization(AdvancedStats, specializations)
end

function ExtendedTedder.registerEventListeners(vehicleType)
    SpecializationUtil.registerEventListener(vehicleType, "onLoadStats", ExtendedTedder)
end

function ExtendedTedder.registerOverwrittenFunctions(vehicleType)
    SpecializationUtil.registerOverwrittenFunction(vehicleType, "processTedderArea", ExtendedTedder.processTedderArea)
end

function ExtendedTedder:onLoadStats()
    local spec = self[ExtendedTedder.SPEC_TABLE_NAME]

    spec.hasAdvancedStats = true
    spec.advancedStatisticsPrefix = "Tedder"

    spec.advancedStatistics =
        self:registerStats(
        spec.advancedStatisticsPrefix,
        {
            {"WorkedLitres", AdvancedStats.UNITS.LITRE, true},
            {"WorkedHectares", AdvancedStats.UNITS.HECTARE}
        }
    )
end

function ExtendedTedder:processTedderArea(superFunc, ...)
    local realArea = superFunc(self, ...)
    if self.isServer and realArea > 0 then
        local spec = self[ExtendedTedder.SPEC_TABLE_NAME]
        local ha = MathUtil.areaToHa(realArea, g_currentMission:getFruitPixelsToSqm()) -- 4096px are mapped to 2048m
        self:updateStat(spec.advancedStatistics["WorkedHectares"], ha)
        self:updateStat(spec.advancedStatistics["WorkedLitres"], self.spec_tedder.lastDroppedLiters)
    end
    return realArea, realArea
end
