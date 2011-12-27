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
        system "#{editor} #{pth}"
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
        system "#{editor} #{dest_pth}"

        rnd_file_in_dir dir
end

doc "Удалить файл и перейти к случайному"
file_cmd :rm_file_and_go_rnd do |file|
        File::unlink(file)
        if !files_in_pth(dir = File.dirname(file)).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode File.dirname(file)
        end
end

doc "Отредактировать файл в редакторе"
file_cmd :edit_file do |file|
        system "#{editor} #{file}"
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

file_cmd :hide_file do |file|
        dir = dirname(file)
        name = basename(file)
        dest_pth = fjoin(dir, ".#{name}")
        safe_mv(file, dest_pth)
        rnd_file_in_dir dir
end

file_cmd :run_file_in_browser do |file|
        system browser, file
end

file_cmd :run_content_in_browser do |file|
        system browser, r_file(file)
end
