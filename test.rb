class Nothing
def initialize
raise ArgumentError.new("bad")
end
end
Nothing.new
