@flash_messages = {:error => [], :success => []}
def print_flash_messages 
        unless @flash_messages[:error].empty? and @flash_messages[:success].empty?
                nl
                nl
                if @flash_messages[:error]
                        @flash_messages[:error].each do |v|
                                puts " ".white_on_red + " " + v
                        end
                end
                if @flash_messages[:success]
                        @flash_messages[:success].each do |v|
                                puts " ".black_on_green + " " + v
                        end
                end
        end
        @flash_messages = {:error => [], :success => []}
end

def flash type, text
        @flash_messages[type].push text
end

def flash_s text
        flash :success, text
end

def flash_e text
        flash :error, text
end
