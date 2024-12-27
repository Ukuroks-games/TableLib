--[[
	# TableLib

	Библиотека для создания таблиц

	Author: Egor00f
]]
local TableLib = {}

--[[
	# Структура массива ячеек таблицы
]]
export type TableData = {
	[number]: {
		[number]: Frame,
	},
}

export type Size = {
	X: number,
	Y: number,
}

--[[
	# Структура таблицы.
]]
export type Table = {

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

	--[[
			Скопировать таблицу

			## Params:

			`table` - Таблица для копирования

			## Returns:

			Скопированная таблица
		]]
	Copy: (self: Table) -> Table,

	--[[
			# Удалить таблицу

			## Params:

			`table` - Удаляемая таблица
		]]
	Destroy: (self: Table) -> (),

	--[[
		# Добавить столбец

		## Params:

		`table` - Таблица в которую добавляется новый столбец
	]]
	AddNewColumn: (self: Table) -> (),

	--[[
		# Добавить строку

		## Params:

		`table` - Таблица в котору добавляется новая строка
	]]
	AddNewRow: (self: Table) -> (),

	--[[
		# Получить кол-во строк в таблице
	]]
	GetRowsNum: (self: Table) -> number,

	--[[
		# Получить кол-во стобцов в таблице

		## Params:

		`row` - номер строки, по умолчанию 1
	]]
	GetColsNum: (self: Table, row: number?) -> number,

	--[[
		# Заменить ячейку таблицы

		## Params:

		`row` - строка

		`col` - столбец

		`frame` - То на что заменяется
	]]
	ReplaceTableCell: (self: Table, row: number, col: number, frame: Frame) -> (),
}

local function GiveNameToFrame(i: number, j: number): string
	return "frame " .. i .. " " .. j
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
	# Создать таблицу.

	## Params:

	`ContainerSize` - Размер контейнера, в который вписывается 

	`size` - Размер таблицы

	## Returns:

	Созданная таблица
]]
function TableLib.new(container: Frame, size: Size, padding: number?, typeofTableContent: string?): Table
	assert(container, "container not set")
	assert(size.X >= 0 and size.Y >= 0, "negative values of size")

	local self: Table = {
		Container = container,
		Data = {},
		padding = Instance.new("NumberValue", container),
		Connections = {},
		Copy = TableLib.Copy,
		Destroy = TableLib.Destroy,
		AddNewColumn = TableLib.AddNewColumn,
		AddNewRow = TableLib.AddNewRow,
		GetColsNum = TableLib.GetColsNum,
		GetRowsNum = TableLib.GetRowsNum,
		ReplaceTableCell = TableLib.ReplaceTableCell,
	}

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
	# Создать таблицу из уже существующей из фрейма

	## Params:

	`frame` - фрейм из которого создаётся таблица

	## Returns:

	Созданная таблица

	## Warnings:

	> Функция очень медленная из-за опреций со строками 

]]
function TableLib.FromFrame(frame: Frame): Table
	local self: Table = {
		Container = frame,
		Data = ParseTable(frame),
		padding = frame:WaitForChild("Padding"),
		Connections = {},
		Copy = TableLib.Copy,
		Destroy = TableLib.Destroy,
		AddNewColumn = TableLib.AddNewColumn,
		AddNewRow = TableLib.AddNewRow,
		GetColsNum = TableLib.GetColsNum,
		GetRowsNum = TableLib.GetRowsNum,
		ReplaceTableCell = TableLib.ReplaceTableCell,
	}

	table.insert(
		self.Connections,
		self.padding.Changed:Connect(function()
			TableLib.Normalise(self)
		end)
	)

	return self
end

--[[
	# Нормализовать размер и координаты элементов

	Распологает все елементы таблицы 

	## Params:

	`table` - таблица над которой делать эти манипуляции
]]
function TableLib.Normalise(Table: Table, row: number?, col: number?)
	-- простите, но я не могу мыслить без начала отчета с нуля, поэтому везде -1
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

function TableLib.Copy(self: Table): Table
	local copy = self.Container:Clone()

	local paddingIstance = self.padding:Clone() or copy:WaitForChild("Padding")
	paddingIstance.Parent = copy

	local selfCopy: Table = {
		Container = copy,
		padding = paddingIstance,
		Connections = {},
		Data = ParseTable(self.Container),
		Copy = TableLib.Copy,
		Destroy = TableLib.Destroy,
		AddNewColumn = TableLib.AddNewColumn,
		AddNewRow = TableLib.AddNewRow,
		GetColsNum = TableLib.GetColsNum,
		GetRowsNum = TableLib.GetRowsNum,
		ReplaceTableCell = TableLib.ReplaceTableCell,
	}

	table.insert(
		selfCopy.Connections,
		paddingIstance.Changed:Connect(function()
			TableLib.Normalise(self)
		end)
	)

	return selfCopy
end

function TableLib.Destroy(self: Table)
	for _, v in pairs(self.Connections) do
		if v then
			v:Disconnect()
		end
	end

	self.Container:Destroy()
	self.padding:Destroy()
end

function TableLib.AddNewColumn(self: Table)
	for i, v in pairs(self.Data) do
		local a = Instance.new("Frame", self.Container)
		a.Name = GiveNameToFrame(i, #v + 1)

		v[#v + 1] = a
	end

	TableLib.Normalise(self)
end

function TableLib.AddNewRow(self: Table)
	self.Data[#self.Data + 1] = {}

	for i = 1, #self.Data[#self.Data] do
		local a = Instance.new("Frame", self.Container)
		a.Name = GiveNameToFrame(#self.Data + 1, i)

		self.Data[#self.Data + 1][i] = a
	end

	TableLib.Normalise(self)
end

function TableLib.GetRowsNum(self: Table): number
	return #self.Data
end

function TableLib.GetColsNum(self: Table, row: number?): number
	return #self.Data[row or 1]
end

function TableLib.ReplaceTableCell(self: Table, row: number, col: number, frame: Frame)
	assert(self:GetRowsNum() >= row and self:GetColsNum(row) >= col, "out of table size")

	local cell = self.Data[row][col]

	frame.Position = cell.Position
	frame.Size = cell.Size
	frame.Parent = cell.Parent
	frame.Name = GiveNameToFrame(row, col)

	cell:Destroy()
end

return TableLib
