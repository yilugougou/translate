module Watir
  class IE
    def execute_script(scriptCode)
      window.execScript(scriptCode)
    end

  end
end