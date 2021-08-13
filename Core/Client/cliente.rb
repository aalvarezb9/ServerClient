require 'socket'  
# require 'json'    
# require './Core/Server/handleserver'
# require './handleserver'


# print "Ingrese una IP a la que se quiere conectar: "
# hostname = gets.chomp
# print "Ingrese un puerto por el que desea hacer la conexión: "
# port = gets.chomp

class Cliente
    def initialize(hostname, port, user)
        @hostname = hostname
        @port = port
        @user = user
        @s = conectarse()
        @msj = ''
        @usuarioEnLinea = ''
    end

    def iniciar
        t1 = Thread.new {
            loop {
                msj = gets.chomp
                enviar(msj)
            }
        }
        begin
            while line = @s.gets
                escuchar(line)
            end
        rescue
            puts "Conexión cerrada..."
        end
        # t1.join
        Thread.kill(t1)
    end

    def conectarse
        begin
            return TCPSocket.open(@hostname, @port)
        rescue
            puts "Error en la conexión, verifique el hostname(#{@hostname}) y el puerto(#{@port})"
            return nil
        end
    end

    def escuchar(line)
        if line.chop == "Bye"
            cerrar()    
        end
        puts line.chop      
    end

    def enviar(msj)
        # @msj = gets.chomp
        begin
            @s.puts(msj.strip)
        rescue
            puts ""
        end
    end

    def cerrar
        @s.close
    end
end

# puts "Conexión cerrada con '#{usuarioEnLinea}' - #{Time.now.ctime}"