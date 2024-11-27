# How use it

Guide to how use this lib.

For use this lib

Include this lib:
```
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TableLib = require(ReplicatedStorage.shared.TableLib)
```

Table structure have members:
+ `Container` - table in this frame
+ `Data` - array of table elements

## Create table

```
local Table = TableLib.CreateTable(
	UDim2.new(), 
	{
		X = 10,	-- columns
		Y = 10	-- rows
	}
)
```

## Edit table content

access to elements is:
```
Table.Data[Row][Column]: Frame
```


## Delete table

Just delete table.Container

```
Table.Container:Destroy()
Table = nil
```

or if you lazy you can use:

```
TableLib.DeleteTable(Table)
```
