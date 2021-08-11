
class Chat
    def initialize(emisor, receptor, userReceptor)
        @emisor = emisor["client"]
        @userEmisor = emisor["user"]
        @receptor = receptor
        @userReceptor = userReceptor
    end

    def chatear
        t1 = Thread.new {
            while msj = @emisor.gets do
                @receptor.puts("#{@userEmisor}: #{msj.chop}")
            end
        }
        t1.join

        t2 = Thread.new {
            while msj1 = @receptor.gets do
                @emisor.puts("#{@userReceptor}: #{msj1.chop}")
            end
        }
        t2.join

    end
    
end