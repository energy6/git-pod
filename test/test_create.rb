require 'tmpdir'
require 'fileutils'
require 'pathname'
require 'minitest/autorun'

require_relative 'helper'
require_relative '../lib/git-pod'
require_relative '../lib/git-pod/Pod.rb'

describe GitPod::Create do
  before do
    @tempdir = create_tmp_repo()
  end

  after do
    cleanup_tmp_repo(self.name, @tempdir, passed?)    
  end

  describe "when creating a new pod" do
    NAME = "testPod"
    DESC = "A unit test created pod."

    before do
      Dir.chdir(@tempdir) do
        command = GitPod::Create.new ["-d", "#{DESC}", NAME]
        command.exec()
      end
    end

    it "leads to a new pod available" do
      Dir.chdir(@tempdir) do
        pods = GitPod::Pod.all()
        testPod = pods.select{ |pod| pod.name == NAME }.compact
        assert_equal 1, testPod.size, "No single pod with name '#{NAME}'' found."
        assert_equal DESC, testPod[0].description, "Description of pod does not match."
      end
    end

    it "leads to the pods master branch created" do
      repo = Git.open(@tempdir)
      branches = repo.branches.select{ |b| b.name == "pods/#{NAME}/master" }.compact
      assert_equal 1, branches.size, "Branch not found"
    end

    it "leads not to any additional pod branches created" do
      repo = Git.open(@tempdir)
      branches = repo.branches.select{ |b| b.name.start_with? "pods/#{NAME}/" }.compact
      assert_equal 1, branches.size, "Too many pod branches found"
    end
  end
end
