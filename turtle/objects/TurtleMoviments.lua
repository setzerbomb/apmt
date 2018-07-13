function TurtleMoviments(root)

  dofile(root .. "/controllers/DataController.lua")
  dofile(root .. "/controllers/FuelController.lua")
  dofile(root .. "/objects/TurtlePositionLookup.lua")

  -- Local variables of the object / Variáveis locais do objeto
  local self = {}

  local commonF = CommonFunctions()
  local Data = DataController(commonF,root)
  local FuelC
  local objects

  local function loadAndFillDataObjects()
    Data.load()
    objects = Data.getObjects()
  end

  local function calculateDistance(x1,y1,z1,x2,y2,z2)
    distance = {}
    distance.x = math.sqrt(math.pow((x2 - x1),2))
    distance.y = math.sqrt(math.pow((y2 - y1),2))
    distance.z = math.sqrt(math.pow((z2 - z1),2))
    return distance
  end

  -- Global functions of the object / Funções Globais do objeto

  function self.right()
    if turtle.turnRight() then
      objects.position.addF()
      self.saveAll()
    end
  end

  function self.getData()
    return Data
  end

  function self.getCommonF()
    return commonF
  end

  function self.left()
    if turtle.turnLeft() then
      objects.position.subF()
      self.saveAll()
    end
  end

  local function action(moviment,changePositionData)
    if not moviment() then
      self.verifyFuel()
    else
      changePositionData()
    end
  end

  function self.up()
    action(turtle.up,function() objects.position.addY(); self.saveAll(); end)
  end

  function self.down()
    action(turtle.down,function() objects.position.subY(); self.saveAll(); end)
  end

  function self.forward()
    action(turtle.forward,self.adjustGPSWhenGoForward)
  end

  function self.back()
    action(turtle.back,self.adjustGPSWhenGoBack)
  end

  function self.adjustGPSWhenGoForward()
    local gpsCase = commonF.switch{
      [0] =function (x) objects.position.addZ() end,
      [1] =function (x) objects.position.subX() end,
      [2] =function (x) objects.position.subZ() end,
      [3] =function (x) objects.position.addX() end,
      default = function (x) return false end
    }
    gpsCase:case(objects.position.getF())
    self.saveAll()
  end

  function self.adjustGPSWhenGoBack()
    local gpsCase = commonF.switch{
      [0] =function (x) objects.position.subZ() end,
      [1] =function (x) objects.position.addX() end,
      [2] =function (x) objects.position.addZ() end,
      [3] =function (x) objects.position.subX() end,
      default = function (x) return false end
    }
    gpsCase:case(objects.position.getF())
    self.saveAll()
  end

  function self.verifyFuel()
    if FuelC.fuelLevel() <= 10 then
      return FuelC.refuel()
    else
      return true
    end
  end

  function self.forceRefuel()
    return FuelC.refuel()
  end

  function self.saveAll()
    Data.saveData()
  end

  function self.verifyItens()
    for i = 1,12 do
      if turtle.getItemCount(i) == 0 then
        return true
      end
    end
    objects.execution.setTerminate(true)
    return true
  end

  function self.verifyFuelLevel()
    local distance = calculateDistance(objects.position.getX(),objects.position.getY(),objects.position.getZ(),objects.home.getX(),objects.home.getY(),objects.home.getZ())
    local dXYZ = distance.x + distance.y + distance.z
    if turtle.getFuelLevel() <= (dXYZ+50) then
      if not FuelC.refuel() then
        objects.execution.setTerminate(true)
      end
    end
  end

  function self.getDistance(x2,y2,z2)
    local d = calculateDistance(objects.position.getX(),objects.position.getY(),objects.position.getZ(),x2,y2,z2)
    return (d.x + d.y + d.z)
  end

  self.select = turtle.select

  self.place = turtle.place

  self.placeUp = turtle.placeUp

  self.placeDown = turtle.placeDown

  self.detect = turtle.detect

  self.detectUp = turtle.detectUp

  self.detectDown = turtle.detectDown

  self.suck = turtle.suck

  self.suckUp = turtle.suckUp

  self.suckDown = turtle.suckDown

  self.drop = turtle.drop

  self.dropUp = turtle.dropUp

  self.dropDown = turtle.dropDown

  self.getItemCount = turtle.getItemCount

  self.getItemSpace = turtle.getItemSpace

  local function start()
    loadAndFillDataObjects()
    FuelC = FuelController((Data.getObjects()).fuels)
  end
  start()

  return self
end
