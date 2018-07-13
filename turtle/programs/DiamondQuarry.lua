function DiamondQuarry(miningTurtle,guiCustomMessages,x,y)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local miningT = miningTurtle
  local Data = miningT.getData()
  local commonF = miningT.getCommonF()
  local objects = Data.getObjects()
  local specificData
  local posX,posY = x,y
  local guiMessages = guiCustomMessages or GUIMessages()
  -- Private functions / Funções privadas

  local function specificDataInput()
    specificLocalData = {}
    specificLocalData.first = true
    specificLocalData.turn = false
    specificLocalData.stepX = 0
    specificLocalData.stepY = 0
    specificLocalData.y = 0
    specificLocalData.x = 0
    if posX ~= nil and posY ~= nil then
      specificLocalData.x = posX
      specificLocalData.y = posY
    else
      while specificLocalData.y<=0 or specificLocalData.x<=0 do
        guiMessages.showHeader("Diamond Quarry")
		    print("Tell me the quarry dimension x:y")
        print("X:")
        specificLocalData.x = tonumber(commonF.limitToWrite(15))
        print("Y:")
        specificLocalData.y = tonumber(commonF.limitToWrite(15))
        if specificLocalData.y<=0 or specificLocalData.x<=0 then
          guiMessages.showWarningMsg("Informed value can't be zero or lower than zero")
        end
      end
    end
    return specificLocalData
  end

  local function addStepX()
    specificData.stepX = specificData.stepX + 1
    miningT.saveAll()
  end

  local function addStepY()
    specificData.stepY = specificData.stepY + 1
    miningT.saveAll()
  end

  local function main()
    if objects.execution.getExecuting() ~= "DiamondQuarry" then
      objects.execution.setExecuting("DiamondQuarry")
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
    [0] = function(x)
        while specificData.stepX <= specificData.x-1 and not objects.execution.getTerminate() do
          miningT.forward()
          miningT.digUp()
          miningT.digDown()
          addStepX()
          miningT.enlighten("down",27)
        end
        specificData.stepX = 0
        end,
    [1] = function(x)
        if specificData.turn then
          miningT.left()
          miningT.forward()
          miningT.digUp()
          miningT.digDown()
          miningT.left()
          specificData.turn = false
        else
          miningT.right()
          miningT.forward()
          miningT.digUp()
          miningT.digDown()
          miningT.right()
          specificData.turn = true
        end
        addStepY()
        end,
    default = function (x) return 0 end
  }

  local function patternAction()
    while objects.execution.getStep() <=1 and not objects.execution.getTerminate() do
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
    while  not objects.execution.getTerminate() and specificData.stepY <= specificData.y do
      while specificData.first do
        if objects.escape.getTries() > 0 then
          specificData.first=false
          for i = 1,5 do
            miningT.up()
          end
        else
          miningT.down()
        end
      end
      patternAction()
      miningT.verifyFuelLevel()
    end
    wasTerminated(objects.execution.getTerminate())
  end

  return self
end
