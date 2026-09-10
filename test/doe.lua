require 'compile'
require 'doe'

local app = compile "out = 1 + 2"

--assert(doe(app) == 3)
