# encoding: UTF-8

require "fileutils"
require "yaml"
require "./lib/sync_services"
require "middleman-gh-pages"

#
# Config
#

BUILD_DIR = './build'
PACKED_BUILD_DIR = './packed_builds'
DATA_DIR = './data'
DATA_ASSETS_DIR = './source/assets/data'
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
  require "bundler/setup"
  require "roo"
  require "csv"

  column_names = ["canton", "bfs_number", "municipality", "tax_freedom_day", "timespan", "gross_income", "social_group"]
  CSV.open("#{DATA_ASSETS_DIR}/fichier.csv", "w:iso8859-1") do |csv|
    csv << column_names

    # navigate into the data directory
    Dir.foreach("#{DATA_DIR}/raw") { |file|

      # only read excel files
      if file.include?('.xls')
        excel_file = Roo::Excel.new("#{DATA_DIR}/raw/#{file}")

        excel_file.sheets.each_with_index { |key, index|

          # set current default sheet to work on
          excel_file.default_sheet = key

          puts "working on sheet #{index} from file #{file}"
          3.upto(excel_file.last_row) do |line|
            csv << [
              excel_file.cell(line, 'A'), # canton
              excel_file.cell(line, 'B').to_i, # bfs_number
              excel_file.cell(line, 'C'), # municipality
              excel_file.cell(line, 'D'), # tax_freedom_day
              excel_file.cell(line, 'E').to_i, # timespan
              key.gsub(/\'/, '').gsub(/\sFr\./, ''), # gross_income
              file.gsub(/20130322_fichier/, '').gsub(/\.xls/, '') # social_group
            ]
          end
        }
      end
    }
  end
  puts "Files merged & converted."
end

desc "Fetch all municipalities within Switzerland"
task :fetch_municipalities do
  require "bundler/setup"
  require "csv"
  require "mechanize"

  @a = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  @b = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  @c = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  @d = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  @e = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }

  column_names = ["bfs_number", "german", "french", "italian", "english", "coat_of_arms"]
  CSV.open("#{DATA_ASSETS_DIR}/municipalities.csv", "w") do |csv|
    csv << column_names
  
    # open up the index of all municipalities
    @a.get('http://de.wikipedia.org/wiki/Gemeinden_der_Schweiz-A') do |page|

      def process_list(page_link, csv)
        @b.get("http://de.wikipedia.org#{page_link}") { |current_list|

          municipalities_list = current_list.parser
          municipalities_list.css('#mw-content-text>ul>li>a').each { |municipality|
            line = []
            french_link = ""
            italian_link = ""
            english_link = ""

            # german
            @b.get(municipality.attr('href')) { |municipality_page|
              municipality_doc = municipality_page.parser
              name = municipality_doc.css('#firstHeading>span').first.text
              puts name

              # bfs_number
              if municipality_doc.css('#mw-content-text>table.float-right.toptextcells>tr>td>a[title="Gemeindenummer"]').length >= 1
                municipality_doc.css('#mw-content-text>table.float-right.toptextcells>tr>td>a[title="Gemeindenummer"]').first.parent.parent.css('td:nth-child(2)>span').first.remove
                bfs_number = municipality_doc.css('#mw-content-text>table.float-right.toptextcells>tr>td>a[title="Gemeindenummer"]').first.parent.parent.css('td:nth-child(2)').first.text
                puts bfs_number
                line[0] = bfs_number
              end

              # # inhabitants
              # if municipality_doc.css('#mw-content-text>table.float-right.toptextcells>tr>td:contains("Einwohner:"').length >= 1
              #   puts municipality_doc.css('#mw-content-text>table.float-right.toptextcells>tr>td:contains("Einwohner:"').first.parent.name
              # end

              if municipality_doc.css('#mw-content-text>table>tr>td>div.center>div.floatnone>a.image>img').length >= 1
                line [5] = "http:#{municipality_doc.css('#mw-content-text>table>tr>td>div.center>div.floatnone>a.image>img').first.attr('src')}"
              end
              line[1] = name

              french_link = "http:#{municipality_doc.css('#p-lang div.body>ul>li.interwiki-fr>a').first.attr('href')}"
              italian_link = "http:#{municipality_doc.css('#p-lang div.body>ul>li.interwiki-it>a').first.attr('href')}"
              english_link = "http:#{municipality_doc.css('#p-lang div.body>ul>li.interwiki-en>a').first.attr('href')}"
            }

            # french
            @c.get(french_link) { |municipality_page|
              municipality_doc = municipality_page.parser
              name = municipality_doc.css('#firstHeading>span').first.text
              line[2] = name
              puts name
            }

            # italian
            @d.get(italian_link) { |municipality_page|
              municipality_doc = municipality_page.parser
              name = municipality_doc.css('#firstHeading>span').first.text
              line[3] = name
              puts name
            }

            # english
            @e.get(english_link) { |municipality_page|
              municipality_doc = municipality_page.parser
              name = municipality_doc.css('#firstHeading>span').first.text
              line[4] = name
              puts name
            }

            csv << line
          }
        }
      end

      process_list("/wiki/Gemeinden_der_Schweiz-A", csv)

      # go ahead to another list of municipalities
      alphabet_list = page.parser
      alphabet_list.css('#mw-content-text>p>a').each { |new_municipalities_list|
        if new_municipalities_list.attr('title') != "Politische Gemeinde"
          process_list(new_municipalities_list.attr('href'), csv)
        end
      }
    end
  end

end

#
# Helpers
#

def datetime_prefix
  Time.now.strftime('%y%m%d_%H%M%S')
end
