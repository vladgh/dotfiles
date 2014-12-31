require 'irb/completion'
require 'irb/ext/save-history'

begin
  require "awesome_print"
  AwesomePrint.irb!
rescue LoadError
end

IRB.conf[:SAVE_HISTORY] = 999
IRB.conf[:EVAL_HISTORY] = 999
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb_history"
IRB.conf[:AUTO_INDENT]  = true
IRB.conf[:USE_READLINE] = true
IRB.conf[:PROMPT_MODE]  = :SIMPLE
IRB.conf[:LOAD_MODULES] |= %w(irb/completion stringio enumerator ostruct)

$: << '.'
