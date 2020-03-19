local bossIntroState = states.state:extend()

function bossIntroState:begin()
  megautils.loadResource("assets/misc/title.png", "title")
  megautils.runFile("entities/misc/starfield.lua")
  megautils.add(banner)
  megautils.add(smallStar, 32, 32, 180, 2)
  megautils.add(smallStar, 112, 200, 180, 2)
  megautils.add(smallStar, 16, 240, 180, 2)
  megautils.add(smallStar, 64, 96, 180, 2)
  megautils.add(smallStar, 220, 112, 180, 2)
  megautils.add(star, 10, 100, 180, 4)
  megautils.add(star, 50, 210, 180, 4)
  megautils.add(star, 140, 32, 180, 4)
  megautils.add(largeStar, 0, 32, 180, 6)
  megautils.add(largeStar, 90, 220, 180, 6)
  if globals.bossIntroBoss == "stick" then
    megautils.runFile("entities/demo/stickman.lua")
    megautils.add(stickManIntro)
  end
  megautils.add(fade, false, nil, nil, fade.remove)
  megautils.playMusic(nil, "assets/sfx/music/stageStart.ogg")
end

function bossIntroState:update(dt)
  megautils.update(self, dt)
end

function bossIntroState:stop()
  megautils.unload()
end

function bossIntroState:draw()
  megautils.draw(self)
end

megautils.cleanFuncs.bossIntro = function()
  globals.bossIntroBoss = nil
  megautils.cleanFuncs.bossIntro = nil
end

return bossIntroState