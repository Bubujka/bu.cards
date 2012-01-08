dir_cmd :dbg_show_env do |dir|
        clear
        pp ENV.to_hash
        char_gets
end
