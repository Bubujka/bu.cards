global_cmd :quit do 
        puts " " 
        exit
end

global_cmd :goto_random_in_default_dir do 
        random_files = `find #{default_dir}/* -type f | sort -R`.split "\n"
        goto_file_mode random_files.first
end

global_cmd :go_home do
        goto_dir_mode rc("default_dir").ex
end

global_cmd :show_help do |pth, mode|
        clear
        str = ob do
                bind = rc('bind')
                bind.each_key do |k|
                        print "\"#{k}\""
                        if (v = bind[k]).class == String
                                puts " -  #{bind[k]}"
                                if (v = @doc[bind[k].to_sym])
                                        puts "   #{v}"
                                end
                        elsif v.class == Hash
                                puts " -  #{v['name']}" if v['name'] 
                                v.each_key do |kk|
                                        if kk == 'name'
                                                next
                                        end
                                        print "   \"#{kk}\""
                                        puts " -  #{v[kk]}"
                                        if (t = @doc[v[kk].to_sym])
                                                puts "      #{t}"
                                        end
                                end
                        end
                end
        end
        system "echo #{str.esc} | #{pager}"
end

global_cmd :next_itm do |pth, mode|
        if mode == :file
                dir = dirname(pth)
                files = files_in_pth(dir)
                filename = basename(pth)
                files.each_cons(2) do |element, next_element|
                        if(element == filename)
                                goto_file_mode fjoin(dir, next_element).ex
                        end
                end
        elsif mode == :dir
                files = files_in_pth(pth)
                goto_file_mode fjoin(pth, files.first).ex
        end
end

global_cmd :prev_itm do |pth, mode|
        if mode == :file
                dir = dirname(pth)
                files = files_in_pth(dir)
                filename = basename(pth)
                files.each_cons(2) do |element, next_element|
                        if(next_element == filename)
                                goto_file_mode fjoin(dir, element).ex
                        end
                end
        elsif mode == :dir
                files = files_in_pth(pth)
                goto_file_mode fjoin(pth, files.last).ex
        end
end


doc "Создать новый файл из содержимого буфера обмена"
global_cmd :from_clipboard_to_new_file do |pth, mode|
        dir = pth
        dir = dirname(pth) if mode == :file

        next_num = find_next_num_in_dir dir
        pth = fjoin(dir, next_num.to_s)        
        FileUtils::touch(pth)
        system "xclip -o > #{pth}"
        system "#{editor} #{pth}"
        goto_file_mode pth
end

global_cmd :show_all_files_as_yaml do |pth, mode|
        clear
        dir = pth
        dir = dirname(pth) if mode == :file
        arr = []
        (files = files_in_pth(dir)).each do |file|
                arr.push({"file"=>file, "data" => r_file(fjoin(dir, file))})
        end

        FileUtils.touch(f = `mktemp --suffix=.yaml`.chomp)

        w_file(f, arr.ya2yaml(:syck_compatible => true))

        system("vim #{f}")

        t = YAML::load(r_file(f))

        new_files = t.map {|v| v["file"]}

        (files - new_files).each do |v|
                FileUtils.rm(fjoin(dir, v))
        end

        t.each do |v|
                w_file(fjoin(dir, v["file"]), v["data"])
        end

        FileUtils.rm(f)
end
