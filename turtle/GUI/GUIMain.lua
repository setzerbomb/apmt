function GUIMain(commonFunctions,guiMessages)
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local commonF = commonFunctions

  -- Global functions of the object / Funções Globais do objeto

  function self.menuApps()
    guiMessages.showHeader("--------Apps--------")
    print("1: Create a Stair")
    print("2: Create a Tunnel")
    print("3: Execute Turtle Maintenance")
    print("4: Go to a specific position [x,y,z]")
    print("5: Quarry mode")
    print("6: Diamond Quarry mode")
    print("7: Return")
    return commonF.limitToWrite(15)
  end

  function self.menu()
    guiMessages.showHeader("------Main Menu------")
    print("1: Configure")
    print("2: Applications")
    print("3: Exit")
    return commonF.limitToWrite(15)
  end

  function self.goToXYZ()
    local x,y,z
    local errorFlag = false
    while (x==nil or y==nil or z==nil) or errorFlag do
      errorFlag = false
      guiMessages.showHeader("----------Coordinates----------")
      print("Type the X coordinate")
      x = tonumber(commonF.limitToWrite(15))
      print("Type the Y coordinate")
      y = tonumber(commonF.limitToWrite(15))
      print("Type the Z coordinate")
      z = tonumber(commonF.limitToWrite(15))
      if y == nil or z==nil or z == nil then
        guiMessages.showWarningMsg("Warning: X,Y and Z must be numbers")
        errorFlag = true
      else
        if y ~= nil then
          if y~=0 and y <= 4 then
            guiMessages.showWarningMsg("Warning: Y must be higher than 4")
            errorFlag = true
          end
        end
      end
    end
    return x,y,z
  end

  return self
end
