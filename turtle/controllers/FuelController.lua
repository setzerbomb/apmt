function FuelController(fuels)
  -- Local variables of the object / Variáveis locais do objeto

  local self = {}
  local fuelsList = fuels.getFuels()

  local guiMessages = GUIMessages()

  local mt = {}

  mt.__newIndex = function()
    return 0
  end

  mt.__index = function()
    return 0
  end

  setmetatable(fuelsList,mt)

  fuels.setRefuelTries(0)

  -- Local functions of the object / Funções locais do objeto
  local function fuelCalc(itemFuel,itemCount,fuelAmount)
    local needed = 0
    if (fuelAmount == nil) then
      needed = math.floor((turtle.getFuelLimit() - turtle.getFuelLevel())/itemFuel)
    else
      needed = fuelAmount/itemFuel
    end
    if needed > 0 then
      if needed > itemCount then
        turtle.refuel()
      else
        turtle.refuel(needed)
      end
      return true,true
    end
    return true,false
  end

  -- Verifying if exists fuel in other slot / Verificando se existe combustível em outro espaço
  local function smartRefuel(fuelAmount)
    local success = false
    local finished = false
    if turtle.getFuelLimit() - turtle.getFuelLevel() > 0 then
      guiMessages.showInfoMsg("Verifying fuel in all slots. [coal/lava]")
      for i = 1,16 do
        turtle.select(i)
        if turtle.refuel(0) then
          local data = turtle.getItemDetail(i)
          if data ~= nil then
            success,finished = fuelCalc(fuelsList[data.name],data.count,fuelAmount)
            if (finished) then
              return true
            else
              if (fuelAmount~=nil) then
                if (fuelAmount < self.fuelLevel()) then
                  return true
                end
              end
            end
          end
        end
      end
    end
    return success
  end

  -- Global functions of the object / Funções globais do objeto

  -- Personalized getFuelLevel function / Função getFuelLevel personalizada
  function self.fuelLevel()
    return turtle.getFuelLevel()
  end
  
  -- Refuel function / Função de reabastecimento
  function self.refuel(fuelAmount)
    if turtle.getFuelLevel() ~= "unlimited" then
      guiMessages.showHeader("Trying to refuel")
      if (smartRefuel(fuelAmount) == false) then
        turtle.select(1)
        fuels.addRefuelTries()
        guiMessages.showErrorMsg("Failed")
        return false
      end
      turtle.select(1)
      guiMessages.showSuccessMsg("Finished")
    end
    fuels.setRefuelTries(0)
    return true
  end

  return self
end
