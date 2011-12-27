
def show_current_dir_line dir
        puts "= dir: #{dir} ="
end

def default_dir_action dir
        dirs = dirs_in_pth(dir)
        pp_list(`for dir in \`ls -d #{dir}/*/ 2> /dev/null\`; do echo \`basename $dir\` "("\`find $dir -type f | wc -l\`")" ; done`.split("\n"), 
                'Dirs')
        pp_list(files_in_pth(dir), "Files")
end

def do_what_i_say_in_dir dir
        puts "\n--- DIR ---\n"
        print "What to do:"
        act = char_gets

        if bindings.key? act
                cmd = bindings[act]

                if is_dir_cmd cmd 
                        send cmd, dir
                end

                if is_global_cmd cmd
                        send cmd, dir, :dir
                end
        end
        goto_dir_mode dir
end

         
