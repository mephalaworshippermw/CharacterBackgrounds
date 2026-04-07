local self = require("openmw.self")

return {
    id = "blacksmith",
    name = "Apprenticed to a Blacksmith",
    description = (
        "Your master was a hard man. You gain a bonus to Strength (+5) " ..
        "and a bonus to your Armorer skill (+15), but you suffer a penalty " ..
        "to Agility (-10) due to the strenuous and repetitive hard labor.\n" ..
        "\n" ..
        "+5 Strength\n" ..
        "+15 Armorer\n" ..
        "-10 Agility"
    ),
    doOnce = function()
        local armorer = self.type.stats.skills.armorer(self)
        armorer.base = armorer.base + 15

        local strength = self.type.stats.attributes.strength(self)
        strength.base = strength.base + 5

        local agility = self.type.stats.attributes.agility(self)
        agility.base = agility.base - 10
    end,
}