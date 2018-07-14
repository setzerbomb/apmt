function GoToPosition(miningTurtle)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local miningT = miningTurtle
  local position = ((miningT.getData()).getObjects()).position
  local guiMessages = guiCustomMessages or GUIMessages()

  -- Private functions / Funções privadas

  local function selectAction(a,b,axis)
    if a > b then
      if axis=="x" then
        return 1
      end
      if axis=="z" then
        return 2
      end
    else
      if axis=="x" then
        return 3
      end
      if axis=="z" then
        return 0
      end
    end
  end

  local function adjustF(f)
    while f ~= position.getF() do
      miningT.left()
    end
  end

  local function adjustX(x2)
    adjustF(selectAction(position.getX(),x2,"x"))
    while position.getX() ~= x2 do
      miningT.forward()
    end
  end

  local function adjustZ(z2)
    adjustF(selectAction(position.getZ(),z2,"z"))
    while position.getZ() ~= z2 do
      miningT.forward()
    end
  end

  local function adjustY(y2)
    local action = nil
    if position.getY() > y2 then
      action = miningT.down
    else
      action = miningT.up
    end
    while position.getY() > 0 and position.getY() ~= y2 and position.getY() <= 254 do
      action()
    end
  end

  -- Global functions of the object / Funções Globais do objeto

  function self.backTo(x2,y2,z2)
    if (miningT.doIHaveEnoughFuelToGo(x2,y2,z2)) then
      adjustX(x2)
      adjustZ(z2)
      adjustY(y2)
    else
      guiMessages.showErrorMsg("I do not have fuel to do this task")
      end
    end

    function self.goTo(x2,y2,z2)
      if (miningT.doIHaveEnoughFuelToGo(x2,y2,z2)) then
        adjustY(y2)
        adjustZ(z2)
        adjustX(x2)
      else
        guiMessages.showErrorMsg("I do not have fuel to do this task")
        end
      end

      return self
    end
