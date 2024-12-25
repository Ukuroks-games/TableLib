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
function TableLib.new(container: Frame, size: { X: number, Y: number }, padding: number?): Table
	local self = setmetatable({
		Container = container,
		Data = {},
		padding = Instance.new("NumberValue", container),
		Connections = {},
	}, TableClass)

	self.padding.Name = "Padding"

	for i = 1, size.Y do
		self.Data[i] = {}
		for j = 1, size.X do
			local frame = Instance.new("Frame")

			frame.Parent = self.Container
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

local function ParseTable(frame: Frame): TableData
	local Data = {}

	for _, value in pairs(frame:GetChildren()) do
		local y, x

		local pos = value.Name:find("x")

		y = tonumber(value.Name:sub(6, pos):match("%d+"))
		x = tonumber(value.Name:sub(6):match("%d+"))

		if y and x then
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

	local ret: Table = setmetatable({
		Container = copy,
		padding = paddingIstance,
		Connections = nil,
		Data = ParseTable(self.Container),
	}, TableClass)

	paddingIstance.Changed:Connect(function()
		TableLib.Normalise(ret)
	end)

	return ret
end

--[[
	# Удалить таблицу

	## Params:

	`table` - Удаляемая таблица
]]
function TableClass.Destroy(self: Table)
	self.Container:Destroy()
	self.padding:Destroy()
end

--[[
	# Нормализовать размер и координаты элементов

	## Params:

	`table` - таблица над которой делать эти манипуляции
]]
function TableLib.Normalise(table: Table)
	for i, v in pairs(table.Data) do
		for j, k in pairs(v) do
			k.Size = UDim2.fromScale(1 / #table.Data[i], 1 / #v)
			k.Position = UDim2.fromScale((j - 1) * (1 / #v), (i - 1) * (1 / #table.Data))
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
		v[#v + 1] = Instance.new("Frame", self.Container)
		v[#v + 1].Name = GiveNameToFrame(i, #v + 1)
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

	for i, v in pairs(self.Data[#self.Data]) do
		v = Instance.new("Frame", self.Container)
		v.Name = GiveNameToFrame(#self.Data + 1, i)
	end
end

return TableLib
