
global_cmd :quit do 
        puts " " 
        exit
end

global_cmd :goto_random_in_default_dir do 
        random_files = `find #{default_dir}/* -type f | sort -R`.split "\n"
        goto_file_mode random_files.first
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
        system "#{editor} #{pth}"
        goto_file_mode pth
end

