---PARAMETER:---
function set_parameter()
    fuel_value = 80--Kohle Value
    maxFuel = turtle.getFuelLimit()--20.000 Bei normalen Turtles
    height = 0
    minFuelAmount = 200
    maxMinFuelAmount = 5000
    coal_string = "minecraft:coal"
    chest_string = "minecraft:chest"
    chest_maple_string = "autumnity:maple_chest"
    enderchest_string = "enderstorage:ender_storage"
    comming_from = "back"--Letzte Richtung aus der Die Turtle gekommen ist["back","forward","up","down"]
    stone_string = "minecraft:stone"
    cobblestone_string = "minecraft:cobblestone"
    cobblestone_deepslate_string = "minecraft:cobbled_deepslate"
    maxCobblestone = 64--Frei Konfigurierbar
    inventar_counter_cobblestone = 0
    saved_blocks_array = {}
    polished_deepslate_str = "quark:polished_deepslate"
end

---DIALOG:---
function input_dialog()
    --Mining oder building?
    a_mode = 0
    print("1.Bridge or 2.Tower?")
    while a_mode ~= 1 and a_mode ~= 2 do
        a_mode = tonumber(dialog_einzelne_xyz_eingabe(":"))
    end
    
    --Wie tief,Breit,Hoch das zu minende Gebiet vor der Turtle
    print("Bitte geben Sie folgende Daten ein..")
    y_xyz = tonumber(dialog_einzelne_xyz_eingabe("Länge/Höhe"))
end
function dialog_einzelne_xyz_eingabe(xyz_string)
    local xyz = nil
    while tonumber(xyz) == nil or tonumber(xyz) == 0 do
        write(xyz_string..":")
        xyz = read()
        if tonumber(xyz) == 0 then
            print("Der Wert darf nicht null sein")
        end
        if tonumber(xyz) == nil then
            print("Bitte geben Sie die Daten in Zahlenformat ein.")
        end
    end
    return xyz
    
end

function build()
    select_block = select_item(polished_deepslate_str)
    local i = 1
    while i <= y_xyz do
        i = i + 1
        local block_found = false
        local block_detail_table = turtle.getItemDetail()
        while block_detail_table == nil or block_found == false do
            print("searching for blocks...")
            select_block = select_item(polished_deepslate_str)
            turtle.select(select_block[1])
            block_detail_table = turtle.getItemDetail()
            --This is disgusting...but might work.
            if block_detail_table ~= nil then
                if block_detail_table.name == polished_deepslate_str then
                    block_found = true
                end
            end
            
        end
        if a_mode == 1 then
            --Bridge
            if turtle.placeDown() == false then
                repeat
                    turtle.attackDown()
                    turtle.digDown()
                    sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
                until turtle.placeDown() == true
            end
            turtle.placeDown()
            turtle.forward()
        else
            --Tower
            if turtle.place() == false then
                repeat
                    turtle.attack()
                    turtle.dig()
                    sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
                until turtle.place() == true
            end
            turtle.place()
            turtle.up()
            
        end
    end
end

function select_item(item)
    --sucht gibt in einer table alle Slots wieder, wo das Item gefunden wird.
    local slot_table = {}
	for i_select = 1 , 16 , 1 do
        local item_data = turtle.getItemDetail(i_select)
        if item_data ~= nil then--Diese Abfrage wird benötigt, weil bei einer ".name" abfrage von nil das Programm stirbt
            if item_data.name == item then
                table.insert(slot_table, i_select)
            end
            
        end
    end
    return slot_table
end

function github_update()
    shell.run("proxy/update.lua")
end

---!!!Start:!!!---
github_update()
input_dialog()
set_parameter()
build()
print("Done!")