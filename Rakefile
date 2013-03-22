require "fileutils"
require "yaml"
require "./lib/sync_services"
require "roo"
require "csv"

#
# Config
#

BUILD_DIR = './build'
PACKED_BUILD_DIR = './packed_builds'
DATA_DIR = './data'
DEPLOY_SRC = BUILD_DIR                        # only deploy build dir
# DEPLOY_SRC = [BUILD_DIR, PACKED_BUILD_DIR]  # also deploy packed builds
REMOTES = YAML.load_file("remotes.yml")

namespace(:deploy) do
  desc "Deploy to production server"
  task :production => :build do
    SyncServices.sync(DEPLOY_SRC, REMOTES["production"])
  end

  desc "Deploy to staging server"
  task :staging => :build do
    SyncServices.sync(DEPLOY_SRC, REMOTES["staging"])
  end

  desc "Deploy to GitHub pages"
  task :gh => :build do
    require "bundler/setup"
    require "middleman-gh-pages"
    # ...
  end
end

namespace(:dry) do
  desc "Dry run to production server"
  task :production => :build do
    SyncServices.sync(DEPLOY_SRC, REMOTES["production"], :dry_run => true)
  end

  desc "Dry run to staging server"
  task :staging => :build do
    SyncServices.sync(DEPLOY_SRC, REMOTES["staging"], :dry_run => true)
  end
end

#
# Rake Tasks
#

task :default => :help

task :help do
  system "rake -T"
end

desc "Install dependencies (gems and Bower components)"
task :install do
  unless `bundle check`.match(%r{satisfied})
    puts "\e[31mBundle missing or out of date. Installing ...\e[0m"
    system "bundle install"
  end

  if `which bower` == "" || `bower --version`.split(".")[1].to_i < 7
    puts "\e[31mBower missing or out of date. Installing ...\e[0m"
    system "npm install bower -g"
  end

  if !File.exist?("components") || File.mtime("component.json") > File.mtime("components")
    puts "\e[31mComponents missing or out of date. Installing ...\e[0m"
    system "bower install --force-latest"
  end

  puts "\e[32mAll dependencies installed and up-to-date!\e[0m"
end

desc "Clean up builds and dependencies"
task :clean do
  rm_rf(BUILD_DIR)
  rm_rf(PACKED_BUILD_DIR)
  rm_rf('./.bundle')
  rm_rf('./components')
end

desc "Build Public HTML"
task :build => :install do
  system "bundle exec middleman build --clean"
end

desc "Pack build into ZIP"
task :pack_build => :build do
  file_name = "#{datetime_prefix}_build"
  mkdir PACKED_BUILD_DIR unless File.exists? PACKED_BUILD_DIR
  FileUtils.cd(PACKED_BUILD_DIR)
  cp_r "../#{BUILD_DIR}", file_name, {:remove_destination => true, :preserve => true}
  system "zip -r #{file_name} #{file_name}"
  rm_f('.DS_Store')
  rm_rf file_name
  FileUtils.cd('..')
end

desc "Run local development server"
task :server => :install do
  system "bundle exec middleman server"
end

desc "Merge all Excel files into one CSV"
task :process_raw do

  column_names = ["canton", "bfs_number", "municipality", "tax_freedom_day", "timespan", "gross_income", "social_group"]
  CSV.open("#{DATA_DIR}/clean/data.csv", "w") do |csv|
    csv << column_names

    # navigate into the data directory
    Dir.foreach("#{DATA_DIR}/raw") { |file|

      # only read excel files
      if file.include?('.xls')
        excel_file = Roo::Excel.new("#{DATA_DIR}/raw/#{file}")

        excel_file.sheets.each_with_index { |(key, sheet), index|
          puts "working on sheet #{index} from file #{file}"
          3.upto(excel_file.last_row) do |line|
            csv << [
              excel_file.cell(line, 'A'), # canton
              excel_file.cell(line, 'B'), # bfs_number
              excel_file.cell(line, 'C'), # municipality
              excel_file.cell(line, 'D'), # tax_freedom_day
              excel_file.cell(line, 'E'), # timespan
              key, # gross_income
              file # social_group
            ]
          end
        }
      end
    }
  end
  puts "Files merged & converted."
end

#
# Helpers
#

def datetime_prefix
  Time.now.strftime('%y%m%d_%H%M%S')
end
