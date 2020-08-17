states = {}

states.currentState = nil
states.current = nil
states.switched = false
states.recordOnSwitch = false
states.openRecord = nil
states.queue = nil

baseState = class:extend()

function baseState:begin() end
function baseState:update(dt) end
function baseState:draw() end
function baseState:switching() end
function baseState:unload() end
function baseState:init() end

state = baseState:extend()

function state:update(dt)
  megautils.update(self, dt)
end
function state:draw()
  self.system:draw()
end
function state:unload()
  megautils.unload()
end

function states.set(n, before, after)
  if before then before() end
  
  local nick = n
  local isStage = nick and (nick:sub(-10) == ".stage.lua" or nick:sub(-10) == ".stage.tmx")
  local map
  local mapArgs = {}
  local sp = "assets/states/blank.lua"
  
  if nick then
    if nick:sub(-10) == ".state.tmx" or nick:sub(-10) == ".stage.tmx" then
      map = megautils.createMapEntity(nick)
      local p = map.map.properties
      
      if p then
        local otherp = nick:sub(0, -11)
        if p.state and p.state ~= "" then
          sp = p.state
        elseif love.filesystem.getInfo(otherp .. ".lua") then
          sp = otherp .. ".lua"
        end
        
        mapArgs.mPath = p.musicPath and p.musicPath ~= "" and p.musicPath
        mapArgs.mLoopPoint = (p.musicLoopPoint and p.musicLoopPoint ~= 0) and p.musicLoopPoint
        mapArgs.mLoopEndPoint = (p.musicLoopEndPoint and p.musicLoopEndPoint ~= 0) and p.musicLoopEndPoint
        mapArgs.mLoop = p.musicLoop == nil or p.musicLoop
        mapArgs.mVolume = p.musicVolume or 1
        
        mapArgs.fadeIn = p.fadeIn == nil or p.fadeIn
      end
    else
      sp = nick
    end
  end
  
  if states.currentState then
    states.currentState:switching()
    if megautils.reloadState and megautils.resetGameObjects then
      states.currentState:unload()
    end
  end
  
  if states.openRecord then
    control.resetRec()
    control.record = save.load(states.openRecord)
    nick = control.record.state
    states.openRecord = nil
    control.oldGlobals = globals
    globals = control.record.globals
    control.oldConvars = convar
    convar.setAllValues(control.record.convars)
    love.math.setRandomSeed(control.record.seed)
    megautils.reloadState = control.record.reload
    megautils.resetGameObjects = control.record.rgo
    control.oldSkins = {}
    for k, v in pairs(megaMan.skins) do
      control.oldSkins[k] = v.path
    end
    for k, v in pairs(control.record.skins) do
      megaMan.setSkin(k, v)
    end
    control.oldConsole = console.ser()
    console.deser(control.record.console)
    lastPressed = nil
    lastTextInput = nil
    lastTouch = nil
    keyboardCheck = {}
    gamepadCheck = {}
    megautils._q = {}
    control.demo = true
    states.set(nick, before, after)
    return
  end
  
  if states.recordOnSwitch then
    lastPressed = nil
    lastTextInput = nil
    lastTouch = nil
    keyboardCheck = {}
    gamepadCheck = {}
    megautils._q = {}
    states.recordOnSwitch = false
    control.updateDemoFunc = nil
    control.drawDemoFunc = nil
    control.resetRec()
    control.recordInput = true
    control.record.globals = table.clone(globals)
    control.record.convars = convar.getAllValues()
    control.record.state = sp
    control.record.seed = love.math.getRandomSeed()
    control.record.reload = megautils.reloadState
    control.record.rgo = megautils.resetGameObjects
    control.record.skins = {}
    for k, v in pairs(megaMan.skins) do
      control.record.skins[k] = v.path
    end
    control.record.console = console.ser()
  end
  
  if megautils.reloadState then
    for k, v in pairs(megautils.reloadStateFuncs) do
      if type(v) == "function" then
        v()
      else
        v.func()
      end
    end
  end
  
  if not states.currentChunk or states.current ~= sp then
    states.currentChunk = love.filesystem.load(sp)
  end
  
  view.x, view.y = 0, 0
  
  states.current = nick
  states.currentState = states.currentChunk()
  states.currentState.system = entitySystem()
  states.switched = true
  
  if after then after() end
  
  if megautils.reloadState and megautils.resetGameObjects then
    if isStage then
      for k, v in pairs(megautils.resetGameObjectsFuncs) do
        if type(v) == "function" then
          v()
        else
          v.func()
        end
      end
    end
    states.currentState:init()
  end
  
  if map then
    states.currentState.system:adde(map):addObjects()
    
    if mapArgs.fadeIn then
      states.currentState.system:add(fade, false):setAfter(fade.remove)
    end
    
    if mapArgs.mPath then
      megautils.playMusic(mapArgs.mPath, mapArgs.mLoop, mapArgs.mLoopPoint, mapArgs.mLoopEndPoint, mapArgs.mVolume)
    end
  end
  
  states.currentState:begin()
end

function states.setq(n, before, after)
  states.queue = {n, before, after}
end

function states.checkQueue()
  if states.queue then
    states.set(states.queue[1], states.queue[2], states.queue[3])
    states.queue = nil
  end
end

function states.update(dt)
  if not states.currentState then return end
  states.currentState:update(dt)
end

function states.draw()
  if not states.currentState then return end
  states.currentState:draw()
end
