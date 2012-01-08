dir_cmd :git_add do |dir|
        clear
        system "cd #{dir}; git add ."
end

dir_cmd :git_status do |dir|
        clear
        system "cd #{dir}; git status"
        char_gets
end

dir_cmd :git_log do |dir|
        clear
        system "cd #{dir}; git log"
end

dir_cmd :git_commit do |dir|
        clear
        system "cd #{dir}; git commit"
        char_gets
end
