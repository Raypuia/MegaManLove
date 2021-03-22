input = {}

input._downMT = {__newindex = function(self, k, v)
    rawget(self, "_sv")[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].down then
        return record.loadedRec.data[record.loadedRecPos].down[k]
      end
      
      return
    end
    
    return rawget(self, "_sv")[k]
  end}

input._pressedMT = {__newindex = function(self, k, v)
    rawget(self, "_sv")[k] = v
  end, __index = function(self, k)
    if record and record.demo then
      if record.loadedRec and record.loadedRec.data and
        record.loadedRec.data[record.loadedRecPos] and record.loadedRec.data[record.loadedRecPos].pressed then
        return record.loadedRec.data[record.loadedRecPos].pressed[k]
      end
      
      return
    end
    
    return rawget(self, "_sv")[k]
  end}

function input.init()
  input.keys = {}
  input._pressedTable = {}
  input.gamepads = love.joystick and love.joystick.getJoysticks()
  input.down = {_sv = {}}
  setmetatable(input.down, input._downMT)
  input.pressed = {_sv = {}}
  setmetatable(input.pressed, input._pressedMT)
  input.touchDown = {}
  input.touchPressed = {}
  input.usingTouch = isMobile or (not love.keyboard and (love.mouse or love.touch))
end

function input.refreshGamepads()
  input.gamepads = love.joystick.getJoysticks()
end

function input.bind(v, k)
  input.keys[k] = v
  input.down[k] = false
  input.pressed[k] = false
  input._pressedTable[k] = nil  
end

function input.unbind(k)
  if not k then
    input.keys = {}
    input._pressedTable = {}
    input.down = {_sv = {}}
    setmetatable(input.down, input._downMT)
    input.pressed = {_sv = {}}
    setmetatable(input.pressed, input._pressedMT)
  else
    input.keys[k] = nil
    input._pressedTable[k] = nil
    input.down[k] = nil
    input.pressed[k] = nil
  end
end

function input._down(k)
  if (console and console.state == 1) or not input.keys[k] then
    return false
  end
  local result = false
  for i=1, #input.keys[k] do
    if input.keys[k][i].type == "keyboard" then
      local v = input.keys[k][i].input
      result = love.keyboard.isDown(v) and not pressingHardInputs(v)
    elseif input.keys[k][i].type == "gamepad" then
      for _, v in ipairs(input.gamepads) do
        if input.keys[k][i].name == v:getName() and v:isGamepadDown(input.keys[k][i].input) then
          result = true
          break
        end
      end
    elseif input.keys[k][i].type == "axis" then
      for _, v in ipairs(input.gamepads) do
        if input.keys[k][i].name == v:getName() then
          local input = input.keys[k][i].input
          if input == "leftx+" and v:getGamepadAxis("leftx") > deadZone then
            result = v:getGamepadAxis("leftx")
            break
          elseif input == "leftx-" and v:getGamepadAxis("leftx") < -deadZone then
            result = v:getGamepadAxis("leftx")
            break
          end
          if input == "lefty+" and v:getGamepadAxis("lefty") > deadZone then
            result = v:getGamepadAxis("lefty")
            break
          elseif input == "lefty-" and v:getGamepadAxis("lefty") < -deadZone then
            result = v:getGamepadAxis("lefty")
            break
          end
          if input == "rightx+" and v:getGamepadAxis("rightx") > deadZone then
            result = v:getGamepadAxis("rightx")
            break
          elseif input == "rightx-" and v:getGamepadAxis("rightx") < -deadZone then
            result = v:getGamepadAxis("rightx")
            break
          end
          if input == "righty+" and v:getGamepadAxis("righty") > deadZone then
            result = v:getGamepadAxis("righty")
            break
          elseif input == "righty-" and v:getGamepadAxis("righty") < -deadZone then
            result = v:getGamepadAxis("righty")
            break
          end
          if input == "triggerleft+" and v:getGamepadAxis("triggerleft") > deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          elseif input == "triggerleft-" and v:getGamepadAxis("triggerleft") < -deadZone then
            result = v:getGamepadAxis("triggerleft")
            break
          end
          if input == "triggerright+" and v:getGamepadAxis("triggerright") > deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          elseif input == "triggerright-" and v:getGamepadAxis("triggerright") < -deadZone then
            result = v:getGamepadAxis("triggerright")
            break
          end
        end
      end
    elseif input.keys[k][i].type == "custom" then
      if input.keys[k][i].func then
        result = input.keys[k][i].func()
      end
    end
    if result then break end
  end
  return result
