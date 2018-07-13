function Stairs(miningTurtle,guiCustomMessages)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local miningT = miningTurtle
  local Data = miningT.getData()
  local commonF = miningT.getCommonF()
  local specificData
  local objects = Data.getObjects()
  local guiMessages = guiCustomMessages or GUIMessages()

  local function main()
    if objects.execution.getExecuting() ~= "Stairs" then
      objects.execution.setExecuting("Stairs")
      objects.execution.setStep(0)
      objects.execution.setTerminate(false)
      objects.escape.setTries(0)
      objects.escape.setTryToEscape(true)
    else
      objects.escape.setTryToEscape(true)
    end
    miningT.saveAll()
  end
  main()

  local actionsCase = commonF.switch{
    [0] = function(x) miningT.forward() end,
    [1] = function(x) miningT.digUp() end,
    [2] = function(x) miningT.digDown() end,
    [3] = function(x) miningT.up() end,
    [4] = function(x) miningT.digUp() end,
    [5] = function(x) miningT.down() end,
    [6] = function(x) miningT.left() end,
    [7] = function(x) miningT.forward() end,
    [8] = function(x) miningT.digUp() end,
    [9] = function(x) miningT.digDown() end,
    [10] = function(x) miningT.up() end,
    [11] = function(x) miningT.digUp() end,
    [12] = function(x) miningT.down() end,
    [13] = function(x) miningT.right() end,
    [14] = function(x) miningT.right() end,
    [15] = function(x) miningT.forward() end,
    [16] = function(x) miningT.forward() end,
    [17] = function(x) miningT.digUp() end,
    [18] = function(x) miningT.digDown() end,
    [19] = function(x) miningT.up() end,
    [20] = function(x) miningT.digUp() end,
    [21] = function(x) miningT.down() end,
    [22] = function(x) miningT.left() end,
    [23] = function(x) miningT.left() end,
    [24] = function(x) miningT.forward() end,
    [25] = function(x) miningT.right() end,
    [26] = function(x) miningT.down() end,
    default = function (x) return 0 end
  }

  local function patternAction()
    while objects.execution.getStep() <=26 do
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
    --guiMessages.showHeader("Stairs")
    guiMessages.showInfoMsg("You can use torchs putting them on slot "..objects.light.getSlot()..", to customizations change the current config")
    while objects.escape.getTries() <=0 and not objects.execution.getTerminate() do
      miningT.verifyFuelLevel()
      patternAction()
      miningT.enlighten("left",4)
    end
    wasTerminated(objects.execution.getTerminate())
  end

  return self
end
