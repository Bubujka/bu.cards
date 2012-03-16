file_cmd :copy_edit_and_return do |file|
        # copy-edit-return
        clear
        puts "Copy-Edit-Return"
        print "Enter dest directory: "
        name = gets.chomp
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        pth = fjoin(dirname(file), name).ex
        dir = dirname(pth)
        FileUtils::mkdir_p(dir)
        FileUtils::cp(file, pth)
        system "#{editor} #{pth}"
        goto_file_mode file
end

file_cmd :move_and_return_to_rnd do |file|
        clear
        dir = dirname(file)
        puts "Move ->  Return-to-random"
        print "Enter dest directory: "
        name = gets.chomp
        return if name.empty?
        
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        dest_dir = fjoin(dir, name).ex
        mv_to_dir file, dest_dir

        rnd_file_in_dir dir
end


file_cmd :move_edit_and_return_to_rnd do |file|
        clear
        dir = dirname(file)
        puts "Move -> Edit -> Return-to-random"
        print "Enter dest directory: "
        name = gets.chomp
        return if name.empty?
        
        # todo: если путь начинается с ~ - надо не джоинить его с директорией
        dest_dir = fjoin(dir, name).ex
        dest_pth = fjoin(dest_dir, find_next_num_in_dir(dest_dir).to_s)

        mv_to_file(file, dest_pth)
        system "#{editor} #{dest_pth.esc}"

        rnd_file_in_dir dir
end

doc "Удалить файл и перейти к случайному"
file_cmd :rm_file_and_go_rnd do |file|
        flash_s "Deleted: #{file.green}"
        File::unlink(file)
        if !files_in_pth(dir = File.dirname(file)).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode File.dirname(file)
        end
end

doc "Отредактировать файл в редакторе"
file_cmd :edit_file do |file|
        system editor, file
        goto_file_mode file
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
                mv_to_dir(file, t = fjoin(dir, dest))
                flash_s "File #{file.green} moved to #{t.green}"
                if rnd = random_file_in(dir)
                        goto_file_mode rnd
                else
                        goto_dir_mode dir
                end
        end
end

doc "Перенести файл в подкаталог относительно домашней директории"
file_cmd :move_file_homesubdir do |file|
        dir = home_dir
        clear
        if dest = dmenu(dirs_in_pth(dir))
                mv_to_dir(file, t = fjoin(dir, dest))
                flash_s "File #{file.green} moved to #{t.green}"
                if rnd = random_file_in(dirname(file))
                        goto_file_mode rnd
                else
                        goto_dir_mode dirname(file)
                end
        end
end

file_cmd :move_file_upsubdir do |file|
        title "Перенос файла в соседний-родительский каталог"
        dir = fjoin(dirname(file), '..').ex
        clear
        if dest = dmenu(dirs_in_pth(dir))
                mv_to_dir(file, t = fjoin(dir, dest))
                flash_s "File #{file.green} moved to #{t.green}"
                if rnd = random_file_in(dirname(file))
                        goto_file_mode rnd
                else
                        goto_dir_mode dirname(file)
                end
        end
end

doc "Скрыть файл"
file_cmd :hide_file do |file|
        dir = dirname(file)
        name = basename(file)
        dest_pth = fjoin(dir, ".#{name}")
        mv_to_file(file, dest_pth)
        rnd_file_in_dir dir
end

def move_to file, ddir
        dir = dirname(file)
        dest_dir = fjoin(dir, ddir)
        mv_to_dir(file, dest_dir)
        rnd_file_in_dir dir
end

file_cmd :move_to_complete do |file|
        move_to file, 'complete'
end

file_cmd :move_to_done do |file|
        move_to file, 'done'
end

file_cmd :move_to_later do |file|
        move_to file, 'later'
end

file_cmd :run_file_in_browser do |file|
        system browser, file
end

file_cmd :run_content_in_browser do |file|
        system browser, r_file(file)
end

file_cmd :pipe_file do |file|
        clear
        print "cat #{file.esc} | "
        system "cat #{file.esc} | #{gets.chomp} | #{pager}"
end

file_cmd :move_to_waiting do |file|
        move_to file, 'waiting'
end


doc "Запрашивает строку и заменяет её файл"
file_cmd :replace_file_with_user_input do |file|
        clear
        puts "Old file content (".green + file.white + "):".green
        nl
        puts `cat #{file.esc}`.chomp
        nl
        print "Write (enter for abort): ".green
        txt = gets.chomp
        return if txt.empty?
        w_file file, txt
        goto_file_mode file
end

doc "Скопировать файл в буфер обмена"
file_cmd :file_to_clipboard do |file|
        system "cat #{file.esc} | xclip"
end

file_cmd :play_sound_file do |file|
        clear
        system "mplayer #{file.esc} -loop 0 2> /dev/null "
end

def move_to_home file, dir, save_struct = false
        if save_struct
                mv_to_dir file, fjoin(fjoin(home_dir, dir), file.dirname.strip_home)
        else
                mv_to_dir file, fjoin(home_dir, dir)
        end
        rnd_file_in_dir dirname(file)
end


doc "Перенести файл в каталог проектов home_dir()/_prj"
file_cmd :move_file_to_home_prj do |file|
        move_to_home file, '_prj'
end

doc "Перенести файл в каталог проектов home_dir()/.later/dir
Сохраняя структуру каталогов
Добавляя дату переноса"
file_cmd :move_file_to_home_hidden_later do |file|
        file.add_date
        move_to_home file, '.later', true
end

doc "Перенести файл в каталог проектов home_dir()/.complete/dir
Сохраняя структуру каталогов
Добавляя дату переноса"
file_cmd :move_file_to_home_hidden_complete do |file|
        file.add_date
        move_to_home file, '.complete', true
end
