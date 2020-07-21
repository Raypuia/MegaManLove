spawner = entity:extend()

function spawner:new(x, y, w, h, cond, ...)
  spawner.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.stuff = {...}
  self.wasOutside = true
  self.instance = nil
  self.cond = cond
end

function spawner:added()
  self:addToGroup("handledBySections")
  self:addToGroup("freezable")
  self.instance = nil
end

function spawner:update()
  if megautils.outside(self) and (not self.instance or self.instance.isRemoved) then
    self.instance = nil
    self.wasOutside = true
  end
  if not megautils.outside(self) and self.wasOutside and not self.instance and (not self.cond or self.cond(self)) then
    self.instance = megautils.add(unpack(self.stuff))
    self.wasOutside = false
  end
end

intervalSpawner = entity:extend()

function intervalSpawner:new(x, y, w, h, time, cond, ...)
  intervalSpawner.super.new(self)
  self.transform.y = y
  self.transform.x = x
  self:setRectangleCollision(w, h)
  self.stuff = {...}
  self.cond = cond
  self.time = time
  self.timer = 0
end

function intervalSpawner:added()
  self:addToGroup("handledBySections")
  self:addToGroup("freezable")
end

function intervalSpawner:update(dt)
  if not megautils.outside(self) then
    self.timer = math.min(self.timer+1, self.time)
    if self.timer == self.time then
      self.timer = 0
      if not self.cond or self.cond(self) then
        megautils.add(unpack(self.stuff))
      end
    end
  else
    self.timer = 0
  end
end