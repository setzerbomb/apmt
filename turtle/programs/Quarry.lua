function Quarry(miningTurtle,guiMessages,x,y)
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
    local specificLocalData = {}
    specificLocalData.stepX = 0
    specificLocalData.stepY = 0
    specificLocalData.y = 0
    specificLocalData.x = 0
    if posX~=nil and posY~=nil then
      specificLocalData.x = posX
      specificLocalData.y = posY
    else
      while specificLocalData.y<=0 or specificLocalData.x<=0 do
	      guiMessages.showHeader("Quarry")
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
    specificLocalData.turn = false
    specificLocalData.descend = false
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
    if objects.execution.getExecuting() ~= "Quarry" then
      objects.execution.setExecuting("Quarry")
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
        while specificData.stepX < specificData.x-1 do
          miningT.forward()
          addStepX()
        end
        specificData.stepX = 0
        end,
    [1] = function(x)
        if specificData.turn then
          if specificData.stepY < specificData.y-1 then
            miningT.left()
            miningT.forward()
            miningT.left()
            addStepY()
          else
            miningT.left()
            miningT.left()
            specificData.stepY = 0
            specificData.descend = true
          end
          specificData.turn = false
        else
          if specificData.stepY < specificData.y-1 then
            miningT.right()
            miningT.forward()
            miningT.right()
            addStepY()
          else
            miningT.right()
            miningT.right()
            specificData.stepY = 0
            specificData.descend = true
          end
          specificData.turn = true
        end
        end,
    [2] = function(x)
        if specificData.descend then
          miningT.down()
          specificData.descend = false
          specificData.turn = (not specificData.turn)
        end
        end,
    default = function (x) return 0 end
  }

  local function patternAction()
    while objects.execution.getStep() <=2 do
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
    while not objects.execution.getTerminate() and objects.position.getY() > 5 do
      patternAction()
      miningT.verifyFuelLevel()
    end
    wasTerminated(objects.execution.getTerminate())
  end

  return self
end
