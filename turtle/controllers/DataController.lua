function DataController(commonFunctions, root)
  dofile(root .. "/objects/TableHandler.lua")

  dofile(root .. "/objects/Position.lua")
  dofile(root .. "/objects/PreviousPosition.lua")
  dofile(root .. "/objects/Execution.lua")
  dofile(root .. "/objects/StoredExecution.lua")
  dofile(root .. "/objects/Home.lua")
  dofile(root .. "/objects/Light.lua")
  dofile(root .. "/objects/Storages.lua")
  dofile(root .. "/objects/Fuels.lua")
  dofile(root .. "/objects/Escape.lua")
  dofile(root .. "/objects/GhostItems.lua")
  dofile(root .. "/objects/TurtleInfo.lua")
  dofile(root .. "/objects/Task.lua")

  dofile(root .. "/GUI/GUIKeepData.lua")

  -- Local variables of the object / Variáveis locais do objeto
  local self = {}

  local TableH = TableHandler()
  local guiKP = GUIKeepData(commonFunctions)

  local values = nil
  local objects = {}
  objects.position = Position()
  objects.light = Light()
  objects.previousPosition = PreviousPosition()
  objects.home = Home()
  objects.execution = Execution()
  objects.storedExecution = StoredExecution()
  objects.escape = Escape()
  --objects.outsideCommunication = OutsideCommunication()
  objects.task = Task()
  objects.turtleInfo = TurtleInfo()
  objects.fuels = Fuels()
  objects.ghosts = GhostItems()
  objects.storages = Storages()
  -- Local functions of the object / Funções locais do objeto

  -- Copy the content of a table located at: http://lua-users.org/wiki/CopyTable
  local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == "table" then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
        copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
      copy = orig
    end
    return copy
  end

  local function fillObjects()
    objects.position.start(values.Position)
    objects.previousPosition.start(values.PreviousPos)
    objects.home.start(values.Home)
    objects.execution.start(values.Execution)
    objects.storedExecution.start(values.StoredExecution)
    objects.escape.start(values.Escape)
    objects.light.start(values.Light)
    --objects.outsideCommunication.start(values.OutsideCommunication)
    objects.turtleInfo.start(values.TurtleInfo)
    objects.fuels.start(values.Fuels)
    objects.ghosts.start(values.Ghosts)
    objects.storages.start(values.Storages)
    objects.task.start(values.Task)
  end

  -- Create a new set data if the data file is empty / Cria um novo conjunto de dados se o arquivo de dados está vazio
  local function newData()
    values = {}

    local autoConfig = true

    guiKP.begin()
    values.Position = guiKP.setPositionData(autoConfig)
    values.PreviousPos =
      guiKP.setPreviousPosition(values.Position.x, values.Position.y, values.Position.z, values.Position.f)
    values.Home = guiKP.setHomeData(values.Position.x, values.Position.y, values.Position.z, autoConfig)
    values.Execution = guiKP.setExecutionData()
    values.StoredExecution = guiKP.setExecutionData()
    values.Escape = guiKP.setTryToEscapeData()
    values.Light = guiKP.setLightData(autoConfig)
    --values.OutsideCommunication = guiKP.setOCData(autoConfig)
    values.TurtleInfo = guiKP.setTurtleInfo(autoConfig)
    values.Fuels = guiKP.setFuels(autoConfig)
    values.Ghosts = guiKP.setGhosts(autoConfig)
    values.Storages = guiKP.setStorages(autoConfig)
    values.Task = {}
    fillObjects()
    self.saveData()
  end

  -- Global functions of the object / Funções Globais do objeto

  -- Load all the data from file / Carrega todos os dados do arquivo
  local function configureDataObjects()
    if values ~= nil and next(values) ~= nil then
      fillObjects()
    else
      newData()
    end
  end

  local function tryToSave()
    TableH.save(values, os.getComputerLabel())
  end

  -- Retrieve the data from the config file / Puxa os dados do arquivo de configuração
  function self.load()
    if TableH.fileExists(os.getComputerLabel()) then
      values = TableH.load(os.getComputerLabel())
      configureDataObjects()
    else
      configureDataObjects()
    end
  end

  -- Save the data into the config file / Salva os dados no arquivo de configuração
  function self.saveData()
    commonFunctions.try(
      tryToSave,
      function(exeception)
        guiKP.showErrorMsg("DataController: Cautch exception while trying to save turtle data: " .. exeception)
      end
    )
  end

  -- Save the current execution / Salva a execução atual
  function self.storeCurrentExecution()
    objects.storedExecution.setExecuting(objects.execution.getExecuting())
    objects.storedExecution.setStep(objects.execution.getStep())
    objects.storedExecution.setSpecificData(deepcopy(objects.execution.getSpecificData()))
    objects.storedExecution.setTerminate(objects.execution.getTerminate())
    self.saveData()
  end

  -- Restore a stopped execution / Restaura uma execução pausada
  function self.restoreStoredExecution()
    if objects.storedExecution.getExecuting() ~= "" then
      objects.execution.setExecuting(objects.storedExecution.getExecuting())
      objects.execution.setStep(objects.storedExecution.getStep())
      objects.execution.setSpecificData(deepcopy(objects.storedExecution.getSpecificData()))
      objects.execution.setTerminate(false)
      objects.storedExecution.setExecuting("")
      objects.storedExecution.setStep(0)
      objects.storedExecution.setSpecificData(nil)
      objects.storedExecution.setTerminate(false)
      self.saveData()
    end
  end

  -- Finalize the current execution
  function self.finalizeExecution()
    objects.execution.setExecuting("")
    objects.execution.setStep(0)
    objects.execution.setSpecificData(nil)
    objects.execution.setTerminate(false)
    self.saveData()
  end

  -- Save the current position / Salva a posição atual
  function self.storeCurrentPosition()
    objects.previousPosition.setX(objects.position.getX())
    objects.previousPosition.setY(objects.position.getY())
    objects.previousPosition.setZ(objects.position.getZ())
    objects.previousPosition.setF(objects.position.getF())
  end

  function self.previousPosIsHome()
    objects.previousPosition.setX(objects.home.getX())
    objects.previousPosition.setY(objects.home.getY())
    objects.previousPosition.setZ(objects.home.getZ())
  end

  -- Getters

  function self.getObjects()
    return objects
  end

  return self
end
