dir_cmd :git_add_clear_and_autocommit do |dir|
        clear
        puts system("cd #{dir}; git add .; /home/waserd/.db/bin/stable/git-clear; /home/waserd/.db/bin/git-autocommit; git push")
        char_gets
end

doc <<EOF
Начать редактировать .dairy файл

В этом файле надо хранить журнал проектных решений - 
что было принято и почему
EOF
dir_cmd :goto_dairy_file do |dir|
        edit_file fjoin(dir, '.dairy').ex
end

doc <<EOF
Начать редактировать .prj файл

Содержимое этого файла всегда показывается в просмотре каталога.
В этом файле надо держать цель каталога и заметки, что важно держать
перед глазами
EOF
dir_cmd :goto_prj_file do |dir|
        edit_file fjoin(dir, '.prj').ex
end

doc "Перейти к первому подкаталогу"
dir_cmd :goto_subdir_1 do |dir|
        dirs = dirs_in_pth dir
        return if dirs.empty?
        goto_dir_mode fjoin(dir, dirs.first)
end

doc "Перейти ко второму подкаталогу"
dir_cmd :goto_subdir_2 do |dir|
        dirs = dirs_in_pth dir
        return if dirs.empty?
        goto_dir_mode fjoin(dir, dirs[1])
end

doc "Перейти к третьему подкаталогу"
dir_cmd :goto_subdir_3 do |dir|
        dirs = dirs_in_pth dir
        return if dirs.empty?
        goto_dir_mode fjoin(dir, dirs[2])
end

doc "Выбрать и перейти в подкаталог"
dir_cmd :select_and_goto_dir do |dir|
        dirs = dirs_in_pth dir
        return if dirs.empty?

        clear
        num = 0
        arr = []

        return unless (dest = dmenu(dirs, "= Select dir in #{dir} ="))
        goto_dir_mode fjoin(dir, dest)
end

doc "Выбрать и перейти к файлу"
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


doc "Создаёт пустой файл и открывает на нём редактор"
dir_cmd :edit_new_file_with_next_name do |dir|
        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        FileUtils::touch(pth)
        system "#{editor} #{pth}"
        goto_file_mode pth
end

doc "Создаёт пустой файл и открывает на нём редактор"
dir_cmd :new_file_with_user_input_with_next_name do |dir|
        clear
        print "Write: ".green
        txt = gets.chomp
        return if txt.empty?
        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        w_file pth, txt
        goto_file_mode pth
end

dir_cmd :edit_new_file_with_user_name do |dir|
        clear
        print "Enter file name: ".green
        name = gets.chomp
        pth = fjoin(dir, name)        
        FileUtils::touch(pth)
        system "#{editor} #{pth}"
        goto_file_mode pth
end

doc "Перейти на каталог выше"       
dir_cmd :go_upper_dir do |dir|
        goto_dir_mode fjoin(dir, '..').ex 
end

doc "Перейти к случайному файлу в текущем каталоге"
dir_cmd :rnd_file_in_dir do |dir|
        if !files_in_pth(dir).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode dir
        end
end

doc "Выполнить shell команду и посмотреть вывод"
dir_cmd :shell_command do |dir|
        clear
        print "$ ".green
        system "cd #{dir.esc} ; #{gets.chomp} | #{pager}"
end

doc "Поиск слова по файлам"
dir_cmd :search_word_in_dir do |dir|
        clear
        print "Search word: ".green
        system "cd #{dir.esc} ; grep --color=always -ni #{gets.chomp.esc} * | #{pager}"
end

doc "Поиск слова по файлам рекурсивно"
dir_cmd :search_word_in_dir_r do |dir|
        clear
        print "Search word recursive: ".green
        system "cd #{dir.esc} ; grep --color=always -nri #{gets.chomp.esc} * | #{pager}"
end

doc "Переносит все файлы из папки later - в текущий каталог"
dir_cmd :unlater_all_files do |dir|
        `find #{fjoin(dir, 'later').esc}/* -maxdepth 0 -type f`.chomp.split("\n").each do |v|
                mv_to_dir(v, dir)
        end
end

doc "Переименовывает все файлы в каталоге по номерам"
dir_cmd :renumerate_files do |dir|
        system "cd #{dir.esc}; renumerate"
end

dir_cmd :fetch_notice do |dir|
        system "cd #{dir.esc}; fetch-notice"
end

