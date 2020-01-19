met = entity:extend()

addobjects.register("met", function(v)
  megautils.add(spawner, v.x, v.y+2, 14, 14, function(s)
      megautils.add(met, s.transform.x, s.transform.y, s)
    end)
end)

function met:new(x, y, s)
  met.super.new(self)
  self.added = function(self)
    self:addToGroup("hurtable")
    self:addToGroup("removeOnTransition")
    self:addToGroup("freezable")
  end
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(14, 14)
  self.t = loader.get("demo_objects")
  self.spawner = s
  self.c = "safe"
  self.quads = {}
  self.quads["safe"] = love.graphics.newQuad(32, 0, 18, 15, 100, 100)
  self.quads["up"] = love.graphics.newQuad(50, 0, 18, 15, 100, 100)
  self.side = -1
  self.s = 0
  self.health = 2
  self.canBeInvincible["global"] = true
  self.timer = 0
  self.blockCollision = true
end

function met:grav()
  self.velocity.vely = math.clamp(self.velocity.vely+self.gravity, -7, 7)
end

function met:healthChanged(o, c, i)
  if o.dinked == 1 then return end
  if c < 0 and not self:checkTrue(self.canBeInvincible) and not o:is(megaChargedBuster) then
    megautils.remove(o, true)
  end
  if self.maxIFrame ~= self.iFrame then return end
  if self:checkTrue(self.canBeInvincible) and o.dink then
    o:dink(self)
    return
  end
  self.changeHealth = c
  self.health = self.health + self.changeHealth
  self.maxIFrame = i
  self.iFrame = 0
  if self.health <= 0 then
    megautils.add(smallBlast, self.transform.x-4, self.transform.y-4)
    megautils.dropItem(self.transform.x, self.transform.y-4)
    megautils.remove(self, true)
    mmSfx.play("enemy_explode")
  elseif self.changeHealth < 0 then
    if o:is(megaChargedBuster) then
      megautils.remove(o, true)
    end
    mmSfx.play("enemy_hit")
  end
end

function met:update(dt)
  local near = megautils.autoFace(self, globals.allPlayers)
  if self.s == 0 then
    if near and math.between(near.transform.x, 
      self.transform.x - 120, self.transform.x + 120) then
      self.timer = math.min(self.timer+1, 80)
    else
      self.timer = 0
    end
    if self.timer == 80 then
      self.timer = 0
      self.s = 1
      self.canBeInvincible["global"] = false
      self.c = "up"
    end
  elseif self.s == 1 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.timer = 0
      self.s = 2
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, -megautils.calcY(45)*2)
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*megautils.calcX(45)*2, megautils.calcY(45)*2)
      megautils.add(metBullet, self.transform.x+4, self.transform.y+4, self.side*2, 0)
      mmSfx.play("buster")
    end
  elseif self.s == 2 then
    self.timer = math.min(self.timer+1, 20)
    if self.timer == 20 then
      self.c = "safe"
      self.canBeInvincible["global"] = true
      self.timer = 0
      self.s = 0
    end
  end
  collision.doCollision(self)
  self:hurt(self:collisionTable(globals.allPlayers), -2, 80)
  self:updateIFrame()
  self:updateFlash()
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function met:draw()
  love.graphics.setColor(1, 1, 1, 1)
  if self.side == -1 then
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x-2, self.transform.y)
  else
    love.graphics.draw(self.t, self.quads[self.c], self.transform.x+16, self.transform.y, 0, -1, 1)
  end
  --self:drawCollision()
end

function met:removed()
  if self.spawner then
    self.spawner.canSpawn = true
  end
end

metBullet = basicEntity:extend()

function metBullet:new(x, y, vx, vy)
  metBullet.super.new(self)
  self.added = function(self)
    self:addToGroup("freezable")
    self:addToGroup("removeOnTransition")
    self:addToGroup("enemyWeapon")
  end
  self.transform.x = x
  self.transform.y = y
  self:setRectangleCollision(6, 6)
  self.tex = loader.get("demo_objects")
  self.quad = love.graphics.newQuad(68, 0, 6, 6, 100, 100)
  self.velocity = velocity()
  self.velocity.velx = vx
  self.velocity.vely = vy
end

function metBullet:recycle(x, y, vx, vy)
  self.transform.x = x
  self.transform.y = y
  self.velocity.velx = vx
  self.velocity.vely = vy
  self.dinked = nil
end

function metBullet:dink(e)
  if e:is(megaman) then
    self.velocity.velx = -self.velocity.velx
    self.velocity.vely = -self.velocity.vely
    self.dinked = 2
    mmSfx.play("dink")
  end
end

function metBullet:update(dt)
  self.transform.x = self.transform.x + self.velocity.velx
  self.transform.y = self.transform.y + self.velocity.vely
  if self.dinked then
    self:hurt(self:collisionTable(megautils.groups()["hurtable"]), -1, 2)
  else
    self:hurt(self:collisionTable(globals.allPlayers), -2, 80)
  end
  if megautils.outside(self) then
    megautils.remove(self, true)
  end
end

function metBullet:draw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(self.tex, self.quad, math.round(self.transform.x), math.round(self.transform.y))
end

megautils.cleanFuncs["unload_met"] = function()
  met = nil
  metBullet = nil
  addobjects.unregister("met")
  megautils.cleanFuncs["unload_met"] = nil
end
