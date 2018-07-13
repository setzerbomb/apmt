function Tunnel(miningTurtle,guiCustomMessages,lim)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local miningT = miningTurtle
  local Data = miningT.getData()
  local commonF = miningT.getCommonF()
  local objects = Data.getObjects()
  local specificData
  local limit = lim
  local guiMessages = guiCustomMessages or GUIMessages()

  -- Private functions / Funções privadas

  local function specificDataInput()
    specificLocalData = {}
    specificLocalData.limit = 0
    specificLocalData.step = 0
    if limit ~= nil then
      specificLocalData.limit = limit
    else
      while specificLocalData.limit <= 0 do
        guiMessages.showHeader("Tunnel")
		    print("What should be the size of the tunnel?[3x3x?]")
        specificLocalData.limit = tonumber(commonF.limitToWrite(15))
        if specificLocalData.limit <= 0 then
          guiMessages.showWarningMsg("Informed value can't be zero or lower than zero")
        end
      end
    end
    return specificLocalData
  end

  local function addStep()
    specificData.step = specificData.step + 1
    miningT.saveAll()
  end

  local function main()
    if objects.execution.getExecuting() ~= "Tunel" then
      objects.execution.setExecuting("Tunel")
      objects.execution.setStep(0)
      objects.execution.setTerminate(false)
      objects.escape.setTries(0)
      objects.escape.setTryToEscape(true)
      objects.execution.setSpecificData(specificDataInput())
      specificData = objects.execution.getSpecificData()
    else
      specificData = objects.execution.getSpecificData()
      objects.escape.setTryToEscape(true)
    end
    miningT.saveAll()
  end
  main()

  local actionsCase = commonF.switch{
    [0] = function(x) miningT.forward() end,
    [1] = function(x) miningT.digUp() end,
    [2] = function(x) miningT.digDown() end,
    [3] = function(x) miningT.left() end,
    [4] = function(x) miningT.forward() end,
    [5] = function(x) miningT.digUp() end,
    [6] = function(x) miningT.digDown() end,
    [7] = function(x) miningT.right() end,
    [8] = function(x) miningT.right() end,
    [9] = function(x) miningT.forward() end,
    [10] = function(x) miningT.forward() end,
    [11] = function(x) miningT.digUp() end,
    [12] = function(x) miningT.digDown() end,
    [13] = function(x) miningT.left() end,
    [14] = function(x) miningT.left() end,
    [15] = function(x) miningT.forward() end,
    [16] = function(x) miningT.right() end,
    default = function (x) return 0 end
  }

  local function patternAction()
    while objects.execution.getStep() <=16 do
      actionsCase:case(objects.execution.getStep())
      objects.execution.addStep()
      miningT.saveAll()
    end
    objects.execution.setStep(0)
    miningT.saveAll()
  end

  local function wasTerminated(terminate)
    if terminate then
      Data.storeCurrentPosition()
      Data.storeCurrentExecution()
      Data.saveData()
      local maintenance = Maintenance(miningT)
      maintenance.start()
    else
      Data.finalizeExecution()
      Data.previousPosIsHome()
      local maintenance = Maintenance(miningT)
      maintenance.start()
    end
  end

  -- Global functions of the object / Funções Globais do objeto

  function self.start()
    guiMessages.showInfoMsg("You can use torchs putting them on slot "..objects.light.getSlot()..", to customizations change the current config")
    while specificData.step <= specificData.limit-1 and  not objects.execution.getTerminate() do
      patternAction()
      miningT.enlighten("left",4)
      miningT.verifyFuelLevel()
      addStep()
    end
    wasTerminated(objects.execution.getTerminate())
  end

  return self
end
