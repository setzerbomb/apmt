function Task()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.getStatus()
    return data.status
  end
  function self.setStatus(status)
    data.status = status
  end

  function self.getExecution()
    return data.execution
  end

  function self.getParams()
    return data.params
  end

  function self.getId()
    return data.id
  end

  function self.isSent()
    return data.sent
  end

  function self.isComplete()
    return data.complete
  end

  function self.complete()
    data.complete = true
  end

  function self.start(tabela)
    data = tabela
  end

  function self.getData()
    return data
  end

  function self.reset()
    data.complete = false
    data.execution = ""
    data.params = {}
    data.status = nil
    data.sent = false
    data.id = 0
  end

  function self.set(task)
    data.complete = task.complete
    data.execution = task.execution
    data.params = task.params
    data.status = task.status
    data.sent = task.sent
    data.id = task.id
  end

  return self
end
