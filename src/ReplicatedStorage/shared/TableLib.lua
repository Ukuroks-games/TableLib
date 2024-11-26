--[[
	TableLib

	Библиотека для создания таблиц
]]
local TableLib = {}

--[[
	Структура таблицы.
]]
export type Table = {

	--[[
		Фрейм в который таблица вписывается
	]]
	Container: Frame,

	--[[
		Двемерный массив элементов таблицы
		обращаться как Data[Y][X]
	]]
	Data: {
		[number]: {
			[number]: Frame
		}
	},


}

--[[
	Создать таблицу.

	Params:

	* ContainerSize - Размер контейнера, в который вписывается 
	* size - Размер таблицы

	Returns:

	Созданная таблица
]]
function TableLib.CreateTable(ContainerSize: UDim2, size: {X: number, Y: number}): Table

	local ret: Table = {}
	ret.Container = Instance.new("Frame")
	ret.Container.Size = ContainerSize

	for i = 1, size.Y do

		ret.Data = {}

		for j = 1, size.X do
			local frame = Instance.new("Frame")

			frame.Parent = ret.Container
			frame.Name = "frame"..i.."x"..j

			ret.Data[i][j] = frame
		end
	end 

	TableLib.Normalise(ret)
	
	return ret
end

--[[
	Создать табличу из уже существующей из фрейма

	Params:

	* frame - фрейм из которого создаётся таблица

	Returns:

	Созданная таблица
]]
function TableLib.FromFrame(frame: Frame): Table

	local ret: Table = {}

	for key, value in pairs(frame:GetChildren()) do

	end

	return ret
end

--[[
	Скопировать таблицу

	Params:

	* table - Таблица для копирования

	Returns:

	Скопированная таблица
]]
function TableLib.Copy(table: Table): Table
	return TableLib.FromFrame(table.Container:Clone())
end

--[[
	Нормализовать размер и координаты элементов

	Params:

	* table - таблица над которой делать эти манипуляции
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
	Добавить столбец

	Params:

	* table - Таблица в которую добавляется новый столбец
]]
function TableLib.AddNewColumn(table: Table)
	
	for key, value in pairs(table.Data) do
		table.Data[key][#table.Data[key] + 1] = Instance.new("Frame")
	end
	
	TableLib.Normalise(table)
end

--[[
	Добавить строку

	Params:

	* table - Таблица в котору добавляется новая строка
]]
function TableLib.AddNewRow(table: Table)
	table.Data[#table.Data + 1] = {}
end



return TableLib
