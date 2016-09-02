require 'zip'

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

def create_tmp_repo()
  tempdir = Dir.mktmpdir()
  repo = Git.init(tempdir)
  FileUtils.touch "#{tempdir}/README.txt"
  repo.add "#{tempdir}/README.txt"
  repo.commit "Initial"
  return repo
end

def cleanup_tmp_repo(testname, repo, passed)
  tempdir = repo.dir.to_s
  unless passed
    filename = "#{testname.gsub(/\W/, "_")}-#{DateTime.now().strftime("%Y%m%d%H%M%S")}.zip"
    zip_folder(tempdir, filename)
  end
  FileUtils.rm_rf(tempdir)
end
