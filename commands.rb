dir_cmd :go_upper_dir do |dir|
        goto_dir_mode ex_pth(fjoin(dir, '..')) 
end

dir_cmd :rnd_file_in_dir do |dir|
        if !files_in_pth(dir).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode dir
        end
end

file_cmd :rm_file_and_go_rnd do |file|
        File::unlink(file)
        if !files_in_pth(dir = File.dirname(file)).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode File.dirname(file)
        end
end

file_cmd :edit_file do |file|
        system "vim #{file}"
        goto_file_mode file
end

dir_cmd :edit_new_file_with_next_name do |dir|
        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        FileUtils::touch(pth)
        system "vim #{pth}"
        goto_file_mode pth
end

dir_cmd :edit_new_file_with_user_name do |dir|
        clear
        print "Enter file name: "
        name = gets.chomp
        pth = fjoin(dir, name)        
        FileUtils::touch(pth)
        system "vim #{pth}"
        goto_file_mode pth
end

file_cmd :copy_edit_and_return do |file|
        # copy-edit-return
        clear
        puts "Copy-Edit-Return"
        print "Enter dest directory: "
        name = gets.chomp
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        pth = ex_pth(fjoin(dirname(file), name))
        dir = dirname(pth)
        FileUtils::mkdir_p(dir)
        FileUtils::cp(file, pth)
        system "vim #{pth}"
        goto_file_mode file
end

file_cmd :move_and_return_to_rnd do |file|
        clear
        dir = dirname(file)
        puts "Move ->  Return-to-random"
        print "Enter dest directory: "
        name = gets.chomp
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        dest_dir = ex_pth(fjoin(dir, name))
        dest_pth = fjoin(dest_dir, find_next_num_in_dir(dest_dir).to_s)
        FileUtils::mkdir_p(dest_dir)
        safe_mv(file, dest_pth)

        rnd_file_in_dir dir
end

file_cmd :move_edit_and_return_to_rnd do |file|
        clear
        dir = dirname(file)
        puts "Move -> Edit -> Return-to-random"
        print "Enter dest directory: "
        name = gets.chomp
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        dest_dir = ex_pth(fjoin(dir, name))
        dest_pth = fjoin(dest_dir, find_next_num_in_dir(dest_dir).to_s)
        FileUtils::mkdir_p(dest_dir)
        safe_mv(file, dest_pth)
        system "vim #{dest_pth}"

        rnd_file_in_dir dir
end

global_cmd :quit do 
        puts " " 
        exit
end

dir_cmd :select_and_goto_dir do |dir|
        dirs = dirs_in_pth dir
        return if dirs.empty?

        clear
        num = 0
        arr = []

        dirs.each_index do |i|
                arr.push " #{i+1}: #{dirs[i]}"
        end 

        pp_list arr, "= Select dir in #{dir} ="
        t = gets.chomp
        return unless t =~ /^[0-9]+$/
        num = t.to_i - 1
        goto_dir_mode fjoin(dir, dirs[num])
end

dir_cmd :select_and_goto_file do |dir|
        files = files_in_pth(dir)
        return if files.empty?
        clear
        num = 0
        pp_list files.each_index.map{|i| " #{i+1}: #{files[i]}"}, "= Select file in #{dir} ="
        t = gets.chomp
        return unless t =~ /^[0-9]+$/
        num = t.to_i - 1
        goto_file_mode fjoin(dir, files[num])
end

dir_cmd :create_dir_with_user_name do |dir|
        clear
        print "Enter dir name: "
        name = gets.chomp
        FileUtils::mkdir(dir = fjoin(dir, name))
        goto_dir_mode dir
end

global_cmd :go_home do
        goto_dir_mode ex_pth(rc("default_dir"))
end

global_cmd :show_help do |pth, mode|
        clear
        # show doc here
        char_gets
end

global_cmd :next_itm do |pth, mode|
        if mode == :file
                dir = dirname(pth)
                files = files_in_pth(dir)
                filename = basename(pth)
                files.each_cons(2) do |element, next_element|
                        if(element == filename)
                                goto_file_mode ex_pth(fjoin(dir, next_element))
                        end
                end
        elsif mode == :dir
                files = files_in_pth(pth)
                goto_file_mode ex_pth(fjoin(pth, files.first))
        end
end

global_cmd :prev_itm do |pth, mode|
        if mode == :file
                dir = dirname(pth)
                files = files_in_pth(dir)
                filename = basename(pth)
                files.each_cons(2) do |element, next_element|
                        if(next_element == filename)
                                goto_file_mode ex_pth(fjoin(dir, element))
                        end
                end
        elsif mode == :dir
                files = files_in_pth(pth)
                goto_file_mode ex_pth(fjoin(pth, files.last))
        end
end

global_cmd :from_clipboard_to_new_file do |pth, mode|
        title "Создать новый файл из содержимого буфера обмена"
        dir = pth
        dir = dirname(pth) if mode == :file

        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        FileUtils::touch(pth)
        system "xclip -o > #{pth}"
        system "vim #{pth}"
        goto_file_mode pth
end

file_cmd :goto_current_dir do |file|
        title "Переход из режима файла - в режим каталога"
        goto_dir_mode dirname(file)
end

file_cmd :move_file_subdir do |file|
        title "Перенос файла в подкаталог"
        dir = dirname(file)
        clear
        if dest = dmenu(dirs_in_pth(dir))
                safe_mv(file, fjoin(dir, dest))
                if rnd = random_file_in(dir)
                        goto_file_mode rnd
                else
                        goto_dir_mode dir
                end
        end
end

file_cmd :move_file_upsubdir do |file|
        title "Перенос файла в соседний-родительский каталог"
        dir = ex_pth(fjoin(dirname(file), '..'))
        clear
        if dest = dmenu(dirs_in_pth(dir))
                safe_mv(file, fjoin(dir, dest))
                if rnd = random_file_in(dirname(file))
                        goto_file_mode rnd
                else
                        goto_dir_mode dirname(file)
                end
        end
end

global_cmd :goto_random_in_default_dir do 
        random_files = `find #{default_dir}/* -type f | sort -R`.split "\n"
        goto_file_mode random_files.first
end

dir_cmd :git_add_clear_and_autocommit do |dir|
        clear
        puts system("cd #{dir}; git add .; /home/waserd/.db/bin/stable/git-clear; /home/waserd/.db/bin/git-autocommit; git push")
        char_gets
end

dir_cmd :goto_prj_file do |dir|
        goto_file_mode ex_pth(fjoin(dir, '.prj'))
end

file_cmd :hide_file do |file|
        dir = dirname(file)
        name = basename(file)
        dest_pth = fjoin(dir, ".#{name}")
        #FileUtils::mkdir_p(dest_dir)
        safe_mv(file, dest_pth)
        rnd_file_in_dir dir
end
