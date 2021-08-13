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
        @semaphore = Mutex.new
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

    def chat(emisor, receptor, client, usr)
        Thread.kill(@escucha)
        socketEmisor = emisor["socket"]
        userEmisor = emisor["user"]
        socketReceptor = receptor["socket"]
        userReceptor = receptor["user"]
        msj = ''
        msj1 = ''

        puts("Chat iniciado entre #{userEmisor} y #{userReceptor}...")

        
        socketEmisor.puts("<=== Chat con '#{userReceptor}' ===>\n")
        socketReceptor.puts("<=== Chat con '#{userEmisor}' ===>\n")
        # @a = Thread.start {
        loop {

            puts("msj -> #{msj.chop}")
            puts("msj1 -> #{msj1.chop}")

            if msj.chop == "\\c" or msj1.chop == "\\c"
                break           
            end

            @escucha1 = Thread.new {
                
                while msj = socketEmisor.gets do
                    if msj.chop == "\\c"
                        socketEmisor.puts("Ha finalizado el chat con #{userReceptor}...")
                        socketEmisor.puts("Ingrese comandos nuevamente")
                        socketReceptor.puts("#{userEmisor} ha salido del chat...")
                        break
                    else
                        socketReceptor.puts("#{userEmisor}: #{msj.chop}")
                    end
                end

            }
            
            
                
            @escucha2 = Thread.new {

                while msj1 = socketReceptor.gets do
                    if msj1.chop == "\\c"
                        socketEmisor.puts("#{userReceptor} ha salido del chat")
                        socketEmisor.puts("Ingrese comandos nuevamente")
                        break
                    else
                        socketEmisor.puts("#{userReceptor}: #{msj1.chop}")
                    end
                end

            }

            @escucha1.join
            # @escucha2.join

        }

        @request = "-"
        puts "fin 133"
        Thread.kill(@escucha1)
        @escucha1.join
        puts "fin 137"
        Thread.kill(@escucha2)
        @escucha2.join
        puts "fin 139"
        escucharComandos(client, usr, 1, false, "-") 
        puts "fin 141"
        
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

    def escucharComandos(client, usr, var, ya, request)
        # Thread.kill(@escucha1)
        # Thread.kill(@escucha2)
        if var == 1
            Thread.kill(@escucha1)
            Thread.kill(@escucha2)
        end
        @request = request
        # ya = false
        loop {

            if ya == true
                @escucha.join
                Thread.kill(@escucha)
                chat(
                    {
                        "socket" => client, 
                        "user" => usr["srv"]
                    },
                    {
                        "socket" => @sockets[obtenerPos(@online, user)], 
                        "user" => obtenerNom(@online, @online.index(user))
                    }, client, usr
                )
            end
            if @request == "\\q"
                Thread.kill(@con)
                break
            end
            @escucha = Thread.new {
                #while @request != "\\q" and @request = client.gets do # while true # @request != "\\q" and @request = client.gets

                    @request = client.gets
                    @request = @request.chop #client.recv(512).chomp

                    case @request
                        when "\\h"
                            client.puts(comandosDisponibles())
                        when "\\u"
                            # client.puts(usuariosEnLinea())
                            users = usuariosEnLinea()
                            if users.length == 0
                                client.puts("No hay usuarios en línea")
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
                            nuevoTiempo = @request.split(/\s+/)[1] # @request.split(" ")[1]
                            File.open("./data/configtime.json", "w") do |f|
                                f.puts(JSON.pretty_generate({"time" => nuevoTiempo.to_i}))
                            end
                            setTiempoN()
                            client.puts("Tiempo de espera actualizado a #{nuevoTiempo} segundos")
                        when /^\\c\s+([a-zA-Z_\.]+[0-9]*?)+$/
                            user = @request.split(/\s+/)[1]
                            if user != usr["srv"]
                                if isOnline(user)
                                    receptor = @sockets[obtenerPos(@online, user)]
                                    emisor = @sockets[obtenerPos(@online, usr["srv"])]
                                    puts("#{usr["srv"]} quiere chatear con #{user}...")
                                    ya = true
                                    # c1 = Thread.new {
                                        receptor.puts("Aceptas la invitación a chatear de #{usr["srv"]}?")
                                    # receptor.puts("Presiona '\\c #{usr["srv"]}' para aceptar\nPresiona 2 para denegar")
                                        receptor.puts("*Presiona 1 para aceptar\n*Presiona 2 para denegar\n")
                                        choice = receptor.gets
                                        case choice.to_i
                                        when 1
                                            ya = true
                                            chat(
                                                {
                                                    "socket" => client, 
                                                    "user" => usr["srv"]
                                                },
                                                {
                                                    "socket" => @sockets[obtenerPos(@online, user)], 
                                                    "user" => obtenerNom(@online, @online.index(user))
                                                }, client, usr
                                            )
                                        when 2
                                            client.puts("Lo sentimos, #{user} ha rechazado la invitación") # emisor.puts("Lo sentimos, #{usr["srv"]} ha rechazado la invitación")
                                        else
                                            client.puts("Opción incorrecta. Vuelva pronto") # emisor.puts("Opción incorrecta. Vuelva pronto")
                                        end
                                    # }
                                    # c1.join
                                    puts "terminado"
                                    # ya = false
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
                            # evaluarOnline()
                            # client.puts("tokenizador8080:#{1}")
                            
                            # @server.close
                        else
                            begin
                                client.puts("Comando desconocido")
                            rescue
                                puts ""
                            end
                    end
                    
                #end ## FIN DEL WHILE
            }
            @escucha.join
            escucharComandos(client, usr, 0, ya, @request)
        }
        conectar()
    end

    def conectar
        if usuariosEnLinea().length == 0
            print "Esperando conexión...\n"
        end
        ya = false

        con = 0
        usuariosEnLineaN = usuariosEnLinea.length()
        loop {
        # while con == 1           
        @con = Thread.start(@server.accept) do |client|
                @sockets.push(client)
                usr = getUsuarioEnLinea()
                @online.push(usr["srv"])
                con += 1
                print "Conexión establecida con #{usr["srv"]}...\n"

                escucharComandos(client, usr, 0, false, "-")
            end # end.join
        }
        # end
        @server.close
        puts "Conexión cerrada"
    end
end



