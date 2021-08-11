require './Core/Server/handleserver'
require './Core/Chat/chat'
require 'json'
require 'socket'      

class Server
    def initialize(port)
        @port = port
        @sockets = []
        @online = []
        @time = getTiempoN() ####
        
        @server = abrirServidor()
        # conectar()
    end

    def evaluarOnline
        if usuariosEnLinea().length == 0
            @server.close
            Thread.kill(@t)
            @server = abrirServidor()
        end
    end

    def abrirServidor
        return TCPServer.open(@port) # TCPServer.new
    end

    def usuariosEnLinea
        h1 = HandleServer.new
        data = h1.getJson(h1.getOnlineLocation())
        return data
    end

    def getUsuarioEnLinea
        user = HandleServer.new
        data = user.getJson(user.getOnlineLocation())
        return data[data.length - 1]
    end

    def borrarEnLinea(token)
        h1 = HandleServer.new
        h1.delOnline2(token)
    end

    def getTiempoN
        tn = HandleServer.new
        time = tn.getJson(tn.getTimeLocation())
        return time["time"]
    end

    def setTiempoN
        @time = getTiempoN()
    end

    def isOnline(usr)
        users = usuariosEnLinea()
        users.each do |onl|
            if onl["srv"] == usr
                return true 
            end
        end
        return false
    end

    def obtenerPos(arreglo, busqueda)
        return arreglo.index(busqueda)
    end

    def obtenerNom(arreglo, indice)
        return arreglo[indice]
    end

    def comandosDisponibles
        return "
            \\h: Muestra la ayuda de los comandos que están disponibles \n
            \\u: Muestra los usuarios que están en línea en el server \n
            \\c <ScreenName>: Abre un chat con el usuario con <ScreenName> especificado \n
            \\c: Cierras el chat que ya está abierto \n
            \\p: Muestra una lista de los mensajes pendientes \n
            \\n <tiempo>: Establece a <tiempo> segundos cada cuanto se envía la notificación de mensajes \n
            \\n: Muestra el tiempo en segundos en el que se envía la notificación de mensajes pendientes \n
            \\q: Cerrar sesión
        "
    end

    def conectar
        print "Esperando conexión...\n"
        ya = false

        con = 0
        usuariosEnLineaN = usuariosEnLinea.length()
        loop {
        # while con == 1           
            Thread.start(@server.accept) do |client|
                @sockets.push(client)
                usr = getUsuarioEnLinea()
                @online.push(usr["srv"])
                con += 1
                print "Conexión establecida con #{usr["srv"]}...\n"
                # client.puts("Conexión establecida - #{Time.now.ctime}\n")
                # client.write("usrAct8080:#{getUsuarioEnLinea()["srv"]}")
                request = "-"
                while request != "\\q" and request = client.gets do # while true
                    request = request.chop #client.recv(512).chomp
                    case request
                        when "\\h"
                            client.puts(comandosDisponibles())
                        when "\\u"
                            # client.puts(usuariosEnLinea())
                            users = usuariosEnLinea()
                            if users.length == 0
                                clien.puts("No hay usuarios en línea")
                            else
                                # client.puts("Los usuarios en línea son: \n")
                                users.each do |onl|
                                    client.puts("- #{onl["srv"]}\n")
                                end
                            end
                        when "\\n"
                            client.puts("#{getTiempoN()}")
                        when "\\p"
                            client.puts("Se mostrarán los mensajes pendientes")
                        when /^\\n\s+[0-9]+$/ # /^\\n\s[0-9]+$/
                            nuevoTiempo = request.split(/\s+/)[1] # request.split(" ")[1]
                            File.open("./data/configtime.json", "w") do |f|
                                f.puts(JSON.pretty_generate({"time" => nuevoTiempo.to_i}))
                            end
                            setTiempoN()
                            client.puts("Tiempo de espera actualizado a #{nuevoTiempo} segundos")
                        when /^\\c\s+([a-zA-Z_\.]+[0-9]*?)+$/
                            user = request.split(/\s+/)[1]
                            if user != usr["srv"]
                                if isOnline(user)
                                    receptor = @sockets[obtenerPos(@online, user)]
                                    emisor = @sockets[obtenerPos(@online, usr["srv"])]
                                    ya = true
                                    c1 = Thread.new {
                                        receptor.puts("Aceptas la invitación a chatear de #{usr["srv"]}?")
                                    # receptor.puts("Presiona '\\c #{usr["srv"]}' para aceptar\nPresiona 2 para denegar")
                                        receptor.puts("*Presiona 1 para aceptar\n*Presiona 2 para denegar\n")
                                        # choice = "-"
                                        # loop {break if choice = receptor.gets}
                                        choice = receptor.gets
                                        case choice.to_i
                                        when 1
                                            client.puts("<=== Chat con '#{user}' ===>\n")
                                            loop {
                                                Chat.new(
                                                    {"client" => client, "user" => usr["srv"]}, 
                                                    @sockets[obtenerPos(@online, user)],
                                                    obtenerNom(@online, @online.index(user))
                                                ).chatear
                                            }
                                        when 2
                                            client.puts("Lo sentimos, #{usr["srv"]} ha rechazado la invitación") # emisor.puts("Lo sentimos, #{usr["srv"]} ha rechazado la invitación")
                                        else
                                            client.puts("Opción incorrecta. Vuelva pronto") # emisor.puts("Opción incorrecta. Vuelva pronto")
                                        end
                                    }
                                    c1.join
                                    puts "terminado"
                                    ya = false
                                else
                                    client.puts("El usuario '#{user}' no está en línea")
                                end
                            else
                                client.puts("No puedes chatear contigo mismo")
                            end
                        when "\\c"
                            client.puts("Debes tener un chat abierto con otro cliente")
                        when "\\q"
                            print "#{usr["srv"]} se ha ido...\n"
                            borrarEnLinea(usr["token"])
                            usuariosEnLineaN = usuariosEnLinea().length
                            client.puts("Bye")
                            evaluarOnline()
                            # client.puts("tokenizador8080:#{1}")
                            
                            # @server.close
                        else
                            client.puts("")
                    end
                end
            end # end.join
        }
        # end
        @server.close
        puts "Conexión cerrada"
    end
end



