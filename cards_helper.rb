
def have_args?
        !ARGV.empty?
end

def config_file
        @@options[:config].ex
end

def rc_exists?
        File.exists?(config_file)
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
        cfg = YAML::load(r_file(File.dirname(__FILE__.ex) + "/rc.yaml"))
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
                        t = fjoin(pth, v)
                        !(`find #{t.esc} -type f`.chomp.empty?)
                        #Dir.entries(t).size != 2
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

def get_char
        # return char from input or C-? C-A-?. 
        dbg(`stty`)
        key = ""
        begin
                  system("stty raw -echo")
                  dbg(`stty`)
                  f = STDIN.getc
                  if (1..26) === f
                          key = "C-" + (f + 96).chr
                  elsif f == ?\e
                        c = STDIN.getc
                        if (1..26) === c
                                key = "C-A-" + (c + 96).chr
                        else
                                key = "A-" + c.chr
                        end
                  else
                          if f >= 208
                                  key = f.chr + STDIN.getc.chr
                          else
                                  key = f.chr
                          end
                  end
        ensure
                  system("stty -raw -brkint -ignpar -istrip iutf8 echo")
        end
        dbg(`stty`)
        key
end

def dbg wtf
        open('~/.bucardslog'.ex, 'a') do |f|
                f.puts("\n[#{Time.now}]#{wtf}")
        end
end


def char_gets title = ""
  print title
  get_char.strip
end

def dmenu arr, intro = "Enter num: "
        keys = %w[ 1 2 3 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ]
        if(arr.size > keys.size)
                pp_list arr.each_index.map{|k| "#{k + 1} - #{arr[k]}"}, intro
                t = gets.chomp
                return unless t =~ /^[0-9]+$/
                t = t.to_i - 1
                arr[t]
        else
                pp_list arr.each_index.map{|k| "#{keys[k]} - #{arr[k]}"}, intro
                t = char_gets
                return unless keys.include? t
                arr[keys.find_index t]
        end
end

def safe_mv from, to
        FileUtils.mkdir_p(dirname(to))
        system "mv --backup=t #{from.esc} #{to.esc}"
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
        puts '-----------------------------------------------------'.green
end

def nl
        puts
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
        ENV['PAGER'] or 'less -R'
end

def ident_text prefix, text
        prefix  + text.split("\n").join("\n#{prefix}").chomp
end

@doc = {}
@doc_str = nil
def doc str
        @doc_str = str
end
def get_doc
        t = @doc_str
        @doc_str = nil
        t
end

class String
        def esc
                return "''" if self.empty?
                str = self.dup
                str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
                str.gsub!(/\n/, "'\n'")
                str
        end

        def cdate
                File.ctime(self).strftime('%F')
        end

        def basename
                File.basename self
        end
        def dirname
                File.dirname self
        end

        def strip_home
                t = self.dup
                t[home_dir() + '/'] = ""
                t
        end

        def ex
                File.expand_path(self)
        end
end

def ob 
        buffer = StringIO.new
        old_stdout = $stdout 
        $stdout = buffer
        yield
        $stdout = old_stdout
        buffer.rewind
        buffer.read
end
