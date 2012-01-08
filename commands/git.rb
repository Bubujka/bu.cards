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

dir_cmd :git_pull do |dir|
        clear
        system "cd #{dir}; git pull"
        char_gets
end

dir_cmd :git_push do |dir|
        clear
        system "cd #{dir}; git push"
        char_gets
end

dir_cmd :git_clear do |dir|
        clear
        system "cd #{dir}; git ls-files --deleted | xargs git rm" # thx to http://snippets.dzone.com/posts/show/5669
end

dir_cmd :git_add_clear_commit_push do |dir|
        clear
        system "cd #{dir}; git add ."
        system "cd #{dir}; git ls-files --deleted | xargs git rm"
        system "cd #{dir}; git commit"
        system "cd #{dir}; git push"
        puts
        puts "Finished".green
        char_gets
end
