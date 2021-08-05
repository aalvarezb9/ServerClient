require './Core/Server/handleserver'
require 'json'
require 'socket'      

class Server
    def initialize(port)
        @port = port
        @server = abrirServidor()
    end

    def abrirServidor
        return TCPServer.new(@port)
    end

    def usuariosEnLinea
        h1 = HandleServer.new
        data = h1.getJson(h1.getOnlineLocation())
        return data
    end

    def getTiempoN
        tn = HandleServer.new
        time = tn.getJson(tn.getTimeLocation())
        return time["time"]
    end

    def comandosDisponibles
        return "
            \\h: Muestra la ayuda de los comandos que están disponibles \n
            \\u: Muestra los usuarios que están en línea en el server \n
            \\c <ScreenName>: Abre un chat con el usuario con <ScreenName> especificado \n
            \\p: Muestra una lista de los mensajes pendientes \n
            \\n <tiempo>: Establece a <tiempo> segundos cada cuanto se envía la notificación de mensajes \n
            \\n: Muestra el tiempo en segundos en el que se envía la notificación de mensajes pendientes \n
        "
    end

    def conectar
        print "Esperando conexión...\n"
        loop {                          
            Thread.start(@server.accept) do |client|
                print "Conexión establecida con #{client}\n"
                client.puts("Conexión establecida - #{Time.now.ctime}\n")
                while true do
                    request = client.recv(512).chomp
                    case request
                        when "\\h"
                            client.write(comandosDisponibles())
                        when "\\u"
                            # client.write(usuariosEnLinea())
                            users = usuariosEnLinea()
                            if users.length == 0
                                clien.write("No hay usuarios en línea")
                            else
                                client.write("Los usuarios en línea son: \n")
                                users.each do |onl|
                                    client.write("- #{onl["srv"]}\n")
                                end
                            end
                        when "\\n"
                            client.write("#{getTiempoN()}")
                        when "\\p"
                            client.write("Se mostrarán los mensajes pendientes")
                        else
                            client.write("Comando desconocido")
                    end
                end
            end
        }
    end
end

# Thread.start(@server.accept) do |client|
#     print "Conexión establecida con #{client}\n"
#     client.puts("Conexión establecida - #{Time.now.ctime}\n")
#     while line = client.gets
#         if line.chop == "h"
#             client.puts(comandosDisponibles())
#         end
#     end
#     @mensaje = ""
#     client.puts("Cerrando conexión...")
#     client.close       
# end

