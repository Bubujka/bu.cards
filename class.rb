class Array
        def hrify
                self.map(&:chomp).join("\n\n"+_hr+"\n\n").chomp
        end
end

class String
        def esc
                return "''" if self.empty?
                str = self.dup
                str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")
                str.gsub!(/\n/, "'\n'")
                str
        end

        def fj pth
                fjoin(self, pth)
        end

        def unyaml
                YAML::load(self)
        end

        def unyaml_file
                self.content.unyaml
        end

        def cdate
                File.ctime(self).strftime('%F')
        end
        
        def achieve_status
                if(self.content.split("\n")[0] =~ /ACHIEVE:(.*)/)
                        $1.chomp.to_sym
                else
                        :regular
                end
        end

        def achieve_status= what
                c = "ACHIEVE:#{what.to_s}\n" + self.content.sub(/ACHIEVE:(.*)\n/, '')
                self.content = c;
        end

        def basename
                File.basename self
        end

        def dirname
                File.dirname self
        end

        def content
                r_file self
        end

        def content= what
                w_file self, what
        end

        def strip_home
                t = self.dup
                return "" if t == home_dir
                t[home_dir() + '/'] = ""
                t
        end

        def ex
                File.expand_path(self)
        end

        def add_date 
                t = { 'date' => Time.now.to_s, 'file' => self.content}.ya2yaml(:syck_compatible => true)
                self.content = t
        end

        def add_date_and_path
                t = { 'date' => Time.now.to_s,
                      'path' => self.dirname.strip_home,
                      'file' => self.content}.ya2yaml(:syck_compatible => true)
                self.content = t
        end

        def files
                Dir.glob(File.join(File.expand_path(self), '*')).select do |file| 
                       File.file?(file) 
                end
        end

        def each_file &block
                self.files.each &block
        end
end