end

function input._pressed(k)
  if console and console.state == 1 then
    return false
  end
  if not input._pressedTable[k] then
    local res = input._down(k)
    if res then
      input._pressedTable[k] = true
      return res
    end
  end
  return false
end

function input.touchDownOverlaps(x, y, w, h)
  for _, v in pairs(input.touchDown) do
    if pointOverlapsRect(v.x, v.y, x, y, w, h) then
      return true
    end
  end
  
  return false
end

function input.touchPressedOverlaps(x, y, w, h)
  for _, v in pairs(input.touchPressed) do
    if pointOverlapsRect(v.x, v.y, x, y, w, h) then
      return true
    end
  end
  
  return false
end

function input.anyDown()
  if console and console.state == 1 then
    return false
  end
  for k, _ in pairs(input.keys) do
    if input._down(k) then
      return true
    end
  end
  return #input.touchDown ~= 0
end

function input.poll()
  for k, _ in pairs(input.keys) do
    input.down[k] = input._down(k)
    input.pressed[k] = input._pressed(k)
  end
  
  if love.touch or love.mouse then
    local newTouches = love.touch and love.touch.getTouches() or {}
    local ids = {}
    
    if love.mouse and love.mouse.isDown(1, 2, 3) then
      newTouches[#newTouches + 1] = "mousetouch"
    end
    
    for _, v in pairs(input.touchDown) do
      if not table.contains(newTouches, v.id) then
        table.removevalue(input.touchDown, v)
      end
    end
    
    for _, v in pairs(input.touchDown) do
      ids[#ids + 1] = v.id
    end
    
    for _, v in pairs(newTouches) do
      if not table.contains(ids, v) then
        if love.mouse and v == "mousetouch" then
          local x, y = cscreen.project(love.mouse.getPosition())
          input.touchDown[#input.touchDown + 1] = {id = v, x = x, y = y, pressure = 1}
          input.touchPressed[#input.touchPressed + 1] = {id = v, x = x, y = y, pressure = 1}
        elseif love.touch then
          local x, y = cscreen.project(love.touch.getPosition(v))
          local p = love.touch.getPressure(v)
          input.touchDown[#input.touchDown + 1] = {id = v, x = x, y = y, pressure = p}
          input.touchPressed[#input.touchPressed + 1] = {id = v, x = x, y = y, pressure = p}
        end
      end
    end
  end
end

function input.flush()
  for k, _ in pairs(input._pressedTable) do
    if not input._down(k) then
      input._pressedTable[k] = nil
    end
  end
  
  input.touchPressed = {}
end

input._dTimer = 0

function input.draw()
  if input._checkD == nil then
    input._checkD = input.usingTouch
  end
  if input._checkD ~= input.usingTouch then
    input._dTimer = 100
    input._checkD = input.usingTouch
  end
  if input._dTimer > 0 then
    input._dTimer = math.max(input._dTimer - 1, 0)
    local na = (input._dTimer % 8 < 5) and 1 or 0.5
    local r, g, b, a = love.graphics.getColor()
    
    if input.usingTouch then
      love.graphics.setColor(0, 0, 0, na)
      love.graphics.rectangle("fill", 0, 0, 8*22, 32)
      love.graphics.setColor(1, 1, 1, na)
      love.graphics.rectangle("line", 0, 0, 8*22, 32)
    else
      love.graphics.setColor(0, 0, 0, na)
      love.graphics.rectangle("fill", 0, 0, 8*24, 32)
      love.graphics.setColor(1, 1, 1, na)
      love.graphics.rectangle("line", 0, 0, 8*24, 32)
    end
    love.graphics.print(input.usingTouch and "TOUCH MODE ACTIVATED" or "TOUCH MODE DEACTIVATED", 8, 8)
    love.graphics.setColor(r, g, b, a)
  end
end