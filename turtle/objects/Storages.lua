function Storages()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.setSlotOut(slotOut)
    data.slotOut = slotOut
  end

  function self.getSlotOut()
    return data.slotOut
  end

  function self.setSlotIn(slotIn)
    data.slotIn = slotIn
  end

  function self.getSlotIn()
    return data.slotIn
  end

  function self.enableEnder()
    data.enabled = true
  end

  function self.disableEnder()
    data.enabled = false
  end

  function self.isEnabled()
    return data.enabled
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
