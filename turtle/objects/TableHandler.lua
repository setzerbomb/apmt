function TableHandler()
  -- Local variables of the object / Variáveis locais do objeto
  local self = {}

  -- Global functions of the object / Funções Globais do objeto

  -- Verify if the file called exists / Verifica se o arquivo chamado existe
  function self.fileExists(name)
    local f = fs.open(name, "r")
    if f == nil then
      return false
    else
      return true
    end
  end

  -- Save the data of the table in a file / Salva os dados da tabela em um arquivo
  function self.save(table, name)
    local file = fs.open(name, "w")
    file.write(textutils.serialize(table))
    file.close()
  end

  -- Read the data of a file and try to put into a table / Lê os dados de um arquivo e tenta coloca-lo em uma tabela
  function self.load(name)
    if self.fileExists(name) then
      local file = fs.open(name, "r")
      local data = file.readAll()
      file.close()
      return textutils.unserialize(data)
    else
      return nil
    end
  end

  return self
end
