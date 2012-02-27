
file_cmd :achieve_and_delete do |file|
        clear
        pth = file.strip_home
        status = file.achieve_status
        content = file.content
        system "achieve gtd #{status.to_s.esc} pth #{pth.esc} text #{content.esc}"
        rm_file_and_go_rnd file       
end

file_cmd :set_achieve_status_error do |file|
        file.achieve_status = :error
        rnd_file_in_dir file.dirname
end

file_cmd :set_achieve_status_bug do |file|
        file.achieve_status = :bug
        rnd_file_in_dir file.dirname
end

file_cmd :set_achieve_status_feature do |file|
        file.achieve_status = :feature
        rnd_file_in_dir file.dirname
end

file_cmd :set_achieve_status_test do |file|
        file.achieve_status = :test
        rnd_file_in_dir file.dirname
end
