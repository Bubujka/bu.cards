
def show_current_dir_line dir
        puts "= dir: #{dir} =\n".green
end

def default_dir_action dir
        dirs = dirs_in_pth(dir)
        content = []
        colored_dirs = dirs.map do |v|
                pth = "#{dir}/#{v}"
                (v + " (" + `find #{pth.esc} -type f | wc -l`.chomp + ")")
        end
        content.push pp_list(colored_dirs, 'Dirs', true).
                gsub(/\([0-9]+\)/){|v| v.blue}.
                gsub(/_today/){|v| v.black_on_green}.
                chomp
        
        files = files_in_pth(dir)
        files_cnt = files.size
        if rc(:hide_todo_files)
                files.select! do |v|
                        !v.match(todo_file_pattern)
                end
        end

        if(files_cnt != files.size)
                content.push "Todo: " + (files_cnt - files.size).to_s.green + ' tasks'
        end

        if t = pp_list(files, "Files", true).chomp
                content.push t
        end

        puts content.hrify
end

def do_what_i_say_in_dir dir
        nl
        print "What to do: ".green
        print_flash_messages

        if cmd = get_cmd_from_user
                if is_dir_cmd cmd 
                        send cmd, dir
                end

                if is_global_cmd cmd
                        send cmd, dir, :dir
                end
        end
        goto_dir_mode dir
end
