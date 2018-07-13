  function GUIKeepData(commonFunctions)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local commonF = commonFunctions
  local guiMessages = GUIMessages()

  -- Private functions / Funções privadas

  local function booleanResp(msg)
    print(msg)
    local resp = io.read()
    if resp == "y" or resp =="Y" then
      return true
    else
      return false
    end
  end

  function self.showErrorMsg(msg)
    guiMessages.showErrorMsg(msg)
  end

  function self.showSuccessMsg(msg)
    guiMessages.showSuccessMsg(msg)
  end

  function self.showWarningMsg(msg)
    guiMessages.showWarningMsg(msg)
  end

  function self.showInfoMsg(msg)
    guiMessages.showInfoMsg(msg)
  end

  function self.showHeader(msg)
    guiMessages.showHeader(msg)
  end

  function self.getOrientation(turtlePositionLookup,miningTurtle)
    local loc1 = turtlePositionLookup.main()
    local success, item = turtle.inspect()
    local result = -1
	  local miningT = miningTurtle
	  local eraseMiningTNewFunctions = false

	  if (miningT ~= nil) then
	    miningT.turnLeft = miningT.left
	    miningT.dig = miningT.digForward
      miningT.attack = miningT.attackForward
	    eraseMiningTNewFunctions = true
	  else
	    miningT = turtle
	  end

    if (success) then
      if (item.name ~= "minecraft:chest") then
        miningT.attack()
        miningT.dig()
      else
        miningT.turnLeft()
      end
    end
    if miningT.forward() then
      local loc2 = turtlePositionLookup.main()
      local heading = {x = loc2.x -loc1.x, y = loc2.y - loc1.y, z = loc2.z - loc1.z}
      result = (heading.x + math.abs(heading.x) * 2) + (heading.z + math.abs(heading.z) * 3)

      if result >= 4 then
        result = 0
      end
      miningT.back()
    end

	  if (eraseMiningTNewFunctions) then
	    miningT.turnLeft = nil
	    miningT.dig = nil
      miningT.attack = nil
	  end

    return result
  end

  -- Global functions of the object / Funções Globais do objeto

  -- Interface to set the position data of the turtle / Interface para inserir os dados de posição da turtle
  function self.begin()
    if turtle.getFuelLevel() <=0 then
      self.showInfoMsg("The Turtle will try to auto configure, to successful do, it'll needs some fuel")
      self.showInfoMsg("Put some coal or a lava bucket in the next 10 seconds")
      sleep(10)
      turtle.select(1)
      if not turtle.refuel() then
        self.showWarningMsg("Starting manual configuration")
      end
    end
  end

  function self.setPositionData(auto)
    local turtlePositionLookup = TurtlePositionLookup()
    local position = turtlePositionLookup.main()


    if turtle.getFuelLevel() > 0 and position ~= nil then
      position.f = self.getOrientation(turtlePositionLookup)
    else
      position = {}
      gpsWorks = false
      local errorFlag = true
      while errorFlag do
        errorFlag = false
        self.showHeader("--------Position Device--------")
        print("Type the X coordinate of the device")
        position.x = tonumber(io.read())
        print("Type the Y coordinate of the device")
        position.y = tonumber(io.read())
        print("Type the Z coordinate of the device")
        position.z = tonumber(io.read())
        print("Type the F coordinate of the device")
        position.f = tonumber(io.read())
        if position.x == nil or position.y == nil or position.z == nil or position.f == nil then
          self.showWarningMsg("Warning: X,Y,Z and F must be numbers")
          errorFlag = true
        else
          if position.f ~= nil then
            if position.f > 3 or position.f < 0 then
              self.showWarningMsg("Warning: F must be a number between 0 and 3")
              errorFlag = true
            end
          end
        end
      end
    end
    return position
  end

  function self.setFuels(auto)
    local fuels = {}
    fuels.list={}
    if auto then
      fuels.list["minecraft:lava_bucket"] = 1000
      fuels.list["minecraft:coal"] = 80
    end
    return fuels
  end

  function self.setStorages(auto)
    local storages = {}
    if auto then
      storages.enabled = false
      storages.slotIn = 13
      storages.slotOut = 14
    else
      self.showHeader("--------Storages--------")
      local success = false
      while not success do
        print("Let me know where the Input EnderStorage will stay [12-16]")
        storages.slotIn = tonumber(io.read())
        if storages.slotIn ~= nil then
          if (storages.slotIn >= 12 and storages.slotIn <= 16) then
            success = true
          else
		        self.showWarningMsg("Slot value must be between 12 and 16")
		      end
        end
      end
	    print("")
      success = false
      while not success do
        print("Let me know where the Output EnderStorage will stay [12-16]")

        storages.slotOut = tonumber(io.read())
        if storages.slotOut ~= nil then
          if (storages.slotOut >= 12 and storages.slotOut <= 16 and storages.slotOut ~= storages.slotIn) then
            success = true
          else
		        self.showWarningMsg("Slot value must be between 12 and 16 and different than: [" .. storages.slotIn .. "]")
		      end
        end
      end
      storages.enabled = booleanResp("Woul you like to enable the Ender Storages? [y/n]")
    end
    return storages
  end

  function self.setGhosts(auto)
    local ghosts = {}
    if auto then
      ghosts.storageGhosts = {}
      ghosts.storageGhosts["EnderStorage:enderChest"] = "EnderStorage:enderChest"
      ghosts.storageGhosts["minecraft:chest"] = "minecraft:chest"
      ghosts.lightGhosts = {}
      ghosts.lightGhosts["minecraft:torch"] = "minecraft:torch"
    end
    return ghosts
  end

  -- Interface to set the data of current execution / Interface para configurar a execução atual
  function self.setExecutionData()
    local exec = {}
    exec.executing = ""
    exec.step = 0
    exec.terminate = false
    exec.specificData = nil
    return exec
  end

  -- Interface to set escape data / Interface para configurar os dados de escape
  function self.setTryToEscapeData()
    local esc = {}
    esc.escape = true
    esc.tries = 0
    return esc
  end

  function self.setLightData(auto)
    local l = {}
    if auto then
      l.step = 0
      l.slot = 15
      l.enabled = true
    else
      self.showHeader("--------Light Configuration--------")
      l.step = 0
      local success = false
      while not success do
        print("Let me know where the Torch will stay [12-16]")
        l.slot = tonumber(io.read())
        if l.slot ~= nil then
          if (l.slot >= 12 and l.slot <= 16) then
            success = true
          else
		        self.showWarningMsg("The slot value must be between 12 and 16")
		      end
        end
      end
      self.showInfoMsg("The Torch slot will be " .. l.slot)
      l.enabled = booleanResp("Would you like to enable the torchs use? [y/n]")
    end
    return l
  end

  -- Just a interface / Somente uma interface
  function self.setPreviousPosition(x,y,z,f)
    local pPos = {}
    self.showInfoMsg("Saving current position")
    pPos.x = x
    pPos.y = y
    pPos.z = z
    pPos.f = f
    return pPos
  end

  function self.setTurtleInfo(auto)
    local turtleI = {}
    if auto then
      turtleI.world = "minecraft"
    else
      while turtleI.world == nil do
        self.showHeader("--------Aditional Configuration--------")
        print("Type the world name")
        turtleI.world = io.read()
      end
    end
    turtleI.id = os.getComputerID()
    turtleI.name = os.getComputerLabel()
    return turtleI
  end

  local function homeAutoSet(x,y,z)
    local home = {}

    self.showInfoMsg("Considering the actual position as home")

    home.isSet = true
    home.x = x
    home.y = y
    home.z = z

    return home
  end

  function self.homeManualSet()
    local errorFlag = true
    local home = {}

    while errorFlag do
      errorFlag = false
      home.isSet = true
      self.showHeader("--------House Position--------")
      print("Type the X house coordinate")
      home.x = tonumber(io.read())
      print("Type the Y house coordinate")
      home.y = tonumber(io.read())
      print("Type the Z house coordinate")
      home.z = tonumber(io.read())
      if home.x == nil or home.y == nil or home.z == nil then
        self.showWarningMsg("Warning: X,Y and Z must be numbers")
        errorFlag = true
      end
    end
    return home
  end
  -- Interface to set the home data / Interface para inserir os dados da casa
  function self.setHomeData(x,y,z,auto)
    self.showInfoMsg("x="..x.." y="..y.." z="..z)
    if (not auto) then
      print("Do you like to inform the house position now? [y/n]")
      local resp = io.read()
      if resp == "y" or resp =="Y" then
        return self.homeManualSet()
      end
    end
    return homeAutoSet(x,y,z)
  end

  function self.menu()
    self.showHeader("------Turtle Configuration------")
    print("1: Change device coordinates")
    print("2: Chance house coordinates")
    print("3: Clear all stored and current executions data and set goal position to home")
    print("4: Customize torch use")
    print("5: Change turtle information")
    print("6: Active/Deactivate Ender Storage use")
    print("7: Save and Exit")
    print("8: Exit without save")
    return io.read()
  end

  return self
end
