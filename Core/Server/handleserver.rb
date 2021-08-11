require 'json'
require 'digest'
require './Core/Client/cliente'

class HandleServer
    def initialize
        @option = 1
        @screenName = ""
        @password = ""
        @serverLocation = "./data/servers.json"
        @onlineLocation = "./data/online.json"
        @contLogin = 0
        # showOptions()
    end

    def showOptions       
        while @option != "3"
            puts "1. Login"
            puts "2. Sign up"
            puts "3. Salir"
            print "Seleccione una opción: "
            @option = gets.chomp
            # if @option.to_i == 1 || @option.to_i == 2
            if @option == "3"
                if @contLogin > 0
                    puts "---SESIÓN CERRADA---"
                    delOnline()
                end
            else
                if @option == "1"
                    puts "---INICIAR SESIÓN---"
                    screenName()
                    password()
                    exe()
                elsif @option == "2"
                    puts "---REGISTRARSE---"
                    screenName()
                    password()
                    exe()
                else
                    puts "Ingrese una opción correcta"
                end
                
            end
        end
    end

    def screenName
        print "Ingrese su screen-name: "
        @screenName = gets.chomp
    end

    def password
        @password2 = ''
        print "Ingrese su contraseña: "
        @password = gets.chomp
        if @option == "2"
            while @password2 != @password
                print "Repite la contraseña: "
                @password2 = gets.chomp
                if @password2 != @password
                    puts "Contraseñas no coinciden, repítala de nuevo"
                end
            end
        end

        @password = Digest::SHA1.hexdigest @password
    end

    def exe
        # @option == "1" ? login(): signUp()
        if @option == "1"
            lg, srv = login()
            if lg
                putOnline(srv)
            else
                puts "El usuario y/o contraseña están incorrectos"
            end
        else
            signUp()
        end
    end

    def login
        @contLogin += 1
        data = getJson(@serverLocation)

        data.each do |srv|
            if srv["screenname"] == @screenName && srv["password"] == @password
                puts "Bienvenido, #{srv["screenname"]}!"
                # putOnline(srv["id"])
                return true, srv["screenname"]
                # break
            end
        end

        return false
        # puts "El usuario y/o contraseña están incorrectos"
    end

    def signUp
        data = {
                    "id" => "#{Digest::SHA1.hexdigest([Time.now, rand].join)}", 
                    "screenname" => @screenName, 
                    "password" => @password
                }
        data2 = getJson(@serverLocation)

        if existe(data["screenname"], data2)
            puts "El usuario con el screen-name '#{@screenName}' no fue registrado porque ya existe"
        else
            data2.push(data)
            File.open("./data/servers.json", "w") do |f|
                f.write(JSON.pretty_generate(data2))
            end
        end
    end

    def getJson(location)
        return JSON.load(File.open(location, "r"))
    end

    def existe(screenName, data)
        # data = getJson()
        data.each do |srv|
            if srv["screenname"] == screenName
                return true
                break
            end
        end

        return false
    end

    def putOnline(srv)
        data = getJson(@onlineLocation)
        dt = {"srv" => srv, "token" => Digest::SHA1.hexdigest([Time.now, rand].join)}
        data.push(dt)
        File.open("./data/online.json", "w") do |f|
            f.write(JSON.pretty_generate(data))
        end

        Cliente.new('localhost', 2000, dt["srv"]).iniciar
    end

    def delOnline
        data = getJson(@onlineLocation)
        data2 = []
        data.each do |server|
            if server["srv"] != @screenName
                data2.push(server)
            end
        end

        File.open("./data/online.json", "w") do |f|
            f.write(JSON.pretty_generate(data2))
        end
    end

    def delOnline2(token)
        data = getJson(@onlineLocation)
        data2 = []
        data.each do |server|
            if server["token"] != token
                data2.push(server)
            end
        end

        File.open("./data/online.json", "w") do |f|
            f.write(JSON.pretty_generate(data2))
        end
    end

    def getOnlineLocation
        return @onlineLocation
    end

    def getServerLocation
        return @serverLocation
    end

    def getTimeLocation
        return "./data/configtime.json"
    end
end

