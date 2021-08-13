
class Chat
    def initialize(emisor, receptor, userReceptor)
        @emisor = emisor["client"]
        @userEmisor = emisor["user"]
        @receptor = receptor
        @userReceptor = userReceptor
        @fin = false
        @msj = ''
        @msj1 = ''
    end

    def chatear
        @t1 = Thread.new {
            while @msj = @emisor.gets do
                # if @msj.chop == "\\c"
                    # @fin = true           
                # else
                @receptor.puts("#{@userEmisor}: #{@msj.chop}")
                    # puts @msj
                # end
                
            end
        }
        @t1.join

        @t2 = Thread.new {
            while @msj1 = @receptor.gets do
                # if @msj1.chop == "\\c"
                    # @fin = true         
                # else
                @emisor.puts("#{@userReceptor}: #{@msj1.chop}")
                    # puts @msj1
                # end
            end
        }
        @t2.join
        
        
    end
    
end