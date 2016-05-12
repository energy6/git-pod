require 'tmpdir'
require 'minitest/autorun'
require 'git-pod'

describe GitPod::Create do
  before do
    @tempdir = Dir.mktmpdir()
    p @tempdir
    Git.init(@tempdir)
  end

  after do
    puts @tempdir
    # Dir.rmdir(@tempdir)
  end

  describe "creating a new pod" do
    Dir.chdir(@tempdir) do
      command = GitPod::Create.new ["-d A unit test created pod.", "testPod"]

      it "leads to a new pod master branch" do
        command.exec()
      end

    end
  end
end

class CreateTest < Minitest::Unit::TestCase

  def test_easy
    puts "Yeah!"
  end

end
