function StoredExecution()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.setExecuting(toExecute)
    data.executing = toExecute
  end

  function self.getExecuting()
    return data.executing
  end

  function self.setStep(step)
    data.step = step
  end

  function self.getStep()
    return data.step
  end

  function self.addStep()
    data.step = data.step + 1
  end

  function self.setSpecificData(specificData)
    data.specificData = specificData
  end

  function self.getSpecificData()
    return data.specificData
  end

  function self.setTerminate(novo)
    data.terminate = novo
  end

  function self.getTerminate()
    return data.terminate
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
