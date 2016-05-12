require 'tmpdir'
require 'fileutils'
require 'minitest/autorun'
require_relative '../lib/git-pod'

describe GitPod::Create do
  before do
    @tempdir = Dir.mktmpdir()
    repo=Git.init(@tempdir)
    FileUtils.touch "#{@tempdir}/README.txt"
    repo.add "#{@tempdir}/README.txt"
    repo.commit "Initial"
  end

  after do
    FileUtils.rm_rf(@tempdir)
  end

  describe "creating a new pod" do
    it "leads to a new pod master branch" do
      Dir.chdir(@tempdir) do
        command = GitPod::Create.new ["-d A unit test created pod.", "testPod"]
        command.exec()
      end
    end
  end
end
