local data = {}
data.name = "demo game"
data.initState = "states/title.state.lua"
data.run = function()
  globals.defeats = {}
  globals.defeats.stickMan = false
  megautils.resetGameObjectsFuncs["megaman"] = function()
    megaman.colorOutline = {}
    megaman.colorOne = {}
    megaman.colorTwo = {}
    megaman.weaponHandler = {}
    for i=1, maxPlayerCount do
      megaman.weaponHandler[i] = weaponhandler(nil, nil, 10)
      megaman.weaponHandler[i]:register(0, "megaBuster", {0, 120, 248}, {0, 232, 216}, {0, 0, 0})
      megaman.weaponHandler[i]:register(9, "rushCoil", {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
      megaman.weaponHandler[i]:register(10, "rushJet", {248, 56, 0}, {255, 255, 255}, {0, 0, 0})
      if globals.defeats.stickMan then
        megaman.weaponHandler[i]:register(1, "stickWeapon", {255, 255, 255}, {128, 128, 128}, {0, 0, 0})
      end
      megaman.colorOutline[i] = megaman.weaponHandler[i].colorOutline[0]
      megaman.colorOne[i] = megaman.weaponHandler[i].colorOne[0]
      megaman.colorTwo[i] = megaman.weaponHandler[i].colorTwo[0]
    end
  end
  megautils.resetGameObjects()
  globals.gameOverMenuState = "states/menu.state.lua"
  globals.gameOverMenuMusic = {"assets/menu.ogg"}
  loader.load("assets/stick_weapon.png", "stick_weapon", "texture", nil, true)
end

return data