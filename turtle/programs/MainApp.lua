function MainApp(root)

  dofile(root .. "/objects/CommonFunctions.lua")
  dofile(root .. "/objects/MiningT.lua")
  dofile(root .. "/objects/Communicator.lua")

  dofile(root .. "/programs/Configuration.lua")
  dofile(root .. "/programs/Maintenance.lua")
  dofile(root .. "/programs/GoToPosition.lua")
  dofile(root .. "/programs/Stairs.lua")
  dofile(root .. "/programs/Tunnel.lua")
  dofile(root .. "/programs/Quarry.lua")
  dofile(root .. "/programs/DiamondQuarry.lua")

  dofile(root .. "/GUI/GUIMessages.lua")
  dofile(root .. "/GUI/GUIMain.lua")

  self = {}

  local miningT = MiningT(root)
  local objects = (miningT.getData()).getObjects()
  local execution = objects.execution
  local commonF = miningT.getCommonF()
  local guiMessages = GUIMessages()
  local guiMain = GUIMain(commonF,guiMessages)
  local continue,showMainMenu,showApps = true,true,true
  local turtleProcotol = nil
  local server = nil

  local mainCase = commonF.switch{
    [1] = function(x)
      Configuration(miningT)
    end,
    [2] = function(x)
      self.apps(guiMain)
    end,
    [3] = function(x)
      continue = false
    end,
    default = function (x) continue = false end
  }

  local appsCase = commonF.switch{
    [1] = function(x)
      local stairs = Stairs(miningT,guiMessages)
      stairs.start()
    end,
    [2] = function(x)
      local tunnel = Tunnel(miningT,guiMessages)
      tunnel.start()
    end,
    [3] = function(x)
      local maintenance = Maintenance(miningT,guiMessages)
      continue,showMainMenu = maintenance.start()
    end,
    [4] = function(x)
      local gtp = GoToPosition(miningT,guiMessages)
      x,y,z = guiMain.goToXYZ()
      if (x~=nil and y>4 and z~=nil) then
        miningT.down()
        gtp.goTo(x,y,z)
      end
    end,
    [5] = function(x)
      local quarry = Quarry(miningT,guiMessages)
      quarry.start()
    end,
    [6] = function(x)
      local diamondQuarry = DiamondQuarry(miningT,guiMessages)
      diamondQuarry.start()
    end,
    [7] = function(x)
      showApps = false
    end,
    default = function (x) print("Invalid Option") end
  }

  local function continueExecutionIf()
    if execution.getExecuting() ~= "" then
      if execution.getExecuting() == "Stairs" then
        appsCase:case(1)
      end
      if execution.getExecuting() == "Tunnel" then
        appsCase:case(2)
      end
      if execution.getExecuting() == "Maintenance" then
        appsCase:case(3)
      end
      if execution.getExecuting() == "Quarry" then
        appsCase:case(5)
      end
      if execution.getExecuting() == "DiamondQuarry" then
        appsCase:case(6)
      end
    end
  end

  local function continueExecution()
    while continue do
      turtle.select(1)
      continueExecutionIf()
      if showMainMenu then
        mainCase:case(tonumber(guiMain.menu()))
      end
    end
  end

  local function stabilishFirstConnection(communicator)
    for i = 1,5 do
      local protocolData = communicator.protocolGenerator()
      if (protocolData[3]) then
        turtleProcotol = protocolData[1]
        server = protocolData[2]
        return true
      end
    end
    return false
  end

  local function executeSlaveTask(task,master)
    if task.execution == "GoToPosition" then
      if next(task.params) ~= nil then
        local gtp = GoToPosition(miningT,guiMessages)
        local x,y,z = task.params[1],task.params[2],task.params[3]
        if (tonumber(x)~=nil and tonumber(y)~=nil and tonumber(z)~=nil) then
          if (y>4) then
            miningT.down()
            gtp.goTo(x,y,z)
          end
          print("Finish Task")
          Communicator().finishTask(objects.task.getData(),true,server,turtleProcotol)
          objects.task.reset()
        end
      end
      --communicator.finishTask(task,false,server,turtleProcotol)
    end
    if task.execution == "Stairs" then
      local stairs = Stairs(miningT,guiMessages,master)
      stairs.start()
    end
    if task.execution == "Tunnel" then
      if next(task.params) ~= nil then
        local tunnel = Tunnel(miningT,guiMessages,master)
        tunnel.start()
      end
      --communicator.finishTask(task,false,server,turtleProcotol)
    end
    if task.execution == "Quarry" then
      if next(task.params) ~= nil then
        local quarry = Quarry(miningT,guiMessages,master)
        quarry.start()
      end
      --communicator.finishTask(task,false,server,turtleProcotol)
    end
    if task.execution == "DiamondQuarry" then
      if next(task.params) ~= nil then
        local diamondQuarry = DiamondQuarry(miningT,guiMessages,master)
        diamondQuarry.start()
      end
      --communicator.finishTask(task,false,server,turtleProcotol)
    end
  end

  local function slaveBehavior(communicator)
    local task = communicator.waitForTask(turtleProcotol)
    guiMessages.showInfoMsg(textutils.serialize(task))
    local times = 1
    if (task.execution~=nil and task.execution ~= "") then
      local master = {["task"] = task,["server"] = server,["protocol"] = turtleProcotol}
      objects.task.set(master.task)
      miningT.saveAll()
      executeSlaveTask(task,master)
    else
      guiMessages.showErrorMsg("Turtle couldn't find a task to execute")
      print("Waiting" .. (3-times) .. " more times")
      if times > 3 then
        guiMessages.showInfoMsg("Disabling Ender and Slave Behavior")
        objects.turtleInfo.deactivateSlaveBehavior()
        objects.storages.disableEnder()
        guiMessages.showInfoMsg("Executing Maintenance")
        appsCase:case(3)
      else
        times = times + 1
      end
    end
  end

  function self.apps(guiMain)
    showApps = true
    while continue and showApps do
      if showMainMenu then
        appsCase:case(tonumber(guiMain.menuApps()))
      end
    end
  end

  function self.main()
    local r = 0;
    if (objects.turtleInfo.isSlave()) then
      guiMessages.showInfoMsg("Type something to access the turtle configuration")
      r = commonF.limitToWrite(1)
      if r ~= 0 then
        mainCase:case(1)
      else
        local communicator = Communicator(commonF)
        if execution.getExecuting() == "" then
          if stabilishFirstConnection(communicator) then
            if objects.task.getExecution() ~= nil and objects.task.getExecution() ~= "" then
              if (objects.task.isComplete() == true) then
                print("Finish Task")
                communicator.finishTask(objects.task.getData(),true,server,turtleProcotol)
                objects.task.reset()
              else
                executeSlaveTask(objects.task.getData(), {["task"] = objects.task.getData(),["server"] = server,["protocol"] = turtleProcotol})
              end
            end
            guiMessages.showSuccessMsg("Success on stablishing connection with server")
            guiMessages.showInfoMsg("Using protocol: " .. turtleProcotol)
            guiMessages.showInfoMsg("Waiting for tasks...")
            while (objects.turtleInfo.isSlave()) do
              if execution.getExecuting() == "" then
                slaveBehavior(communicator)
              else
                continueExecution()
              end
            end
          else
            guiMessages.showErrorMsg("Couldn't find a server, going back to home")
            local x,y,z = objects.home.getX(),objects.home.getY(),objects.home.getZ()
            local gtp = GoToPosition(miningT,guiMessages)
            gtp.backTo(x,y,z)
            objects.task.reset()
            Data.finalizeExecution()
            Data.previousPosIsHome()
            guiMessages.showInfoMsg("Executing Maintenance")
            appsCase:case(3)
          end
        else
          continueExecution()
        end
      end
    else
      guiMessages.showInfoMsg("Type something to access the main menu if there is some execution running")
      r = commonF.limitToWrite(2.5)
      if r == 0 then
        continueExecution()
      else
        mainCase:case(tonumber(guiMain.menu()))
      end
    end
  end

  return self
end
