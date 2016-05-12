require 'tmpdir'
require 'fileutils'
require 'pathname'
require 'zip'
require 'minitest/autorun'
require_relative '../lib/git-pod'
require_relative '../lib/git-pod/Pod.rb'

def zip_folder(folder, zipfile_name)
  Zip::File.open(zipfile_name, Zip::File::CREATE) do |zipfile|
    Dir.glob("#{folder}/**/*", File::FNM_DOTMATCH) do |filename|
      # Two arguments:
      # - The name of the file as it will appear in the archive
      # - The original file, including the path to find it
      src = Pathname.new(folder)
      tgt = Pathname.new(filename)
      zipfile.add(tgt.relative_path_from(src).to_path, filename) if tgt.file?
    end
  end
end

describe GitPod::Create do
  before do
    @tempdir = Dir.mktmpdir()
    repo = Git.init(@tempdir)
    FileUtils.touch "#{@tempdir}/README.txt"
    repo.add "#{@tempdir}/README.txt"
    repo.commit "Initial"
  end

  after do
    unless passed?
      filename = "#{self.name.gsub(/\W/, "_")}-#{DateTime.now().strftime("%Y%m%d%H%M%S")}.zip"
      zip_folder(@tempdir, filename)
    end
    FileUtils.rm_rf(@tempdir)
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
