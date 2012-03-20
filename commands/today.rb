doc "Перенести файл в каталог home_dir()/_today
Добавляя дату и путь до оригинального файла" 
file_cmd :move_file_to_home_today do |file|
        file.add_date_and_path
        move_to_home file, '_today'
end

doc "Показать повестку дня из папки home_dir()/_today"
global_cmd :show_today_tasks do |pth, mode|
        clear
        dir = home_dir.fj('_today')
        files_in_pth(dir).each do |file|
                t = dir.fj(file).unyaml_file
                print "(#{t['path']}) ".green unless t['path'].chomp.empty?
                puts "#{t['file'].chomp}"
                hr
        end
        char_gets
end
