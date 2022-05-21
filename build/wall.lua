---PARAMETER:---
function set_parameter()
    fuel_value = 80--Kohle Value
    maxFuel = turtle.getFuelLimit()--20.000 Bei normalen Turtles
    height = 0
    minFuelAmount = 200
    maxMinFuelAmount = 5000
    coal_string = "coal"
    chest_string = "chest"
    enderchest_string = "enderstorage:ender_storage"
    comming_from = "back"--Letzte Richtung aus der Die Turtle gekommen ist["back","forward","up","down"]
    stone_string = "minecraft:stone"
    cobblestone_string = "minecraft:cobblestone"
    cobblestone_deepslate_string = "quark:cobbled_deepslate"
    maxCobblestone = 64--Frei Konfigurierbar
    inventar_counter_cobblestone = 0
    saved_blocks_array = {}
    turtle.select(1)
    polished_deepslate_str = item_detail.name
    --building_block_obj wird in input dialog gesetzt
end

---DIALOG:---
function input_dialog()
    repeat
        print("Platzieren Sie den Baublock im ersten Slot und drücken Sie danach ENTER")
        read()
        building_block_obj = turtle.getItemDetail(1)
    until building_block_obj ~= nil
    print("Bitte geben Sie folgende Daten ein..")
    length = tonumber(dialog_einzelne_xyz_eingabe("Länge"))
    heigth = tonumber(dialog_einzelne_xyz_eingabe("Höhe"))
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
    --Startet über den ersten zu platzierenden Block
    select_block = select_item(building_block_objs.name)
    local i = 1
    while i <= heigth do
        i = i + 1
        --TODO MUST!!


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

function select_item(item, find_string)
    --sucht gibt in einer table alle Slots wieder, wo das Item gefunden wird.
    local slot_table = {}
	for i_select = 1 , 16 , 1 do
        local item_data = turtle.getItemDetail(i_select)
        if item_data ~= nil then--Diese Abfrage wird benötigt, weil bei einer ".name" abfrage von nil das Programm stirbt
            if find_string == true then
                if string.find(item_data.name, item) == true
                    table.insert(slot_table, i_select)
                end
            elseif item_data.name == item then
                table.insert(slot_table, i_select)
            end
            
        end
    end
    return slot_table
end

function start_position()
    force_move("up")
    force_move("forward")
end

function force_move(direction)
    if direction == "up" then
        --Gravel-Schutz Script:
        if turtle.up() == false then
            repeat
                turtle.attackUp()
                if turtle.detectUp() == true then
                    counter_cobblestone("up")
                    turtle.digUp()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.up() == true

        end
        comming_from = "down"

    elseif direction == "down"
        --Runter:
        --Gravel-Schutz Script:
        if turtle.down() == false then
            repeat
                turtle.attackDown()
                if turtle.detectDown() == true then
                    counter_cobblestone("down")
                    turtle.digDown()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.down() == true
            
        end
        comming_from = "up"

    elseif direction == "forward" then
        --Gravel-Schutz Script:
        if turtle.forward() == false then
            repeat
                turtle.attack()
                if turtle.detect() == true then
                    counter_cobblestone("forward")
                    turtle.dig()
                end
                sleep(0.25)  -- small sleep to allow for gravel/sand to fall.
            until turtle.forward() == true

        end
        comming_from = "back"

    else
        print("ERROR: False force move string.")
    end
end

function github_update()
    shell.run("proxy/update.lua")
end

---!!!Start:!!!---
github_update()
input_dialog()
set_parameter()
start_position()
build()
print("Done!")