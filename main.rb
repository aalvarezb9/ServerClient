require './Core/Server/handleserver'


option = "1"
while option != "3"
    puts "1. Server"
    puts "2. Client"
    puts "3. Salir"
    print "Seleccione una opción: "
    option = gets.chomp
    if option == "1"
        HandleServer.new.showOptions()
    elsif option == "2"
        puts "Cliente"
    elsif option == "3"
        puts ""
    else
        puts "Opción desconocida"
    end
end

print "ADIÓS"