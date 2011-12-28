def show_current_file_line file
        puts "= file: #{file} =\n".green
end

def default_file_action file
        if(File.exists?(file))
                if(File.size(file) == 0)
                        puts "File empty".red
                else
                        puts r_file file
                end
        else
                puts "File not exists".red
        end
end

def do_what_i_say_in_file file
        print "\nWhat to do( DerucmMaN):".green
        act = char_gets
        dir = dirname file

        if bindings.key? act
                cmd = bindings[act]
                if is_global_cmd cmd
                        send cmd, file, :file
                end

                if is_dir_cmd cmd 
                       send cmd, dir
                end

                if is_file_cmd cmd 
                       send cmd, file
                end
        end
        goto_file_mode file
end


