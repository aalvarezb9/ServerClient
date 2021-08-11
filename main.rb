require './Core/Server/server'
require './Core/Server/handleserver'
# require './Core/Client/cliente'



option = "1"
while option != "3"
    puts "1. Server"
    puts "2. Client"
    puts "3. Salir"
    print "Seleccione una opción: "
    option = gets.chomp
    if option == "1"
        Server.new(2000).conectar
    elsif option == "2" 
        HandleServer.new.showOptions
    elsif option == "3"
        puts "ADIÓS"
    else
        puts "Opción desconocida"
    end
end
