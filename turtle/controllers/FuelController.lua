function FuelController(fuels)
  -- Local variables of the object / Variáveis locais do objeto

  local self = {}
  local fuels = fuels.getFuels()
  
  local guiMessages = GUIMessages()

  local mt = {}

  mt.__newIndex = function()
    return 0
  end

  mt.__index = function()
    return 0
  end

  setmetatable(fuels,mt)

  -- Local functions of the object / Funções locais do objeto
  local function fuelCalc(itemFuel,itemCount)
    local needed = math.floor((turtle.getFuelLimit() - turtle.getFuelLevel())/itemFuel)
    if needed > 0 then
      if needed > itemCount then
        turtle.refuel()
      else
        turtle.refuel(needed)
      end
      return false
    else
      return true
    end
  end

  -- Verifying if exists fuel in other slot / Verificando se existe combustível em outro espaço
  local function smartRefuel()
    local finish = false
    if turtle.getFuelLimit() - turtle.getFuelLevel() > 0 then
      guiMessages.showInfoMsg("Verifying fuel in all slots. [coal/lava]")
      for i = 1,16 do
        turtle.select(i)
        if turtle.refuel(0) then
          local data = turtle.getItemDetail(i)
          if data ~= nil then
            finish = fuelCalc(fuels[data.name],data.count)
            if finish then
              return sucess
            end
          end
        end
      end
    end
    return sucess
  end

  -- Global functions of the object / Funções globais do objeto

  -- Personalized getFuelLevel function / Função getFuelLevel personalizada
  function self.fuelLevel()
    return turtle.getFuelLevel()
  end

  -- Refuel function / Função de reabastecimento
  function self.refuel()
    if turtle.getFuelLevel() ~= "unlimited" then
      guiMessages.showHeader("Trying to refuel")
      if smartRefuel() == false then
        turtle.select(1)
        return false
      end
      turtle.select(1)
      guiMessages.showSuccessMsg("Finished")
    end
    return true
  end

  return self
end
