function Light()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.setStep(step)
    data.step = step
  end

  function self.getStep()
    return data.step
  end

  function self.addStep()
    data.step = data.step + 1
  end

  function self.setSlot(slot)
    data.slot = slot
  end

  function self.getSlot()
    return data.slot
  end

  function self.setEnabled(enabled)
    data.enabled = enabled
  end

  function self.getEnabled()
    return data.enabled
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
