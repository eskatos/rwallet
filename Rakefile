require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'rwallet'
  s.version = '0.0.3'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Command line password wallet written in ruby'
  s.description = s.summary
  s.author = 'Paul MERLIN'
  s.email = 'eskatos@n0pe.org'
  s.executables = ['rwallet']
  s.default_executable = 'rwallet'
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
  s.add_dependency('ezcrypto', '>=0.7.2')
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "rwallet Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
  rdoc.options << '--diagram'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

Rake::PackageTask.new('rwallet','0.0.1') do |p|
#  p.need_tar_gz = true
#  p.need_zip = true
#  p.need_tar_bz2 = false
#  p.need_tar = false
 p.package_files.include(%w(LICENSE README setup.rb) + Dir.glob("{bin,lib}/**/*"))
end



CLEAN.include('pkg')
CLEAN.include('doc')

