
def bindings
        return rc('bind')
end

def get_cmd_from_user
        act = char_gets
        
        if bindings.key? act
                t = bindings[act]
                if t.class == Hash
                        clear
                        name = t['name'] || ""
                        print "#{name}: ".green
                        act = char_gets
                        if t.key? act
                                return t[act]
                        else
                                return
                        end
                end
                return t
        end
end
