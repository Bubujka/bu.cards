
def have_args?
        !ARGV.empty?
end

def config_file
        ex_pth @@options[:config]
end

def rc_exists?
        File.exists?(config_file)
end

def ex_pth pth
        File.expand_path(pth)
end

def r_file pth
        `cat #{pth}`.chomp
end

def w_file pth, content
        File.open(pth, "w") do |f|
                f.write(content)
        end
end

def rc what
        cfg = YAML::load(r_file(File.dirname(ex_pth(__FILE__)) + "/rc.yaml"))
        if rc_exists?
                cfg.deep_merge!(YAML::load(r_file(config_file)))
        end
        cfg[what.to_s]
end

def clear 
        print `clear`
end

def files_in_pth pth
        arr = Dir.entries(pth).select do |v|
                !File.directory? fjoin(pth, v) and !(v =='.' || v == '..') 
        end.natural_sort

        if rc(:hide_dotted_files)
                arr.select! do |v|
                        !v.match(/^\./)
                end
        end
        arr
end

def dirs_in_pth pth
        dirs = Dir.entries(pth).select do |v| 
                File.directory? fjoin(pth, v) and !(v =='.' || v == '..') 
        end.natural_sort

        if rc(:hide_empty_dirs)
                dirs.select! do |v|
                        Dir.entries(fjoin(pth, v)).size != 2
                end
        end

        if rc(:hide_dotted_dirs)
                dirs.select! do |v|
                        !v.match(/^\./)
                end
        end
        dirs
end

def pp_list array, label, ret = false
        r = ""
        if !array.empty?
                r += "#{label.green}: \n"
                IO.popen("pr --columns 3 -t", "r+") do |io|
                        array.each do |v|
                                io.puts "#{v}\n"
                        end
                        io.close_write
                        r += io.readlines.to_s + "\n"
                        r += "---------------------\n"
                end
        end
        puts(r) unless(ret)
        r
end

def fjoin pth, v
        File.join(pth, v)
end

def find_next_num_in_dir dir
        `ls -v #{dir} | grep '^[0-9]*$' | tail -1`.chomp.to_i + 1
end

def dirname pth
        File.dirname pth
end
def basename pth
        File.basename pth
end

def char_gets title = ""
  print title
  get_character.chr.strip
end

def dmenu arr, intro = "Enter num: "
        pp_list arr.each_index.map{|k| "#{k + 1} - #{arr[k]}"}, intro
        t = gets.chomp
        return unless t =~ /^[0-9]+$/
        t = t.to_i - 1
        arr[t]
end

def safe_mv from, to
        FileUtils.mkdir_p(dirname(to))
        system "mv --backup=t #{from} #{to}"
end

def title wtf
        # todo
end

def default_dir
        rc "default_dir"
end
@@watched = {}
def random_file_in dir
        @@watched[dir] = [] unless @@watched[dir]

        files = files_in_pth(dir) or []
        watched = @@watched[dir]

        diff = files - watched
        if diff.size <= 0
                @@watched[dir] = []
                diff = files
        end

        t = diff.choice
        return unless t
        @@watched[dir].push t
        return fjoin(dir, t)
end

def goto_file_mode file
        clear
        show_current_file_line file
        default_file_action file
        do_what_i_say_in_file file
end

def hr
        puts '-----------------------------------------------------'
end

def goto_dir_mode dir
        clear
        show_current_dir_line dir
        if File.exists?(pth = fjoin(dir, '.prj')) and ((prj_data = r_file(pth)) != "")
                hr
                puts r_file(pth)
                hr
        end
        default_dir_action dir
        do_what_i_say_in_dir dir
end

def editor
        ENV['EDITOR'] or 'vim'
end

def browser
        ENV['BROWSER'] or 'chromium-browser'
end

def pager
        ENV['PAGER'] or 'less'
end

def doc str
        #todo
end

class String
        def esc
                return "''" if self.empty?
                str = self.dup
                str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
                str.gsub!(/\n/, "'\n'")
                str
        end
end
