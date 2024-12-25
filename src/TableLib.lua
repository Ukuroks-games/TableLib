--[[
	# TableLib

	Библиотека для создания таблиц

	Author: Egor00f
]]
local TableLib = {}

local TableClass = {}
TableClass.__index = TableClass

--[[
	# Структура массива ячеек таблицы
]]
export type TableData = {
	[number]: {
		[number]: Frame,
	},
}

--[[
	# Структура таблицы.
]]
export type Table = typeof(setmetatable(
	{} :: {

		--[[
			# Фрейм в который таблица вписывается
		]]
		Container: Frame,

		--[[
			# Двумерный массив ячеек таблицы

			обращаться как Data[Y][X]
		]]
		Data: TableData,

		--[[
			# Отступы между ячейками таблицы

			имя инстанса Padding

			При изменении значения, таблица автоматически потстраивает размер ячеек
		]]
		padding: NumberValue,

		--[[
			# Список всех подключений

			Руками не трогать!
		]]
		Connections: { RBXScriptConnection },
	},
	TableClass
))

local function GiveNameToFrame(i: number, j: number): string
	return "frame " .. i .. " " .. j
end

--[[
	# Создать таблицу.

	## Params:

	`ContainerSize` - Размер контейнера, в который вписывается 

	`size` - Размер таблицы

	## Returns:

	Созданная таблица
]]
function TableLib.new(
	container: Frame,
	size: { X: number, Y: number },
	padding: number?,
	typeofTableContent: string?
): Table
	local self = setmetatable({
		Container = container,
		Data = {},
		padding = Instance.new("NumberValue", container),
		Connections = {},
	}, TableClass)

	self.padding.Name = "Padding"
	self.padding.Value = padding or 0

	for i = 1, size.Y do
		self.Data[i] = {}
		for j = 1, size.X do
			local frame = Instance.new(typeofTableContent or "Frame", self.Container)

			frame.Name = GiveNameToFrame(i, j)

			self.Data[i][j] = frame
		end
	end

	TableLib.Normalise(self)

	table.insert(
		self.Connections,
		self.padding.Changed:Connect(function()
			TableLib.Normalise(self)
		end)
	)

	return self
end

--[[
	# Парсер фрейма

	Создаёт структура данных
]]
local function ParseTable(frame: Frame): TableData
	local Data = {}

	for _, value in pairs(frame:GetChildren()) do
		local y, x

		y = tonumber(value.Name:sub(6, value.Name:find("x")):match("%d+"))
		x = tonumber(value.Name:sub(6):match("%d+"))

		if y and x then
			if table.find(Data, x) == nil then
				Data[y] = {}
			end

			Data[y][x] = value
		end
	end

	return Data
end

--[[
	# Создать таблицу из уже существующей из фрейма

	## Params:

	`frame` - фрейм из которого создаётся таблица

	## Returns:

	Созданная таблица

	## Warnings:

	Функция очень медленная из-за опреций со строками

]]
function TableLib.FromFrame(frame: Frame): Table
	local self: Table = setmetatable({
		Container = frame,
		Data = ParseTable(frame),
		padding = frame:WaitForChild("Padding"),
		Connections = {},
	}, TableClass)

	table.insert(
		self.Connections,
		self.padding.Changed:Connect(function()
			TableLib.Normalise(self)
		end)
	)

	return self
end

--[[
	Скопировать таблицу

	## Params:

	`table` - Таблица для копирования

	## Returns:

	Скопированная таблица
]]
function TableClass.Copy(self: Table): Table
	local copy = self.Container:Clone()

	local paddingIstance = copy:WaitForChild("Padding", copy)

	local self: Table = setmetatable({
		Container = copy,
		padding = paddingIstance,
		Connections = {},
		Data = ParseTable(self.Container),
	}, TableClass)

	table.insert(
		self.Connections,
		paddingIstance.Changed:Connect(function()
			TableLib.Normalise(self)
		end)
	)

	return self
end

--[[
	# Удалить таблицу

	## Params:

	`table` - Удаляемая таблица
]]
function TableClass.Destroy(self: Table)
	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end

	self.Container:Destroy()
	self.padding:Destroy()
end

--[[
	# Нормализовать размер и координаты элементов

	Распологает все елементы таблицы 

	## Params:

	`table` - таблица над которой делать эти манипуляции
]]
function TableLib.Normalise(Table: Table, row: number?, col: number?)
	-- простите, но я не могу мыслить без начала отчета с нуля
	-- я ваще плюсовик, не шарю за эту конченую нумерацию

	--[[
		
	]]
	local function set(k: Frame, v: number, i: number, j: number)
		k.Size = UDim2.new(1 / v, -Table.padding.Value, 1 / v, -Table.padding.Value)
		k.Position = UDim2.fromScale((j - 1) * (1 / v), (i - 1) * (1 / #Table.Data))
	end

	if row and col then
		set(Table.Data[row][col], #Table.Data[row], row, col)
	else
		for i, v in pairs(Table.Data) do
			for j, k in pairs(v) do
				set(k, #v, i, j)
			end
		end
	end
end

--[[
	# Добавить столбец

	## Params:

	`table` - Таблица в которую добавляется новый столбец
]]
function TableClass.AddNewColumn(self: Table)
	for i, v in pairs(self.Data) do
		local a = Instance.new("Frame", self.Container)
		a.Name = GiveNameToFrame(i, #v + 1)

		v[#v + 1] = a
	end

	TableLib.Normalise(self)
end

--[[
	# Добавить строку

	## Params:

	`table` - Таблица в котору добавляется новая строка
]]
function TableClass.AddNewRow(self: Table)
	self.Data[#self.Data + 1] = {}

	for i = 1, #self.Data[#self.Data] do
		local a = Instance.new("Frame", self.Container)
		a.Name = GiveNameToFrame(#self.Data + 1, i)

		self.Data[#self.Data + 1][i] = a
	end

	TableLib.Normalise(self)
end

--[[
	# Получить кол-во строк в таблице
]]
function TableClass.GetRowsNum(self: Table): number
	return #self.Data
end

--[[
	# Получить кол-во стобцов в таблице

	## Params:

	`row` - номер строки, по умолчанию 1
]]
function TableClass.GetColsNum(self: Table, row: number?): number
	return #self.Data[row or 1]
end

--[[
	# Заменить ячейку таблицы

	## Params:

	`row` - строка

	`col` - столбец

	`frame` - То на что заменяется
]]
function TableClass.ReplaceTableCell(self: Table, row: number, col: number, frame: Frame)
	local cell = self.Data[row][col]

	if cell then
		cell:Destroy()
	end

	cell = frame
	frame.Name = GiveNameToFrame(row, col)
	frame.Parent = self.Container

	TableLib.Normalise(self)
end

return setmetatable(TableLib, TableClass)
