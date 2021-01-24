---!!!FUNCTIONS:!!!---

---PARAMETER:---
function set_parameter()
    fuel_value = 80--Kohle Value
    maxFuel = turtle.getFuelLimit()--20.000 Bei normalen Turtles
    height = 0
	minFuelAmount = 200
    selector_coal = 1 --Wenn auf Slot 1 nichts gefunden wird, wird durch die funktion select_coal() der Parameter select_coal angepasst
    --Direction wird benötigt um am Ende der Row anzugeben, ob sich rechts oder links bewegt werden soll:
    direction = 1 --1 steht für rechts und -1 für links
end

---DIALOG:---
function input_dialog()
    --Wie tief,Breit,Hoch das zu minende Gebiet vor der Turtle
    print("Bitte geben Sie folgende Daten ein..")
    x_xyz = dialog_einzelne_xyz_eingabe("Breite")
    y_xyz = dialog_einzelne_xyz_eingabe("Höhe")
    z_xyz = dialog_einzelne_xyz_eingabe("Tiefe")
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

---FUELING:---
function checker_fuel()
    --Dieser Code bezieht sich auf Kohle Energie
    local i_checker_fuel = 0
    while turtle.getFuelLevel() <= minFuelAmount do
        --Solange minFuelAmount nicht übertroffen wurde, wird diese Schleife wiederholt.
        if select_coal() ~= nil then
            --Wenn Kohle gefunden wurde
            while select_coal() ~= nil do
                --Es wird solange das inv geleert, bis maxFuel erreicht wurde oder keine Kohle mehr gefunden wurde
                --Zähler um zu wissen, ob es der erste Durchgang ist.
                i_checker_fuel = i_checker_fuel + 1
                
                slot_coal = select_coal()--Gibt einen Slot von Kohle wieder oder nil, wenn keine Kohle gefunden wurde.
                coal_amount = turtle.getItemCount(slot_coal)
                if i_checker_fuel == 1 then
                    --Bei dem ersten Durchgang, wird 1 Kohle übrig gelassen, damit immer ein Slot für Kohle freigehalten wird.
                    coal_amount = coal_amount - 1
                end
                -- Max Anzahl an Items beachten, um nicht mehr als max möglich zu fuelen:
                maxFuel_items = math.floor((maxFuel-turtle.getFuelLevel())/fuel_value)
                if coal_amount > maxFuel_items then
                    coal_amount = maxFuel_items
                end

                --Refuel:
                turtle.refuel(coal_amount)
            end

        else
            --Wenn keine Kohle gefunden wurde
            print("Keine Kohle gefunden. Bitte mit Kohle befüllen.")
            print("Drücken Sie ENTER, wenn sie Kohle eingeführt haben.")
            read()
        end
        
    end
    --Gefueled
    print("Turtle goes brrr")
end
function select_coal()
	--sucht und selected kohle
	--int select_coal ->siehe set_parameter()
	for i_select_coal = 1 , 16 , 1 do
		local item_data = turtle.getItemDetail(i_select_coal)
		if item_data.name == "minecraft:coal" then--PARAMETER
			return i_select_coal
			--Die For Schleife wird bei gefundener Kohle abgebrochen und select_kohle wird die Slotnummer mitgegeben, welche die Kohle beinhaltet.
		end
    end
    return nil
	
end

---MINING/MOVING:---
function route_mine()

    if  y_xyz > 0 then
        --Die eingegebene Höhe ist positiv und es muss als erste y_direction nach oben gegangen werden
        y_direction = 1
    else
        --Die eingegebene Höhe ist negativ und es muss als erste y_direction nach unten gegangen werden
        y_direction = -1
    end


    if x_xyz < 0 then
        x_forloop = math.abs(x_xyz) + 1

        --Die Breite gibt die Reihen links von der Turtle abzubauen.
        x_direction = -1
    else
        x_forloop = x_xyz

        --Die Breite gibt die Reihen rechts von der Turtle abzubauen.
        x_direction = 1
    end
    for i_x = 1 , x_forloop , 1 do
        --Die Breite, welche x ist, bestimmt wie viele Reihen gegangen werden.

        for i_z = 1 , z_xyz , 1 do
            --Die Tiefe, welche z ist, bestimmt wie weit eine Reihe gegangen wird.
            if i_z == 1 and i_x ~= 1 then
                --Erste Spalte der Reihe, welche nicht die erste ist, benötigt eine weitere Drehung, weil sich gerade erst in die Reihe von der Seite bewegt worden ist.
                turtle_turn(x_direction)
            end

            if y_xyz < 0 then
                y_forloop = math.abs(y_xyz) + 1
            else
                y_forloop = y_xyz
            end
            for i_y = 1 , y_forloop , 1 do
                --Die Höhe, welche y ist, bestimmt wie hoch oder tief in jedem Feld gegangen wird.
                
                --Bevor eine Bewegung gemacht wird, wird überprüft ob mehr Fuel als der minFuelAmount gegeben ist.
                checker_fuel()

                if i_y == 1 then
                    --Erster Durchgang wird gerade aus gegangen:
                    turtle.dig()
                    turtle.forward()
                else
                    --Es wird hoch oder runter gegangen
                    if y_direction == 1 then
                        --Hoch:
                        turtle.digUp()
                        turtle.up()
                        y_direction = -1
                    elseif y_direction == -1 then
                        --Runter:
                        turtle.digDown()
                        turtle.down()
                        y_direction = 1
                    end
                end
            end
        end
        if i_x ~= x_xyz then
            --Es wird sich in eine Richtung gedreht, damit die nächste Reihe gestertet werden kann.
            turtle_turn(x_direction)

        end
    end
end

function turtle_turn(direction)
    if direction == 1 then
        --turn rechts
        turtle.turnRight()
    elseif direction == -1 then
        --turn links
        turtle.turnLeft()
    end
end

function checker_inventory()
    --Checkt ob mindestens ein Slot frei ist.
    --Wenn keine Chest im Inventory ist, wird geprintet "Bitte entleeren sie das Inventar" oder so.

end

function chest_place()
    

end

--Start:
input_dialog()
set_parameter()
route_mine()
print("Ich habe getan!")