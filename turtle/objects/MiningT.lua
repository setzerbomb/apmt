function MiningT(root)
  dofile(root .. "/objects/TurtleMoviments.lua")
  dofile(root .. "/objects/LoadPeripherals.lua")
  dofile(root .. "/controllers/LightController.lua")

  -- Local variables of the object / Variáveis locais do objeto
  local self = TurtleMoviments(root)
  local Data = self.getData()
  local objects = Data.getObjects()
  local storageGhosts = objects.ghosts.getStorageGhosts()
  local oldseed = os.time()
  local possibilities = {1, 2, 3, 4}
  local item, r = nil, nil
  local lightController = LightController(self)
  local oldseed = os.time()

  -- Local functions

  local function randomness(minimo, maximo)
    math.randomseed(oldseed)
    oldseed = ((oldseed - math.tan(os.time())) * ((os.clock() * 1000) + (os.time() / 1000))) / oldseed
    return math.random(minimo, maximo)
  end

  local function reset()
    for i = 1, 4 do
      possibilities[i] = i
    end
  end

  local function randomAction()
    if #possibilities > 1 then
      r = possibilities[randomness(1, #possibilities)]
      table.remove(possibilities, r)
    else
      possibilities[1] = nil
    end
    if next(possibilities) ~= nil then
      if r == 1 then
        return self.forward()
      else
        if r == 2 then
          return self.up()
        else
          if r == 3 then
            return self.down()
          else
            if r == 4 then
              return self.back()
            end
          end
        end
      end
    else
      if randomness(1, 2) == 1 then
        return self.left()
      else
        return self.right()
      end
      reset()
    end
  end

  local function dig(detect, inspect, side, action)
    if detect() and self.verifyItens() then
      sucess, item = inspect()
      if peripheral.getType(side) == nil and (storageGhosts[item.name] == nil or item.name == "EnderStorage:enderChest") then
        if not action() then
          objects.escape.addTries()
          return false
        else
          return true
        end
      end
    end
    return false
  end

  local function move(movement, attack, action, changePositionData)
    while not movement() do
      if (not self.verifyFuel()) then
        if (objects.execution.getExecuting() ~= "Maintenance") then
          objects.execution.setTerminate(true)
        end
        return false
      end
      attack()
      if not action() then
        if objects.escape.getTryToEscape() then
          return randomAction()
        else
          return false
        end
      end
    end
    reset()
    changePositionData()
    return true
  end

  local function attack(action)
    while action() do
      sleep(0.5)
    end
    return false
  end

  local function place(action, attackAction, digAction)
    if not action() then
      attackAction()
      digAction()
      return action()
    end
    return true
  end

  -- Global functions of the object / Funções Globais do objeto

  function self.digForward()
    return dig(self.detect, turtle.inspect, "front", turtle.dig)
  end

  function self.digUp()
    return dig(self.detectUp, turtle.inspectUp, "up", turtle.digUp)
  end

  function self.digDown()
    return dig(self.detectDown, turtle.inspectDown, "down", turtle.digDown)
  end

  function self.up()
    return move(
      turtle.up,
      self.attackUp,
      self.digUp,
      function()
        objects.position.addY()
        self.saveAll()
      end
    )
  end

  function self.down()
    return move(
      turtle.down,
      self.attackDown,
      self.digDown,
      function()
        objects.position.subY()
        self.saveAll()
      end
    )
  end

  function self.forward()
    return move(turtle.forward, self.attackForward, self.digForward, self.adjustGPSWhenGoForward)
  end

  function self.back()
    local lowFuel = false
    while not turtle.back() do
      if (self.verifyFuel()) then
        return false
      end
      self.attackForward()
      self.left()
      self.left()
      if not self.digForward() then
        self.right()
        self.right()
        if objects.escape.getTryToEscape() then
          return randomAction()
        else
          return false
        end
      end
      self.right()
      self.right()
    end
    reset()
    self.adjustGPSWhenGoBack()
    return true
  end

  function self.attackForward()
    return attack(turtle.attack)
  end

  function self.attackUp()
    return attack(turtle.attackUp)
  end

  function self.attackDown()
    return attack(turtle.attackDown)
  end

  function self.placeForward()
    return place(turtle.place, self.attackForward, self.digForward)
  end

  function self.placeUp()
    return place(turtle.placeUp, self.attackUp, self.digUp)
  end

  function self.placeDown()
    return place(turtle.placeDown, self.attackDown, self.digDown)
  end

  function self.enlighten(side, limit)
    lightController.enlighten(side, limit)
  end

  return self
end
