def statistic_dir 
        rc(:statistic_dir).ex
end

def stats what
        unless File.exists?(statistic_dir)
                FileUtils.mkdir_p statistic_dir
        end

        file = statistic_dir.fj(what)
        File.open(file, 'a+') do |f|
                f.write(Time.now.to_f.to_s + "\n")
        end
end
