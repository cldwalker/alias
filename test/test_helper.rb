require 'bacon'
require 'mocha'
require 'mocha-on-bacon'
require 'alias'

class Bacon::Context
  alias_method :test, :it
  def before_all; yield; end
  def xtest(*args); end
  def capture_stdout(&block)
    original_stdout = $stdout
    $stdout = fake = StringIO.new
    begin
      yield
    ensure
      $stdout = original_stdout
    end
    fake.string
  end

  def capture_stderr(&block)
    original_stderr = $stderr
    $stderr = fake = StringIO.new
    begin
      yield
    ensure
      $stderr = original_stderr
    end
    fake.string
  end
end