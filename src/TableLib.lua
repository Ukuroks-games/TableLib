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
		[number]: Frame
	}
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
	Connections: {
		RBXScriptConnection
	}
}

local function GiveNameToFrame(i: number, j: number): string
	return "frame "..i.." "..j
end

--[[
	# Создать таблицу.

	## Params:

	`ContainerSize` - Размер контейнера, в который вписывается 
	`size` - Размер таблицы

	## Returns:

	Созданная таблица
]]
function TableLib.CreateTable(ContainerSize: UDim2, size: {X: number, Y: number}, padding: number?): Table

	local ret: Table = {
		Container = Instance.new("Frame"),
		Data = nil,
		padding = Instance.new("NumberValue"),
		Connections = nil
	}
	ret.Container.Size = ContainerSize
	ret.padding.Parent = ret.Container
	ret.padding.Name = "Padding"

	for i = 1, size.Y do

		ret.Data = {}

		for j = 1, size.X do
			local frame = Instance.new("Frame")

			frame.Parent = ret.Container
			frame.Name = GiveNameToFrame(i, j)

			ret.Data[i][j] = frame
		end
	end

	TableLib.Normalise(ret)

	ret.padding.Changed:Connect(function(NewValue: number) 
		TableLib.Normalise(ret)
	end)

	return ret
end

local function ParseTable(frame: Frame): TableData

	local Data = {}

	for key, value in pairs(frame:GetChildren()) do

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

	local ret: Table = {
		Container = frame,
		Data = ParseTable(frame),
		padding = frame:WaitForChild("Padding"),
		Connections = nil
	}



	ret.Connections = {ret.padding.Changed:Connect(function(NewValue: number) 
		TableLib.Normalise(ret)
	end)
	}

	return ret
end

--[[
	Скопировать таблицу

	## Params:

	`table` - Таблица для копирования

	## Returns:

	Скопированная таблица
]]
function TableLib.Copy(table: Table): Table	
	local copy = table.Container:Clone()

	local paddingIstance = copy:WaitForChild("Padding")

	local ret: Table = {
		Container = copy,
		padding = paddingIstance,
		Connections = nil,
		Data = ParseTable(table.Container)
	}



	paddingIstance.Changed:Connect(function(NewValue: string)
		TableLib.Normalise(ret)
	end)

	return ret
end

--[[
	# Удалить таблицу

	## Params:

	`table` - Удаляемая таблица
]]
function TableLib.DeleteTable(table: Table)
	table.Container:Destroy()

end

--[[
	# Нормализовать размер и координаты элементов

	## Params:

	`table` - таблица над которой делать эти манипуляции
]]
function TableLib.Normalise(table: Table)

	for i, v in pairs(table.Data) do
		for j, k in pairs(v) do
			k.Size = UDim2.fromScale (
				1 / #table.Data[i],
				1 / #v
			)
			k.Position = UDim2.fromScale (
				(j - 1) * (1 / #v), 
				(i - 1) * (1 / #table.Data)
			)
		end
	end

end

--[[
	# Добавить столбец

	## Params:

	`table` - Таблица в которую добавляется новый столбец
]]
function TableLib.AddNewColumn(table: Table)

	for key, value in pairs(table.Data) do
		table.Data[key][#table.Data[key] + 1] = Instance.new("Frame")
		table.Data[key][#table.Data[key] + 1].Name = GiveNameToFrame(key, #table.Data[key] + 1)
	end

	TableLib.Normalise(table)
end

--[[
	# Добавить строку

	## Params:

	`table` - Таблица в котору добавляется новая строка
]]
function TableLib.AddNewRow(table: Table)
	table.Data[#table.Data + 1] = {}

	for i, v in pairs(table.Data[#table.Data]) do
		v = Instance.new("Frame")
		v.Name = GiveNameToFrame(#table.Data + 1, i)
	end
end

return TableLib
