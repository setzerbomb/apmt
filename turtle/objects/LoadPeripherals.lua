function LoadPeripherals ()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local wraped = {}
  local types = {}

  -- Global functions of the object / Funções Globais do objeto

  -- Return a specific peripheral / Retorna um periférico específico
  function self.getPeripheral(key)
    return wraped[key]
  end

  -- Return the table of types of peripherals / Retorna a tabela contendo os tipos de periféricos
  function self.getTypes()
    return types
  end

  -- Print the list of peripherals / Imprime na tela a lista de periféricos
  function self.showTypes()
    return textutils.serialize(types)
  end

  -- Local Functions / Funções Locais

  -- The start function / A função de inicialização
  local function start()
    --os.loadAPI("ocs/apis/sensor")

    for k,v in ipairs(peripheral.getNames())do
    wraped[k] = peripheral.wrap(v)
    types[k] = {}
    if peripheral.getType(v)=="sensor" then
      types[k][1] = wraped[k].getSensorName()
      types[k][2] = v
    else
      types[k][1] = peripheral.getType(v)
      types[k][2] = v
    end
    end
  end

  self.openWirelessModem =  function(types)

    local locateModemSide = function(types)
      for k,v in ipairs(types) do
        if (v[1] == "modem") then
          return v[2]
        end
      end
      return nil
    end

    local side = locateModemSide(types)

    if (side ~= null) then
      if (rednet.isOpen(side) == false) then
        rednet.open(side)
      end
      return true
    end
    return false
  end

  start()

   return self
end
