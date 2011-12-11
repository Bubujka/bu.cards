def ddef name, &block
        self.class.send(:define_method, name, &block)
end

@file_cmds = []
@dir_cmds = []
@global_cmds = []

def file_cmd name, &block
        @file_cmds.push(name).uniq!
        ddef name, &block
end

def dir_cmd name, &block
        @dir_cmds.push(name).uniq!
        ddef name, &block
end

def global_cmd name, &block
        @global_cmds.push(name).uniq!
        ddef name, &block
end

def is_dir_cmd cmd
        @dir_cmds.include? cmd.to_sym
end

def is_file_cmd cmd
        @file_cmds.include? cmd.to_sym
end

def is_global_cmd cmd
        @global_cmds.include? cmd.to_sym
end
