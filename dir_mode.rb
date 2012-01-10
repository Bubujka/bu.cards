
def show_current_dir_line dir
        puts "= dir: #{dir} =\n".green
end

def default_dir_action dir
        dirs = dirs_in_pth(dir)
        colored_dirs = dirs.map do |v|
                (v + " (" + `find #{dir}/#{v} -type f | wc -l`.chomp + ")")
        end
        t = pp_list(colored_dirs, 'Dirs', true).gsub(/\([0-9]+\)/){|v| v.blue}.chomp
        puts t
        
        puts pp_list(files_in_pth(dir), "Files", true).chomp
end

def do_what_i_say_in_dir dir
        nl
        print "What to do:".green

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
