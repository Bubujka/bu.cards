def ddef name, &block
        self.class.send(:define_method, name, &block)
end

@file_cmds = []
@dir_cmds = []
@global_cmds = []

def add_doc_to name
        if (t = get_doc) 
                @doc[name] = t 
        end
end
def file_cmd name, &block
        add_doc_to name
        @file_cmds.push(name).uniq!
        ddef name, &block
end

def dir_cmd name, &block
        add_doc_to name
        @dir_cmds.push(name).uniq!
        ddef name, &block
end

def global_cmd name, &block
        add_doc_to name
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
