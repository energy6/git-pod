require 'tmpdir'
require 'fileutils'
require 'pathname'
require 'minitest/autorun'
require 'ramcrest'

require_relative 'helper'
require_relative 'RamcrestExt'
require_relative '../lib/git-pod'
require_relative '../lib/git-pod/Pod.rb'

describe GitPod::List do
  include Ramcrest::MatchesPattern
  include Ramcrest::IncludesInAnyOrderExactly

  before do
    @tempdir = create_tmp_repo()
    Dir.chdir(@tempdir) do
      GitPod::Setup.new([]).exec()
    end
  end

  after do
    cleanup_tmp_repo(self.name, @tempdir, passed?)    
  end

  describe "when listing all available pods" do
    before do
      Dir.chdir(@tempdir) do
        @out, @err = capture_io do
          GitPod::List.new([]).exec()
        end
      end
    end

    it "gives " do
      lines = @out.split("\n")
      assert_that lines, includes_in_any_order_exactly(
          matches_pattern(/\s*No pods available.\s*/)
        )
    end
  end

  describe "when listing all available pods" do
    before do
      Dir.chdir(@tempdir) do
        GitPod::Create.new(["-d", "Test Pod A", "testPodA"]).exec()
        GitPod::Create.new(["-d", "Test Pod B", "testPodB"]).exec()
        GitPod::Create.new(["-d", "Test Pod C", "testPodC"]).exec()
        GitPod::Create.new(["-d", "Test Pod D", "testPodD"]).exec()
        GitPod::Create.new(["-d", "Test Pod E", "testPodE"]).exec()
        GitPod::Select.new([ "testPodB", "testPodC" ]).exec()
        @out, @err = capture_io do
          GitPod::List.new([]).exec()
        end
      end
    end

    it "gives " do
      lines = @out.split("\n")
      assert_that lines, includes_in_any_order_exactly(
          matches_pattern(/\s*testPodA\s+.*/),
          matches_pattern(/\s*testPodB\s+.*/),
          matches_pattern(/\s*testPodC\s+.*/),
          matches_pattern(/\s*testPodD\s+.*/),
          matches_pattern(/\s*testPodE\s+.*/)
        )
    end
  end

  describe "when listing all selected pods" do
    before do
      Dir.chdir(@tempdir) do
        GitPod::Create.new(["-d", "Test Pod A", "testPodA"]).exec()
        GitPod::Create.new(["-d", "Test Pod B", "testPodB"]).exec()
        GitPod::Create.new(["-d", "Test Pod C", "testPodC"]).exec()
        GitPod::Create.new(["-d", "Test Pod D", "testPodD"]).exec()
        GitPod::Create.new(["-d", "Test Pod E", "testPodE"]).exec()
        GitPod::Select.new([ "testPodB", "testPodC" ]).exec()
        @out, @err = capture_io do
          GitPod::List.new(['-u']).exec()
        end
      end
    end

    it "gives " do
      lines = @out.split("\n")
      assert_that lines, includes_in_any_order_exactly(
          matches_pattern(/\s*testPodB\s+.*/),
          matches_pattern(/\s*testPodC\s+.*/)
        )
    end
  end

  describe "when listing all not selected pods" do
    before do
      Dir.chdir(@tempdir) do
        GitPod::Create.new(["-d", "Test Pod A", "testPodA"]).exec()
        GitPod::Create.new(["-d", "Test Pod B", "testPodB"]).exec()
        GitPod::Create.new(["-d", "Test Pod C", "testPodC"]).exec()
        GitPod::Create.new(["-d", "Test Pod D", "testPodD"]).exec()
        GitPod::Create.new(["-d", "Test Pod E", "testPodE"]).exec()
        GitPod::Select.new([ "testPodB", "testPodC" ]).exec()
        @out, @err = capture_io do
          GitPod::List.new(['--no-used']).exec()
        end
      end
    end

    it "gives " do
      lines = @out.split("\n")
      assert_that lines, includes_in_any_order_exactly(
          matches_pattern(/\s*testPodA\s+.*/),
          matches_pattern(/\s*testPodD\s+.*/),
          matches_pattern(/\s*testPodE\s+.*/)
        )
    end
  end
end