dir_cmd :git_add_clear_and_autocommit do |dir|
        clear
        puts system("cd #{dir}; git add .; /home/waserd/.db/bin/stable/git-clear; /home/waserd/.db/bin/git-autocommit; git push")
        char_gets
end

dir_cmd :goto_prj_file do |dir|
        goto_file_mode ex_pth(fjoin(dir, '.prj'))
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


dir_cmd :edit_new_file_with_next_name do |dir|
        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        FileUtils::touch(pth)
        system "#{editor} #{pth}"
        goto_file_mode pth
end

dir_cmd :edit_new_file_with_user_name do |dir|
        clear
        print "Enter file name: "
        name = gets.chomp
        pth = fjoin(dir, name)        
        FileUtils::touch(pth)
        system "#{editor} #{pth}"
        goto_file_mode pth
end

doc "Перейти на каталог выше"       
dir_cmd :go_upper_dir do |dir|
        goto_dir_mode ex_pth(fjoin(dir, '..')) 
end

doc "Перейти к случайному файлу в текущем каталоге"
dir_cmd :rnd_file_in_dir do |dir|
        if !files_in_pth(dir).empty?
                goto_file_mode random_file_in(dir)
        else
                goto_dir_mode dir
        end
end

