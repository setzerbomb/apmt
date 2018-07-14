function MainApp(root)

  dofile(root .. "/objects/CommonFunctions.lua")
  dofile(root .. "/objects/MiningT.lua")

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
  local execution = ((miningT.getData()).getObjects()).execution
  local commonF = miningT.getCommonF()
  local guiMessages = GUIMessages()
  local guiMain = GUIMain(commonF,guiMessages)
  local continue,showMainMenu,showApps = true,true,true

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
      if x~=0 and y~=0 and z~=0 then
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

  local function continueExecution()
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
    guiMessages.showInfoMsg("Type something to access the main menu if there is some execution running")
    r = commonF.limitToWrite(2.5)
    if r == 0 then
      while continue do
        turtle.select(1)
        continueExecution()
        if showMainMenu then
          mainCase:case(tonumber(guiMain.menu()))
        end
      end
    else
      mainCase:case(tonumber(guiMain.menu()))
    end
  end

  return self
end
