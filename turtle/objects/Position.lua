function Position()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}
  local data

  -- Global functions of the object / Funções Globais do objeto

  function self.addF()
    if data.f <3 then
      data.f = data.f + 1
    else
      data.f = 0
    end
  end

  function self.subF()
    if data.f > 0 then
      data.f = data.f - 1
    else
      data.f = 3
    end
  end

  function self.addY()
    data.y = data.y + 1
  end

  function self.subY()
    data.y = data.y - 1
  end

  function self.addZ()
    data.z = data.z + 1
  end

  function self.subZ()
    data.z = data.z - 1
  end

  function self.addX()
    data.x = data.x + 1
  end

  function self.subX()
    data.x = data.x - 1
  end

  function self.getF()
    return data.f
  end

  function self.setF(f)
    data.f = f
  end

  function self.getY()
    return data.y
  end

  function self.setY(y)
    data.y = y
  end

  function self.getX()
    return data.x
  end

  function self.setX(x)
    data.x = x
  end

  function self.getZ()
    return data.z
  end

  function self.setZ(z)
    data.z = z
  end

  function self.start(tabela)
    data = tabela
  end

  return self
end
